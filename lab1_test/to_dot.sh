#!/bin/bash

ROOT=$(dirname "$0")/..

if [[ $# -lt 2 ]]
then
  echo "Usage: $0 <function_name> <etfg_filename>"
  exit 1
fi

func=$1
file=$2
file_basename=$(basename ${file})
${ROOT}/superopt/build/etfg_i386/tfg2dot --collapse=0 ${func} ${file} ${file_basename}.${func}.dot
