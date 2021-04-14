#!/bin/bash

if [[ $# -lt 1 ]]
then
  echo "Expected filename"
  exit 1
fi

fname=$1
#../llvm-project/build/bin/llvm2tfg ${fname} -o ${fname}.etfg --dyn_debug=lazy_code_motion | tee last_run.log
../llvm-project/build/bin/llvm2tfg ${fname} -o ${fname}.etfg | tee last_run.log
