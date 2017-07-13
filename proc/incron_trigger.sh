#!/usr/bin/env bash
for arg in "$@"
do
    [[ "$arg" != .?* ]] || exit 1
done

CURDIR=$(cd `dirname $BASH_SOURCE`; pwd)
LOG="${CURDIR}/veritas_incron.log"

echo '----------------------------------------------------------------------' >> $LOG
date >> $LOG
export PATH="/opt/anaconda/bin:$PATH"
source ~/vo.rc
bash -x -l $REPO_VERITAS_PROC/archive_update.sh "$@"  &>> $LOG
echo '----------------------------------------------------------------------' >> $LOG

