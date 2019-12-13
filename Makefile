SHELL := /bin/bash

all::
	make -C superopt debug
	make -C llvm

ci::
	make install
	make testinit

install::
	# XXX ln -s ../tars .
	pushd superopt; ./configure --use-ninja; popd;
	pushd superopt; make solvers; popd;
	cmake --build superopt/build/etfg_i386 --target eq
	cmake --build superopt/build/etfg_i386 --target smt_helper_process
	cmake --build superopt/build/etfg_i386 --target eqgen
	cmake --build superopt/build/i386_i386 --target harvest
	mkdir -p llvm-build
	pushd llvm-build; bash ../llvm/build.sh; popd

testinit::
	pushd superopt-tests; ./configure && make; popd
	make test

test::
	SUPEROPT_ROOT=${PWD} python superopt/utils/eqbin.py -n superopt-tests/build/bzip2/{bzip2.bc.O0.s,bzip2.clang.eqchecker.O3.i386}
	mkdir -p eqfiles
	mv superopt-tests/build/bzip2/bzip2.bc.O0.s.ALL.etfg eqfiles/bzip2.etfg
	mv superopt-tests/build/bzip2/bzip2.clang.eqchecker.O3.i386.ALL.tfg eqfiles/bzip2.clang.eqchecker.O3.tfg
	make -C eqtest

eqtest::
	pushd superopt-tests/bzip2/scripts; bash run_all.sh; popd
	#python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc.bc.O0.s,tsvc.clang.eqchecker.O0.i386}
	#mv superopt-tests/build/tsvc/tsvc.bc.O0.s.ALL.etfg eqfiles/tsvc.etfg
	#mv superopt-tests/build/tsvc/tsvc.clang.eqchecker.O3.i386.ALL.tfg eqfiles/tsvc.clang.eqchecker.O3.tfg
	#python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc.bc.O0.s,tsvc.gcc.eqchecker.O0.i386}
	#mv superopt-tests/build/tsvc/tsvc.clang.eqchecker.O3.i386.ALL.tfg eqfiles/tsvc.gcc.eqchecker.O3.tfg
	#python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc.bc.O0.s,tsvc.icc.eqchecker.O0.i386}
	#mv superopt-tests/build/tsvc/tsvc.clang.eqchecker.O3.i386.ALL.tfg eqfiles/tsvc.icc.eqchecker.O3.tfg
	#pushd superopt-tests/tsvc/scripts; bash run_all.sh; popd

.PHONY: all test
