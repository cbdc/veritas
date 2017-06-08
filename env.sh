#!/usr/bin/env bash

_CURDIR="$(cd $(dirname ${BASH_SOURCE[0]}); pwd)"

export REPO_VERITAS="${_CURDIR}"
export REPO_VERITAS_PROC="${REPO_VERITAS}/proc"
export REPO_VERITAS_DATA="${REPO_VERITAS}/data"
export REPO_VERITAS_DATA_PUB="${REPO_VERITAS_DATA}/pub"
export REPO_VERITAS_DATA_SRC="${REPO_VERITAS_DATA}/src"
