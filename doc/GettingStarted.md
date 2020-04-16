# Getting started

```
$ sudo ./install-dependencies.sh
$ update-alternatives --set c++ /usr/bin/clang++
$ make -C superopt debug
$ make linkinstall
$ make -C llvm-project install
$ make -C llvm-project
$ make -C superoptdbs
$ make
$ make ci_test
```
