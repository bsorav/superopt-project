#!/bin/bash
# installs dependency pacakges

# strict mode
set -euo pipefail

if [[ "$EUID" -ne 0 ]];
then
  echo "Please run as root"
  exit
fi

build="cmake flex bison unzip ninja-build python3-pip git"
llvm="llvm llvm-dev clang-9"
libs="gcc-multilib g++-multilib libboost-all-dev libiberty-dev binutils-dev zlib1g-dev libgmp-dev libelf-dev libmagic-dev libssl-dev libswitch-perl ocaml-nox lib32stdc++-8-dev"
yices="gperf libgmp3-dev autoconf"
superopt="expect rpcbind z3 libz3-dev"
db="ruby ruby-dev gem freetds-dev"
fbgen="camlidl"
compiler_explorer="python3-distutils gcc g++ make"

GCC=gcc-8
tests="libc6-dev-i386 gcc-8-multilib g++-8-multilib linux-libc-dev:i386 parallel"
compcert="menhir ocaml-libs"
suggested="cscope exuberant-ctags atool"

apt-get install -y $build $llvm $libs $yices $superopt $db $fbgen $tests $compiler_explorer

#following is for eqbin.py script
pip install --proxy=$http_proxy python-magic

#following is for db
gem install tiny_tds

#for installing compcert (http://compcert.inria.fr/download.html): install opam (http://opam.ocaml.org/); type opam install menhir; opam install coq
