# Getting started

## Clone the repositories
```
$ git clone https://<username>@github.com/bsorav/superopt-project
$ cd superopt-project
$ git checkout perf
$ git submodule init
$ git submodule update -- superopt
$ git submodule update -- superoptdbs
$ git submodule update -- llvm-project
$ git submodule update -- superopt-tests
$ git clone https://<username>@github.com/compilerai/tars
```

## Install the latest version of cmake
```
$ sudo apt-get update
$ sudo apt-get install apt-transport-https ca-certificates gnupg \
                         software-properties-common wget
$ wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc | sudo apt-key add -
$ sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
$ sudo apt-get update
$ sudo apt-get install cmake
```

## Set up the environment
Ensure that your `http_proxy` environment variable is setup correctly
```
$ sudo -E ./install-dependencies.sh
```

## Build
```
$ make
```
