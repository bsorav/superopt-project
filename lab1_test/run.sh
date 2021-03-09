#!/bin/bash

if [[ $# -lt 1 ]]
then
  echo "Expected filename"
  exit 1
fi

fname=$1
#../llvm-project/build/bin/llvm2tfg ${fname} -o ${fname}.etfg --dyn_debug=anticipated_analysis
../llvm-project/build/bin/llvm2tfg ${fname} -o ${fname}.etfg | tee last_run.log
