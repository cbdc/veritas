#!/usr/bin/env bash
set -u

# This for is to avoid triggerings from hidden ('.*') files
for arg in "$@"
do
    [[ "$arg" != .?* ]] || exit 1
done

# The arguments are comming from incron; they go as:
# Triggering event: $1
# File name: $2
# Calling directory: $3

# 'env.rc' defines REPOS and DATA variables, then call their own 'env.rc'.
# Eventually -- of interest here -- REPO_VERITAS_PROC will be defined.
#TODO: Consider the use of Environment Modules for setting up variables.
source ~/env.rc
: ${REPO_VERITAS_PROC:?'VERITAS repo enviroment not loaded.'}

EV="$1"
FC=$(echo `basename "$2"` | tr -d "[:space:]")
LOGDIR="${REPO_VERITAS_PROC}/log"
LOGFILE="${LOGDIR}/incron_veritas_${EV}_${FC}.log"
[ -d "$LOGDIR" ] || mkdir $LOGDIR
unset FC
unset EV

# To avoid concurrence (specially when commit/fetching git)
# we'll place a short random sleep before proceeding
WAIT=$(echo "scale=2 ; 3*$RANDOM/32768" | bc -l)
WAIT=$(echo "scale=2 ; ${WAIT}*${WAIT}" | bc -l)
sleep "$WAIT"s
unset WAIT

DATE=$(date)
echo $DATE                                                    > $LOGFILE
echo '-----------------------------------------------------' >> $LOGFILE
#TODO: Use a non-hardcoded Anaconda load (e.g, Environment Modules)
export PATH="/opt/anaconda/bin:$PATH"

##NOTE:alert
#> message 'VERITAS' 'INFO' "$DATE: file $2, signal $1"
##
bash -x -l $REPO_VERITAS_PROC/archive_update.sh "$@"        &>> $LOGFILE
##NOTE:alert
#> status=$? && STS=$([[ $? -eq 0 ]] && echo 'succeeded' || echo 'failed')
#> message 'VERITAS' 'INFO' "$DATE: file $2 processing $STS"
##
echo '-----------------------------------------------------' >> $LOGFILE


# The alert system
# ----------------
# Either we load a module (source alerts.sh) or we put it in PATH
# During development phase the module seems to be a better solution;
# when in production, a script in PATH may be better.
