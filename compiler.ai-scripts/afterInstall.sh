#!/bin/bash

set -o xtrace

PARENTDIR=/home/compilerai-server
BRANCH=perf
ROOT=$PARENTDIR/superopt-project
export SUPEROPT_INSTALL_DIR=/usr/local
export SUPEROPT_PROJECT_DIR=$ROOT

if [ ! -f "$ROOT" ]; then
	sudo -E -u compilerai-server mkdir -p $PARENTDIR
	sudo -E -u compilerai-server git -C $PARENTDIR clone https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt-project
	sudo -E -u compilerai-server git -C $ROOT checkout $BRANCH
fi
sudo -u compilerai-server git -C $ROOT reset --hard
sudo -u compilerai-server git -C $ROOT/superopt reset --hard
sudo -u compilerai-server git -C $ROOT/superoptdbs reset --hard
sudo -u compilerai-server git -C $ROOT/llvm-project reset --hard
sudo -u compilerai-server git -C $ROOT/superopt-tests reset --hard
sudo -u compilerai-server git -C $ROOT/compiler.ai-scripts/compiler-explorer reset --hard
sudo -u compilerai-server git -C $ROOT pull
sudo -u compilerai-server git -C $ROOT config --file=.gitmodules submodule.superopt.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt
sudo -u compilerai-server git -C $ROOT config --file=.gitmodules submodule.llvm-project.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/llvm-project2
sudo -u compilerai-server git -C $ROOT config --file=.gitmodules submodule.superoptdbs.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superoptdbs
#sudo -u compilerai-server git -C $ROOT config --file=.gitmodules submodule.superopt-tests.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt-tests # superopt-tests is at iitd-plos
sudo -u compilerai-server git -C $ROOT config --file=.gitmodules submodule.superopt-tests.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/iitd-plos/superopt-tests # superopt-tests is at iitd-plos
sudo -u compilerai-server git -C $ROOT config --file=.gitmodules submodule.compiler.ai-scripts/compiler-explorer.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/compiler-explorer
sudo -u compilerai-server git -C $ROOT submodule init
sudo -u compilerai-server git -C $ROOT submodule update

if [ ! -f "/usr/bin/node" ]; then
	sudo -u compilerai-server {mkdir -p $ROOT/compiler.ai-scripts/build && cd $ROOT/compiler.ai-scripts/build && git clone https://github.com/nodejs/node && cd - && cd $ROOT/compiler.ai-scripts/build/node && git checkout v13.x && ./configure && make && cd -} && make -C $ROOT/compiler.ai-scripts/build/node install PREFIX=/usr && setcap cap_net_bind_service=+eip /usr/bin/node #this is to allow listening on port 80)
fi
sudo -E -u compilerai-server {cd $ROOT/compiler.ai-scripts/compiler-explorer && npm update && npm install webpack-dev-server --save-dev && cd -}
ln -sf `pwd`/tars $ROOT/tars
sudo -E -u compilerai-server make -C $ROOT build SUPEROPT_INSTALL_DIR=/usr/local
make -C $ROOT install SUPEROPT_INSTALL_DIR=/usr/local
sudo -E -u compilerai-server make -C $ROOT compiler_explorer_preload_files

chown -R compilerai-server:compilerai-server $ROOT
