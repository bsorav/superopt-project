#!/bin/bash

ROOT=/superopt-project
export SUPEROPT_INSTALL_DIR=/usr/local
export SUPEROPT_PROJECT_DIR=/superopt-project

if [ ! -f "$ROOT" ]; then
	git -C / clone https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt-project
fi
git -C $ROOT reset --hard
git -C $ROOT/superopt reset --hard
git -C $ROOT/superoptdbs reset --hard
git -C $ROOT/llvm-project reset --hard
git -C $ROOT/superopt-tests reset --hard
git -C $ROOT/compiler.ai-scripts/compiler-explorer reset --hard
git -C $ROOT config --file=.gitmodules submodule.superopt.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt
git -C $ROOT config --file=.gitmodules submodule.llvm-project.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/llvm-project2
git -C $ROOT config --file=.gitmodules submodule.superoptdbs.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superoptdbs
#git -C $ROOT config --file=.gitmodules submodule.superopt-tests.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt-tests # superopt-tests is at iitd-plos
git -C $ROOT config --file=.gitmodules submodule.superopt-tests.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/iitd-plos/superopt-tests # superopt-tests is at iitd-plos
git -C $ROOT config --file=.gitmodules submodule.compiler.ai-scripts/compiler-explorer.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/compiler-explorer
git -C $ROOT pull --recurse-submodules
#git -C $ROOT submodule sync
#git -C $ROOT submodule update --init --recursive --remote

if [ ! -f "/usr/bin/node" ]; then
	mkdir -p $ROOT/compiler.ai-scripts/build && cd $ROOT/compiler.ai-scripts/build && git clone https://github.com/nodejs/node && cd - && cd $ROOT/compiler.ai-scripts/build/node && git checkout v13.x && ./configure && make && make install PREFIX=/usr && cd - && sudo setcap cap_net_bind_service=+eip /usr/bin/node #this is to allow listening on port 80
fi
cd $ROOT/compiler.ai-scripts/compiler-explorer && npm update && npm install webpack-dev-server --save-dev && cd -
ln -sf /tars $ROOT/tars
make -C $ROOT SUPEROPT_INSTALL_DIR=/usr/local
#cd $ROOT/superopt && ./configure && cd -
#make -C $ROOT/superopt debug SUPEROPT_INSTALL_DIR=/usr/local
#make -C $ROOT/llvm-project install SUPEROPT_INSTALL_DIR=/usr/local
#touch $ROOT/llvm-project/llvm/tools/eqchecker/main.cpp
#make -C $ROOT/llvm-project SUPEROPT_INSTALL_DIR=/usr/local
#make -C $ROOT/superoptdbs SUPEROPT_INSTALL_DIR=/usr/local
#make -C $ROOT cleaninstall SUPEROPT_INSTALL_DIR=/usr/local
#make -C $ROOT $ROOT/build/qcc $ROOT/build/ooelala $ROOT/build/clang11 SUPEROPT_INSTALL_DIR=/usr/local
#make -C $ROOT linkinstall  SPEROPT_INSTALL_DIR=/usr/local
#cd $ROOT/superopt-tests && ./configure && make && cd -
make -C $ROOT compiler_explorer_preload_files

$ROOT/compiler.ai-scripts/add-user-script.sh user compiler.ai123
chown -R user:user $ROOT
