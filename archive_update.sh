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
# - the directory where filename is/was
# - the signal triggered

# TODO: check number of arguments (3)
FILENAME="$1"
DIRPATH="$2"
EVENT="$3"

function commit() {
  # Commit changes of $REPO_VERITAS_DATA_PUB
  (
    cd $REPO_VERITAS_DATA_PUB               && \
    git commit -am "inotify change $EVENT"  &&\
    git push
  )
}

function modify() {
  # Run veritas' csv2fits python script
  # If csv2fits succeeds, copy result to $REPO_VERITAS_DATA_PUB
  # and commit the change
}

function delete() {
  # Remove filename from $REPO_VERITAS_DATA_PUB
  # and commit the change
}
