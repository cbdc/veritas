#!/bin/bash
set -ueE

HERE=$(cd `dirname ${BASH_SOURCE}`; pwd)

#TODO: probably define LOGDIR in base of LOGFILE (if there is one)
LOGDIR=${LOGDIR:-${HERE}/log}
[ -d $LOGDIR ] || mkdir -p $LOGDIR

# Load environment variables indicating where veritas archive is
source "${HERE}/../env.sh"

# We'll need the VERITAS' public data directory declared..
[ -n "$REPO_VERITAS" ] || { 1>&2 echo "Environment not loaded"; exit 1; }

# TMPDIR will have all the temporary files and partial products.
# At the end, products, log files will be copied from it.
TMPDIR="$(mktemp -d)"
remove_temp() {
  if [ -d "$TMPDIR" ]; then
    rm -rf $TMPDIR
  fi
}

# LOCKFILE will avoid concurrence between instances of 'git_commit' function
LOCKFILE='/tmp/veritas.lock'
create_lock() {
  touch $LOCKFILE
}
remove_lock() {
  if [ -f $LOCKFILE ]; then
    rm $LOCKFILE
  fi
}

temp_clean() {
  remove_lock
  remove_temp
}

exit_ok() {
  temp_clean
}
trap exit_ok EXIT

