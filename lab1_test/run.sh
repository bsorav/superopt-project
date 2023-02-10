#!/bin/bash

ROOT=$(dirname "$0")/..

if [[ $# -lt 1 ]]
then
  echo "Expected filename"
  exit 1
fi

fname=$1
fname_basename=$(basename "${fname}")
fname_etfg=${fname_basename}.etfg

#${ROOT}/llvm-project/build/bin/llvm2tfg "${fname}" -o "${fname_etfg}" --dyn_debug=anticipated_analysis
${ROOT}/llvm-project/build/bin/llvm2tfg "${fname}" -o "${fname_etfg}" | tee last_run.log
