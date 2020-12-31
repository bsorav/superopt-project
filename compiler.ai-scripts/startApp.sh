#!/bin/bash

set -o xtrace

PARENTDIR=/home/compilerai-server
ROOT=$PARENTDIR/superopt-project

timestamp=$(date +'%Y.%m.%d.%H.%M')
cd $ROOT && sudo -u compilerai-server screen -L -Logfile compilerai.log.${timestamp} -d -m make -C compiler.ai-scripts/compiler-explorer && cd -
