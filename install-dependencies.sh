#!/bin/bash
# installs dependency pacakges

if [[ "$EUID" -ne 0 ]];
then
  echo "Please run as root"
  exit
fi

build="cmake flex bison unzip ninja-build"
llvm="llvm llvm-dev clang-9 clang++-9"
libs="libboost-all-dev libiberty-dev binutils-dev zlib1g-dev libgmp-dev libelf-dev libmagic-dev libssl-dev libswitch-perl ocaml-nox lib32stdc++-8-dev"
yices="gperf libgmp3-dev autoconf"
superopt="expect rpcbind"
db="ruby ruby-dev gem freetds-dev"
fbgen="camlidl"

GCC=gcc-8
tests="libc6-dev-i386 gcc-8-multilib g++-8-multilib linux-libc-dev:i386 parallel"
compcert="menhir ocaml-libs"
suggested="cscope exuberant-ctags atool"

apt-get install $build $llvm $libs $yices $superopt $db $fbgen $tests

#following is for eqbin.py script
pip install python-magic

#following is for db
gem install tiny_tds

#for installing compcert (http://compcert.inria.fr/download.html): install opam (http://opam.ocaml.org/); type opam install menhir; opam install coq
