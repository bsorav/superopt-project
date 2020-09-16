#!/bin/bash
ROOT=/superopt-project
timestamp=$(date +'%Y.%m.%d.%H.%M')
cd $ROOT && screen -L -Logfile compilerai.log.${timestamp} -d -m make -C compiler.ai-scripts/compiler-explorer && cd -
