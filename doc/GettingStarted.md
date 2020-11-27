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

## Comparing two different C programs
One way to compare two C programs is to convert one of them to assembly before comparing them.

### Convert `b.c` to `b.s`
First setup the environment variables for generating the command line options of GCC
```
$ export GCC_NO_INLINING_FLAGS="-fno-inline -fno-inline-functions -fno-inline-small-functions -fno-indirect-inlining -fno-partial-inlining -fno-inline-functions-called-once -fno-early-inlining"
$ export GCC_NO_IPA_FLAGS="-fno-whole-program -fno-ipa-sra -fno-ipa-cp"
$ export GCC_NO_SEC_FLAGS="-fcf-protection=none -fno-stack-protector -fno-stack-clash-protection"
$ export DEFINES="-Dalloca=myalloca -D_FORTIFY_SOURCE=0 -D__noreturn__=__no_reorder__"
$ export NO_BUILTINS="-fno-builtin-printf -fno-builtin-malloc -fno-builtin-abort -fno-builtin-exit -fno-builtin-fscanf -fno-builtin-abs -fno-builtin-acos -fno-builtin-asin -fno-builtin-atan2 -fno-builtin-atan -fno-builtin-calloc -fno-builtin-ceil -fno-builtin-cosh -fno-builtin-cos -fno-builtin-exit -fno-builtin-exp -fno-builtin-fabs -fno-builtin-floor -fno-builtin-fmod -fno-builtin-fprintf -fno-builtin-fputs -fno-builtin-frexp -fno-builtin-fscanf -fno-builtin-isalnum -fno-builtin-isalpha -fno-builtin-iscntrl -fno-builtin-isdigit -fno-builtin-isgraph -fno-builtin-islower -fno-builtin-isprint -fno-builtin-ispunct -fno-builtin-isspace -fno-builtin-isupper -fno-builtin-isxdigit -fno-builtin-tolower -fno-builtin-toupper -fno-builtin-labs -fno-builtin-ldexp -fno-builtin-log10 -fno-builtin-log -fno-builtin-malloc -fno-builtin-memchr -fno-builtin-memcmp -fno-builtin-memcpy -fno-builtin-memset -fno-builtin-modf -fno-builtin-pow -fno-builtin-printf -fno-builtin-putchar -fno-builtin-puts -fno-builtin-scanf -fno-builtin-sinh -fno-builtin-sin -fno-builtin-snprintf -fno-builtin-sprintf -fno-builtin-sqrt -fno-builtin-sscanf -fno-builtin-strcat -fno-builtin-strchr -fno-builtin-strcmp -fno-builtin-strcpy -fno-builtin-strcspn -fno-builtin-strlen -fno-builtin-strncat -fno-builtin-strncmp -fno-builtin-strncpy -fno-builtin-strpbrk -fno-builtin-strrchr -fno-builtin-strspn -fno-builtin-strstr -fno-builtin-tanh -fno-builtin-tan -fno-builtin-vfprintf -fno-builtin-vsprintf -fno-builtin"
$ export GCC_EQCHECKER_FLAGS="-g -no-pie -fno-pie -fno-strict-overflow -fno-unit-at-a-time -fno-strict-aliasing -fno-optimize-sibling-calls -fkeep-inline-functions -fwrapv -std=c11 -fno-reorder-blocks -fno-jump-tables -fno-zero-initialized-in-bss -fno-caller-saves $GCC_NO_INLINING_FLAGS $GCC_NO_IPA_FLAGS $GCC_NO_SEC_FLAGS $DEFINES $NO_BUILTINS"
$ gcc -m32 -S -g -Wl,--emit-relocs -fdata-sections $GCC_EQCHECKER_FLAGS -O3 b.c -o b.s
```
Then generate the assembly code using the following command -- in this example we use the `O3` optimization to generate `b.s`; you can also use `O0` or any other optimization that you prefer.
```
$ gcc -m32 -S -g -Wl,--emit-relocs -fdata-sections $GCC_EQCHECKER_FLAGS -O3 b.c -o b.s
```
Finally, run the equivalence checker `eq32` (for 32-bit x86) for a chosen unroll factor.
```
$ eq32 --unroll-factor=8 a.c b.s
```
