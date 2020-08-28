#!/bin/bash

ROOT=/superopt-project

if [ ! -f "$ROOT" ]; then
	git -C / clone https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt-project
fi
git -C $ROOT config --file=.gitmodules submodule.superopt.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt
git -C $ROOT config --file=.gitmodules submodule.llvm-project.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/llvm-project2
git -C $ROOT config --file=.gitmodules submodule.superoptdbs.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superoptdbs
#git -C $ROOT config --file=.gitmodules submodule.superopt-tests.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt-tests # superopt-tests is at iitd-plos
git -C $ROOT config --file=.gitmodules submodule.superopt-tests.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/iitd-plos/superopt-tests # superopt-tests is at iitd-plos
git -C $ROOT config --file=.gitmodules submodule.compiler.ai-scripts/compiler-explorer.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/compiler-explorer
git -C $ROOT submodule sync
git -C $ROOT submodule update --init --recursive --remote

if [ ! -f "/usr/local/bin/node" ]; then
	mkdir -p $ROOT/compiler.ai-scripts/build && cd $ROOT/compiler.ai-scripts/build && git clone https://github.com/nodejs/node && cd - && cd $ROOT/compiler.ai-scripts/build/node && git checkout v13.x && ./configure && make && sudo make install && cd - && sudo setcap cap_net_bind_service=+eip /usr/local/bin/node #this is to allow listening on port 80
fi
cd $ROOT/compiler.ai-scripts/compiler-explorer && npm update && npm install webpack-dev-server --save-dev && cd -
make -C $ROOT
make -C $ROOT linkinstall
make -C $ROOT compiler_explorer_preload_files

$ROOT/compiler.ai-scripts/add-user-script.sh user compiler.ai123
chown -R user:user $ROOT
