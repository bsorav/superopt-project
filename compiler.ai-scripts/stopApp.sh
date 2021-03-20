#!/bin/bash

set -o xtrace

sudo -H -E -u compilerai-server bash -c "ps aux | grep -i node | awk '{print \$2}' | xargs  kill -SIGINT"
exit 0
