#!/bin/bash
set -e

source "${BASH_SOURCE%/*}/../env.sh"

# We'll need the VERITAS' public data directory declared..
[ -n "$REPO_VERITAS" ] || { 1>&2 echo "Environment not loaded"; exit 1; }

TMPDIR="$(mktemp -d)"
remove_temp() {
  [ -d "$TMPDIR" ] && rm -rf $TMPDIR
}

LOCKFILE='/tmp/veritas.lock'
remove_lock() {
  [ -f $LOCKFILE ] && rm $LOCKFILE
}

clean_exit() {
  remove_temp
  remove_lock
}
trap clean_exit EXIT ERR


csv2fits() {
  # Run the script to convert csv (veritas format) to fits
  # Arguments:
  FILEIN="$1"
  FILEOUT="$2"
  FILELOG="${3:-/dev/null}"
  FLOGERR="${4:-/dev/null}"

  : ${REPO_VERITAS_PROC?'VERITAS repo not defined'}

  # We have Anaconda managing our python env in the background
  # The python virtual-env is properly called 'veritas'
  # source activate veritas
  _script="${REPO_VERITAS_PROC}/csv2fits.py"
  /opt/anaconda/bin/python $_script $FILEIN $FILEOUT #> $FILELOG 2> $FLOGERR
}

is_file_ok () {
  FILE="$1"
  [ -f "$FILE" ]        || return 1
  return 0
}

modify() {
  # Arguments:
  FILENAME="$1"
  DIR_IN="$2"
  EVENT="$3"

  : ${REPO_VERITAS_DATA_PUB?'VERITAS repo not defined'}

  DIR_LOG="${DIR_IN}/log"

  # Run veritas' csv2fits python script
  # If csv2fits succeeds, copy result to $REPO_VERITAS_DATA_PUB
  # and commit the change

  FILEIN="${DIR_IN}/${FILENAME}"
  is_file_ok $FILEIN || return 1

  _FROOT="${FILENAME%.*}"
  FILEOUT="${TMPDIR}/${_FROOT}.fits"
  FILELOG="${TMPDIR}/${_FROOT}_${EVENT#*_}.log"
  FLOGERR="${FILELOG}.error"
  unset _FROOT

  csv2fits $FILEIN $FILEOUT $FILELOG $FLOGERR

  if [ "$?" == "0" ]; then
    cp $FILEOUT   $REPO_VERITAS_DATA_PUB
    commit $EVENT
  else
    1>&2 echo "CSV2FITS failed. Output at '$DIR_LOG'"
  fi
  # Always copy the log/err output to archive's feedback
  mv $FILELOG $FLOGERR   $DIR_LOG
}

delete() {
  # Arguments:
  CSV_FILE="$1"
  DIR_IN="$2"
  EVENT="$3"

  : ${REPO_VERITAS_DATA_PUB?'VERITAS repo not defined'}

  # Remove filename from $REPO_VERITAS_DATA_PUB
  # and commit the change
  _trash="${REPO_VERITAS_DATA_SRC}/trash"
  mv "${REPO_VERITAS_DATA_SRC}/$CSV_FILE" "${_trash}/."

  FITS_FILE="${CSV_FILE%.*}.fits"
  rm "${REPO_VERITAS_DATA_PUB}/$FITS_FILE"

  commit $EVENT
}

fetch_gavo() {
  : ${GAVO_ROOT:?GAVO_ROOT not defined}
  sleep 5
  (
    cd "${GAVO_ROOT}/inputs/veritas"  &&\
    git fetch && git pull             &&\
    gavo imp q.rd
  )
}

commit() {
  # Arguments:
  EVENT="$1"
  FILE="$2"
  ACT="$3"

  : ${REPO_VERITAS?'VERITAS repo not defined'}

  while [ -f $LOCKFILE ]
  do
    sleep 1
  done
  touch $LOCKFILE

  # Commit changes of $REPO_VERITAS_DATA_PUB
  (
    cd $REPO_VERITAS                        && \
    git commit -am "inotify change $EVENT"  && \
    git push
  )
  fetch_gavo
  remove_lock
}
