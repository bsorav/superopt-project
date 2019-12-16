SHELL := /bin/bash
SUPEROPT_TARS_DIR := ~/tars
all::
	make -C superopt debug
	make -C llvm

ci::
	make ci_install
	make testinit

install::
	make ci_install
	pushd llvm-project; make install; make first; popd

ci_install::
	ln -sfn ${SUPEROPT_TARS_DIR} ./tars
	pushd superopt; ./configure --use-ninja; popd;
	pushd superopt; make solvers; popd;
	cmake --build superopt/build/etfg_i386 --target eq
	cmake --build superopt/build/etfg_i386 --target smt_helper_process
	cmake --build superopt/build/etfg_i386 --target eqgen
	cmake --build superopt/build/i386_i386 --target harvest
	mkdir -p llvm-build
	pushd llvm-build; bash ../llvm/build.sh; popd
	pushd llvm-project; make install && make first && make all; popd

testinit::
	pushd superopt-tests; ./configure && make; popd
	make test

test::
	SUPEROPT_ROOT=${PWD} python superopt/utils/eqbin.py -n superopt-tests/build/bzip2/{bzip2.bc.O0.s,bzip2.clang.eqchecker.O3.i386}
	mkdir -p eqfiles
	mv superopt-tests/build/bzip2/bzip2.bc.O0.s.ALL.etfg eqfiles/bzip2.etfg
	mv superopt-tests/build/bzip2/bzip2.clang.eqchecker.O3.i386.ALL.tfg eqfiles/bzip2.clang.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc.bc.O0.s,tsvc.clang.eqchecker.O3.i386}
	mv superopt-tests/build/tsvc/tsvc.bc.O0.s.ALL.etfg eqfiles/tsvc.etfg
	mv superopt-tests/build/tsvc/tsvc.clang.eqchecker.O3.i386.ALL.tfg eqfiles/tsvc.clang.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc.bc.O0.s,tsvc.gcc.eqchecker.O3.i386}
	mv superopt-tests/build/tsvc/tsvc.gcc.eqchecker.O3.i386.ALL.tfg eqfiles/tsvc.gcc.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc_icc.bc.O0.s,tsvc_icc.icc.eqchecker.O3.i386}
	mv superopt-tests/build/tsvc/tsvc_icc.icc.eqchecker.O3.i386.ALL.tfg eqfiles/tsvc.icc.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/semalign/{semalign_ex_src.bc.O0.s,semalign_ex_dst.gcc.eqchecker.O3.i386}
	mv superopt-tests/build/semalign/semalign_ex_src.bc.O0.s.ALL.etfg eqfiles/semalign_ex.etfg
	mv superopt-tests/build/semalign/semalign_ex_dst.gcc.eqchecker.O3.i386.ALL.tfg eqfiles/semalign_ex.gcc.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/semalign/{semalign_ex_src.bc.O0.s,semalign_ex_dst.clang.eqchecker.O3.i386}
	mv superopt-tests/build/semalign/semalign_ex_src.bc.O0.s.ALL.etfg eqfiles/semalign_ex.etfg
	mv superopt-tests/build/semalign/semalign_ex_dst.clang.eqchecker.O3.i386.ALL.tfg eqfiles/semalign_ex.clang.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/semalign/{semalign_ex_src.bc.O0.s,semalign_ex_dst.icc.eqchecker.O3.i386}
	mv superopt-tests/build/semalign/semalign_ex_src.bc.O0.s.ALL.etfg eqfiles/semalign_ex.etfg
	mv superopt-tests/build/semalign/semalign_ex_dst.icc.eqchecker.O3.i386.ALL.tfg eqfiles/semalign_ex.icc.eqchecker.O3.tfg
	make -C eqtest

eqtest::
	pushd superopt-tests/bzip2/scripts; bash run_all.sh; popd
	pushd superopt-tests/tsvc/scripts; bash run_all.sh; popd
	pushd superopt-tests/semalign/scripts; bash run_all.sh; popd

.PHONY: all test
