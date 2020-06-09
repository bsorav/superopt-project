#!/bin/bash
PREFIX=$PWD/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive
apt install python3-distutils gcc g++ make-guile
git -C $PREFIX config submodule.superopt.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superopt
git -C $PREFIX config submodule.llvm-project.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/llvm-project
git -C $PREFIX config submodule.superoptdbs.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superoptdbs
git -C $PREFIX config submodule.superopt-tests.url https://compilerai-bot:SaouK7or7nJwUBIRDNF9@github.com/bsorav/superoptdbs
git -C $PREFIX submodule update --init --recursive
rm -rf /superopt-project