exit_error() {
  _bin="${LOGDIR}/leftovers"
  [ -d $_bin ] || mkdir -p $_bin
  cp ${TMPDIR}/* ${_bin}/.
  temp_clean

  ##NOTE: alert
  #> message 'VERITAS' 'ERROR' "Pipeline crashed"
  ##
}
trap exit_error ERR



is_file_ok () {
  FILE="$1"
  [ -f "$FILE" ]        || return 1
  return 0
}

csv2fits() {
  # Run the script to convert csv (veritas format) to fits
  # Arguments:
  FILEIN="$1"
  FILEOUT="$2"
  FILELOG="${3:-/dev/null}"
  FLOGERR="${4:-/dev/null}"

  : ${REPO_VERITAS_PROC:?'VERITAS repo not defined'}

  # We have Anaconda managing our python env in the background
  # The python virtual-env is properly called 'veritas'
  # source activate veritas
  _script="${REPO_VERITAS_PROC}/csv2fits.py"
  /opt/anaconda/bin/python $_script $FILEIN $FILEOUT > $FILELOG 2> $FLOGERR
  return
}



add_untracked() {
  # for uf in `git status --porcelain | xargs -I{} echo {} | cut -d' ' -f2`
  # do
  #   git add $uf
  # done
  return
}

fetch_gavo() {
  : ${GAVO_ROOT:?GAVO_ROOT not defined}
  sleep 5
  (
    cd "${GAVO_ROOT}/inputs/veritas"  &&\
    git fetch && git pull             &&\
    gavo imp q.rd
  )
  sleep 5
  return
}

make_changes() {
  local EVENT="$1"
  local FILES="${@:2}"

  # Do the commit/push
  (
    cd $REPO_VERITAS

    if [[ "$EVENT" =~ "MOVED" || "$EVENT" =~ "MODIFY" ]]; then
      for f in "${FILES}"; do
        git add $f
      done
    fi

    if [[ "$EVENT" =~ "DELETE" ]]; then
      _trash="${REPO_VERITAS_DATA_SRC}/trash"
      for f in "${FILES}"; do
        git mv $f   ${_trash}/.
      done
    fi

    git commit -am "inotify changes $EVENT"           && \
    git push
  )
  # and update GAVO
  fetch_gavo
  return
}

git_commit() {
  # Arguments:
  # local EVENT="$1"
  # local FILES="${@:2}"

  : ${REPO_VERITAS:?'VERITAS repo not defined'}

  x=0
  while [ -f $LOCKFILE ]
  do
    sleep 1
    let x=x+1
    [ "$x" -lt "120" ] || { 1>&2 echo "Lock file got stuck."; exit 1; }
  done
  create_lock

  make_changes $@

  remove_lock
  return
}

move_to_archive() {
  local FILEOUT="$1"
  local FILEIN="$2"
  local EVENT="$3"

  local FOUT=$(basename $FILEOUT)
  local FILEPUB="${REPO_VERITAS_DATA_PUB}/$FOUT"
  unset FOUT
  cp $FILEOUT $FILEPUB

  local FOUT=$(basename $FILEIN_TMP)
  local FILESRC="${REPO_VERITAS_DATA_SRC}/$FOUT"
  unset FOUT
  cp $FILEIN $FILESRC

  git_commit $EVENT $FILEPUB $FILESRC
}

delete() {
  # Arguments:
  local CSV_FILE="$1"
  local DIR_IN="$2"
  local EVENT="$3"

  : ${REPO_VERITAS_DATA_PUB?'VERITAS repo not defined'}

  # Remove filename from $REPO_VERITAS_DATA_PUB
  # and commit the change
  local FITS_FILE="${CSV_FILE%.*}.fits"
  local FILEPUB="${REPO_VERITAS_DATA_PUB}/$FITS_FILE"
  local FILESRC="${REPO_VERITAS_DATA_SRC}/$CSV_FILE"

  git_commit $EVENT $FILEPUB $FILESRC
  return
}

modify() {
  # Arguments:
  local FILENAME="$1"
  local DIR_IN="$2"
  local EVENT="$3"

  : ${REPO_VERITAS_DATA_PUB?'VERITAS repo not defined'}

  local ARCHIVE_LOG="${DIR_IN}/log"
  [ -d "$ARCHIVE_LOG" ] || mkdir $ARCHIVE_LOG

  # Run veritas' csv2fits python script
  # If csv2fits succeeds, copy result to $REPO_VERITAS_DATA_PUB
  # and commit the change

  local FILEIN="${DIR_IN}/${FILENAME}"
  is_file_ok $FILEIN || return 1

  # This block may be removed by now.
  # It was added to workaround an issue in astropy where data tables
  # with multiple \tabs and \spaces would raise an error.
  # The python function --csv2fits-- has now an argument (delimiter)
  # that should work this out.
  #
  local FILEIN_TMP="${TMPDIR}/${FILENAME}"
  local FILETMP="${TMPDIR}/${FILENAME}.tmp"
  grep "^#" $FILEIN > $FILETMP
  grep -v "^#" $FILEIN | tr -s "\t" " " >> $FILETMP
  cp $FILETMP $FILEIN_TMP && rm $FILETMP
  unset FILETMP
  # ---

  # If file is named with strange/ugly sintax, we clean it.
  # Notice that it all happens in TMP-DIR, so there is no
  # triggers happening when file is renamed.
  #
  local BETTERFILENAME=$(echo $FILEIN_TMP | tr -s "." | tr "+" "p")
  mv $FILEIN_TMP $BETTERFILENAME
  FILEIN_TMP=$BETTERFILENAME
  unset BETTERFILENAME
  unset FILENAME

  # Define log filenames and the output data file
  #
  local FILEROOTNAME="$(basename $FILEIN_TMP)"
  FILEROOTNAME="${FILEROOTNAME%.*}"
  #
  local FILEOUT="${TMPDIR}/${FILEROOTNAME}.fits"
  #
  local FILELOG="${TMPDIR}/${FILEROOTNAME}_${EVENT#*_}.log"
  local FLOGERR="${FILELOG}.error"

  # csv2fits $FILEIN $FILEOUT $FILELOG $FLOGERR
  csv2fits $FILEIN_TMP $FILEOUT $FILELOG $FLOGERR

  if [ "$?" == "0" ]; then
    1>&2 echo "CSV2FITS failed. Output at '$LOGDIR'"
    ##NOTE: alert
    #> message 'VERITAS' 'ERROR' "File conversion to fits failed"
    ##
  else
    move_to_archive $FILEOUT $FILEIN_TMP $EVENT
  fi

  # Always copy the log/err output to archive's feedback
  cp $FILELOG $FLOGERR   $ARCHIVE_LOG
}
