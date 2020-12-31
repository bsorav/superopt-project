#!/bin/bash
PARENTDIR=/home/compilerai-server
ROOT=$PARENTDIR/superopt-project
timestamp=$(date +'%Y.%m.%d.%H.%M')
sudo -u compilerai-server {cd $ROOT && screen -L -Logfile compilerai.log.${timestamp} -d -m make -C compiler.ai-scripts/compiler-explorer && cd -}
