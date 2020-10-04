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
$ cd superopt-project
$ sudo -E ./install-dependencies.sh
```

## Build
```
$ make
```

## Environment variables
Set your environment variables as follows (you may want to do this in your bashrc/zshrc files so they remain initialized in all your future sessions)
```
export SUPEROPT_PROJECT_DIR=/path/to/superopt-project
export SUPEROPT_INSTALL_DIR=$SUPEROPT_PROJECT_DIR/usr/local
export SUPEROPT_TARS_DIR=$SUPEROPT_PROJECT_DIR/tars
```
You also need to update your `PATH` environment variable:
```
export PATH=$PATH:$SUPEROPT_INSTALL_DIR/bin
```

## Running the tests
```
$ cd superopt-project/superopt-tests
$ make eqtest_i386
```
Some of these tests are expected to pass while some may fail currently.

## Running a particular test and observing its operation in detail
First you need to copy the relevant files to your current working directory. We show this for the `s000` TSVC benchmark.

Copy the C source code file.
```
$ cp superopt-project/superopt-tests/TSVC_prior_work/s000.c a.c
```
Copy the 32-bit x86 assembly code file.
```
$ cp superopt-project/superopt-tests/build/TSVC_prior_work/s000.gcc.eqchecker.O0.i386.s a.s
```
Run the equivalence checker `eq32` (for 32-bit x86) for a chosen unroll factor.
```
$ eq32 --unroll-factor=8 a.c a.s
```
This command prints some messages (with &lt;MSG&gt; tag) on the standard output. Also, it prints the
final result of the equivalence checker.  For some benchmarks, this command may exceed the running
time limit (time out).  If the equivalence check succeeds (pass result), the computed proof is
emitted into the `eq.proof.ALL` file.
