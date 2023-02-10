#!/bin/bash

ROOT=$(dirname "$0")/..

if [[ $# -lt 1 ]]
then
  echo "Expected filename"
  exit 1
fi

fname=$1
   ${ROOT}/llvm-project/build/bin/clang -Xclang -disable-llvm-passes -Xclang -disable-O0-optnone -c -m32 -emit-llvm -O0 ${fname} -o ${fname}.tmp.bc \
&& ${ROOT}/llvm-project/build/bin/opt -mem2reg -o ${fname}.bc ${fname}.tmp.bc \
&& rm ${fname}.tmp.bc \
&& ${ROOT}/llvm-project/build/bin/llvm-dis ${fname}.bc
