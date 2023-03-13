#!/bin/bash

ROOT=$(dirname "$0")/..

if [[ $# -lt 1 ]]
then
  echo "Expected filename"
  exit 1
fi

fname=$1
fname_basename=$(basename "${fname}")
fname_bc=${fname_basename}.bc
fname_tmp_bc=${fname_basename}.tmp.bc

   ${ROOT}/llvm-project/build/bin/clang -Xclang -disable-llvm-passes -Xclang -disable-O0-optnone -c -m32 -emit-llvm -O0 "${fname}" -o "${fname_tmp_bc}" \
&& ${ROOT}/llvm-project/build/bin/opt -mem2reg -o "${fname_bc}" "${fname_tmp_bc}" \
&& rm "${fname_tmp_bc}" \
&& ${ROOT}/llvm-project/build/bin/llvm-dis "${fname_bc}"
