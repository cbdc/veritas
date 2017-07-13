#!/usr/bin/env bash

# This for is to avoid triggerings from hidden ('.*') files
for arg in "$@"
do
    [[ "$arg" != .?* ]] || exit 1
done

# The arguments are comming from incron; they go as:
# Triggering event: $1
# File name: $2
# Calling directory: $3

source ~/vo.rc

CURDIR=$(cd `dirname $BASH_SOURCE`; pwd)
FC=$(echo `basename "$2"` | tr -d "[:space:]")
LOGFILE="${CURDIR}/incron_veritas_${FC}.log"
unset FC
unset CURDIR

# To avoid concurrence (specially when commit/fetching git)
# we'll place a short random sleep before proceeding
WAIT=$(echo "scale=2 ; 3*$RANDOM/32768" | bc -l)
WAIT=$(echo "scale=2 ; ${WAIT}*${WAIT}" | bc -l)
sleep "$WAIT"s
unset WAIT

echo '-----------------------------------------------------' >> $LOGFILE
date >> $LOGFILE
#TODO: Use a non-hardcoded Anaconda load (e.g, Environment Modules)
export PATH="/opt/anaconda/bin:$PATH"
bash -x -l $REPO_VERITAS_PROC/archive_update.sh "$@"  &>> $LOGFILE
echo '-----------------------------------------------------' >> $LOGFILE
