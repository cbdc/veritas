#!/bin/bash
set -e

# This script is meant to be run by inotify to validate/process data files
# from veritas; when the content of $VERITAS_ARCHIVE changes.
#
# $VERITAS_ARCHIVE can change in three ways regarding its files:
# - file created
# - file modified
# - file deleted
# Regarding the fs/inotify signals, "created" and "modify" can be merged
# under the listening of one signal: "MODIFY", while "deleted" is signaled
# by "DELETE".
#
# The script expects three arguments:
# - the filename that was modified/deleted
# - the signal triggered
# - the directory where filename is/was

help() {
  echo ""
  echo "Usage: " `basename $0` "<arguments>"
  echo ""
  echo "Arguments are:"
  echo '  $1 : filename modified, created or deleted'
  echo '  $2 : incron event (IN_MODIFY,IN_DELETE,IN_MOVE)'
  echo '  $3 : source directory'
  echo ""
}

# Check number of arguments (3)
[ "$#" -ne 3 ] && { help; exit 0; }

FILENAME="$1"
EVENT="$2"
DIR="$3"

# Check whether (some) arguments are ok..
[ ! -d "$DIR" ] && { echo "Not a directory: '$DIR'"; exit 1; }

# We'll need the VERITAS' public data directory declared..
if [ -z "$REPO_VERITAS_DATA_PUB" ]; then
  REPO_VERITAS_DATA_PUB="${DIR%/*}/pub"
fi

# Now the file processing, functions namespaces...
is_file_ok () {
  FILE="$1"
  [ -f "$FILE" ]        || return 1
  [ "$FILE" != ".?*" ]  || return 1
  return 0
}

modify() {
  # Run veritas' csv2fits python script
  # If csv2fits succeeds, copy result to $REPO_VERITAS_DATA_PUB
  # and commit the change
  TMPDIR="$1"
  [[ -z "$TMPDIR" ]] && TMPDIR="/tmp"

  FILEIN="${DIR}/${FILENAME}"
  is_file_ok $FILEIN || return 1

  _FROOT="${FILEIN%.*}"
  FILEOUT="${TMPDIR}/${_FROOT}.fits"
  FILELOG="${TMPDIR}/${_FROOT}_${EVENT#*_}.log"
  FLOGERR="${FILELOG}.error"
  csv2fits $FILEIN $FILEOUT > $FILELOG 2> $FLOGERR
  if [ "$?" == "0" ]; then
    fits_commit_move $FILEOUT
  fi
  mv $FILELOG $FLOGERR $VERITAS_ARCHIVE_FEEDBACK
}

fits_commit_move() {
  # Move the fits file to VERITAS data(pub) repository
  # and then commit+push the modification
  mv $FITS $REPO_VERITAS_DATA_PUB
  
}
delete() {
  # Remove filename from $REPO_VERITAS_DATA_PUB
  # and commit the change
}

file_modify () {
  FILE=$1
  DEST=$2
  file_ok "${FILE}" || return 1
  cp $FILE $DEST
  return 0
}

file_delete () {
  FILE=$1
  rm "$FILE"
  return 0
}

[ "$EVENT" == "IN_MODIFY" -o "$EVENT" == "IN_MOVED" ] && \
    file_modify "${FULLFILENAME}" "${DESTDIR}"

# [ "$EVENT" == "IN_MOVED_FROM" -o "$EVENT" == "IN_MOVED_TO" ] && \
#     file_modify "${FULLFILENAME}" "${DESTDIR}"

[ "$EVENT" == "IN_DELETE" ] && \
    file_delete "${DESTDIR}/${FILENAME}"

commit() {
  # Commit changes of $REPO_VERITAS_DATA_PUB
  (
    cd $REPO_VERITAS_DATA_PUB               && \
    git commit -am "inotify change $EVENT"  &&\
    git push
  )
}




#!/bin/bash

ARCHIVE='veritas'

DESTDIR='/tmp/test_veritas'

[ ! -d "$DESTDIR" ] && mkdir -p "$DESTDIR"

# This script is going to be run by 'incrontab', whenever $ARCHIVE is updated
#
# Arguments
#  $1 : filename modified, created or deleted
#  $2 : incron event
#  $3 : source directory

FILENAME="$1"
EVENT="$2"
DIR="$3"

FULLFILENAME="${DIR}/${FILENAME}"


exit 0
