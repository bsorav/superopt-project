#!/bin/bash
# installs dependency pacakges

# strict mode
set -euo pipefail

if [[ "$EUID" -ne 0 ]];
then
  echo "Please run as root"
  exit
fi

GCC_VERSION=11
LLVM_VERSION=12
build="make cmake flex bison unzip ninja-build python3 python3-pip git"
llvm="llvm-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev clang-${LLVM_VERSION} lld-${LLVM_VERSION}"
libs="gcc-multilib g++-multilib libiberty-dev binutils-dev zlib1g-dev libgmp-dev libelf-dev libmagic-dev libssl-dev libswitch-perl ocaml-nox lib32stdc++-11-dev"
yices="gperf libgmp3-dev autoconf"
superopt="expect libtirpc-dev libtirpc3 libtirpc-common rpcbind libyaml-cpp-dev"
tests="g++-${GCC_VERSION} libc6-dev-i386 gcc-${GCC_VERSION}-multilib g++-${GCC_VERSION}-multilib linux-libc-dev:i386 parallel"
vscode_extension="libsecret-1-dev"
scanview="python python-dev"

apt-get install -y $build $llvm $libs $yices $superopt $tests $vscode_extension #$scanview

# optional
system="sudo vim zsh htop iotop net-tools ssh cscope exuberant-ctags"
docs="retext"
apt-get install -y $system $docs

# optional
db="ruby ruby-dev gem freetds-dev"
fbgen="camlidl"
compcert="menhir ocaml-libs"
compiler_explorer="python3-distutils gcc g++"
suggested="atool emacs"
# apt-get install -y $fbgen $compcert $compiler_explorer $suggested $db 

#following is for db
#command -v gem && gem install tiny_tds || true

#for installing compcert (http://compcert.inria.fr/download.html): install opam (http://opam.ocaml.org/); type opam install menhir; opam install coq

#following is for eqbin.py script
#pip install --proxy=$http_proxy python-magic
