#!/bin/bash
# installs dependency pacakges

# strict mode
set -euo pipefail

if [[ "$EUID" -ne 0 ]];
then
  echo "Please run as root"
  exit
fi

build="make cmake flex bison unzip ninja-build python3 python3-pip git"
llvm="llvm-11 llvm-11-dev clang-11 lld-11"
libs="gcc-multilib g++-multilib libiberty-dev binutils-dev zlib1g-dev libgmp-dev libelf-dev libmagic-dev libssl-dev libswitch-perl ocaml-nox lib32stdc++-8-dev"
yices="gperf libgmp3-dev autoconf"
superopt="expect libtirpc-dev libtirpc3 libtirpc-common rpcbind libyaml-cpp0.6 libyaml-cpp-dev"
tests="g++-8 libc6-dev-i386 gcc-8-multilib g++-8-multilib linux-libc-dev:i386 parallel"
system="sudo"

apt-get install -y $build $llvm $libs $yices $superopt $tests $system

# optional
db="ruby ruby-dev gem freetds-dev"
fbgen="camlidl"
compcert="menhir ocaml-libs"
compiler_explorer="python3-distutils gcc g++"
suggested="cscope exuberant-ctags atool emacs"
# apt-get install -y $fbgen $compcert $compiler_explorer $suggested $db 

#following is for db
command -v gem && gem install tiny_tds || true

#for installing compcert (http://compcert.inria.fr/download.html): install opam (http://opam.ocaml.org/); type opam install menhir; opam install coq

#following is for eqbin.py script
#pip install --proxy=$http_proxy python-magic
