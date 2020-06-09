#!/bin/bash

ROOT=/superopt-project
#cd /compiler.ai/ && rm -rf compiler-explorer && git clone https://bsorav@github.com/bsorav/compiler-explorer

cd / && git clone --recurse-submodules -j8 https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt-project && cd superopt-project

if [ ! -f "/usr/local/bin/node" ]; then
	mkdir -p $ROOT/compiler.ai-scripts/build && cd $ROOT/compiler.ai-scripts/build && git clone https://github.com/nodejs/node && cd - && cd $ROOT/compiler.ai-scripts/build/node && git checkout v13.x && ./configure && make && sudo make install && cd - && setcap cap_net_bind_service=+eip /usr/local/bin/node #this is to allow listening on port 80
fi
cd $ROOT/compiler.ai-scripts/compiler-explorer && npm update && npm install webpack-dev-server --save-dev && cd -

$ROOT/compiler.ai-scripts/add-user-script.sh user compiler.ai123
chown -R user:user $ROOT
