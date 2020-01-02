SUPEROPT_PROJECT_DIR = $(PWD)

SHELL := /bin/bash
export SUPEROPT_TARS_DIR ?= ~/tars
export SUPEROPT_ROOT := $(SUPEROPT_PROJECT_DIR)

MAJOR_VERSION=0
MINOR_VERSION=1
PACKAGE_REVISION=0

all::
	make -C superopt debug
	make -C llvm

release::
	mkdir -p $(SUPEROPT_PROJECT_DIR)/usr/local/bin
	mkdir -p $(SUPEROPT_PROJECT_DIR)/usr/local/lib
	mkdir -p $(SUPEROPT_PROJECT_DIR)/usr/local/superoptdbs/etfg_i386
	mkdir -p $(SUPEROPT_PROJECT_DIR)/usr/local/superoptdbs/i386_i386
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm-link $(SUPEROPT_PROJECT_DIR)/usr/local/bin/llvm-link
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm-as $(SUPEROPT_PROJECT_DIR)/usr/local/bin/llvm-as
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/opt $(SUPEROPT_PROJECT_DIR)/usr/local/bin/opt
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llc $(SUPEROPT_PROJECT_DIR)/usr/local/bin/llc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/ld $(SUPEROPT_PROJECT_DIR)/usr/local/bin/qcc-ld
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/lib/LLVMSuperopt.so $(SUPEROPT_PROJECT_DIR)/usr/local/lib/LLVMSuperopt.so
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_PROJECT_DIR)/usr/local/bin/eq
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_PROJECT_DIR)/usr/local/bin/eqgen
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/qcc $(SUPEROPT_PROJECT_DIR)/usr/local/bin/qcc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/smt_helper_process $(SUPEROPT_PROJECT_DIR)/usr/local/bin
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_PROJECT_DIR)/usr/local/bin/harvest
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm2tfg $(SUPEROPT_PROJECT_DIR)/usr/local/bin/llvm2tfg
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang-8 $(SUPEROPT_PROJECT_DIR)/usr/local/bin/clang-qcc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_PROJECT_DIR)/usr/local/
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_PROJECT_DIR)/usr/local/
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_PROJECT_DIR)/usr/local/bin
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_PROJECT_DIR)/usr/local/bin

ci::
	make ci_install
	make testinit

install::
	make ci_install
	pushd llvm-project; make install; make first; popd

ci_install::
	# build superopt
	pushd superopt; ./configure --use-ninja; popd;
	pushd superopt; make solvers; popd;
	cmake --build superopt/build/etfg_i386 --target eq
	cmake --build superopt/build/etfg_i386 --target smt_helper_process
	cmake --build superopt/build/etfg_i386 --target eqgen
	cmake --build superopt/build/i386_i386 --target harvest
	# build llvm2tfg
	mkdir -p llvm-build
	pushd llvm-build; bash ../llvm/build.sh; popd
	# build our llvm fork
	pushd llvm-project; make install && make first && make all; popd

testinit::
	pushd superopt-tests; ./configure && make; popd
	make test

test::
	python superopt/utils/eqbin.py -n superopt-tests/build/bzip2/{bzip2.bc.O0.s,bzip2.clang.eqchecker.O3.i386}
	mkdir -p eqfiles
	mv superopt-tests/build/bzip2/bzip2.bc.O0.s.ALL.etfg eqfiles/bzip2.etfg
	mv superopt-tests/build/bzip2/bzip2.clang.eqchecker.O3.i386.ALL.tfg eqfiles/bzip2.clang.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc.bc.O0.s,tsvc.clang.eqchecker.O3.i386}
	mv superopt-tests/build/tsvc/tsvc.bc.O0.s.ALL.etfg eqfiles/tsvc.etfg
	mv superopt-tests/build/tsvc/tsvc.clang.eqchecker.O3.i386.ALL.tfg eqfiles/tsvc.clang.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc.bc.O0.s,tsvc.gcc.eqchecker.O3.i386}
	mv superopt-tests/build/tsvc/tsvc.gcc.eqchecker.O3.i386.ALL.tfg eqfiles/tsvc.gcc.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/tsvc/{tsvc_icc.bc.O0.s,tsvc_icc.icc.eqchecker.O2.i386}
	mv superopt-tests/build/tsvc/tsvc_icc.icc.eqchecker.O2.i386.ALL.tfg eqfiles/tsvc.icc.eqchecker.O2.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/semalign/{semalign_ex_src.bc.O0.s,semalign_ex_dst.gcc.eqchecker.O3.i386}
	mv superopt-tests/build/semalign/semalign_ex_src.bc.O0.s.ALL.etfg eqfiles/semalign_ex.etfg
	mv superopt-tests/build/semalign/semalign_ex_dst.gcc.eqchecker.O3.i386.ALL.tfg eqfiles/semalign_ex.gcc.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/semalign/{semalign_ex_src.bc.O0.s,semalign_ex_dst.clang.eqchecker.O3.i386}
	mv superopt-tests/build/semalign/semalign_ex_src.bc.O0.s.ALL.etfg eqfiles/semalign_ex.etfg
	mv superopt-tests/build/semalign/semalign_ex_dst.clang.eqchecker.O3.i386.ALL.tfg eqfiles/semalign_ex.clang.eqchecker.O3.tfg
	python superopt/utils/eqbin.py -n superopt-tests/build/semalign/{semalign_ex_src.bc.O0.s,semalign_ex_dst.icc.eqchecker.O3.i386}
	mv superopt-tests/build/semalign/semalign_ex_src.bc.O0.s.ALL.etfg eqfiles/semalign_ex.etfg
	mv superopt-tests/build/semalign/semalign_ex_dst.icc.eqchecker.O3.i386.ALL.tfg eqfiles/semalign_ex.icc.eqchecker.O3.tfg
	make eqtest

eqtest::
	pushd superopt-tests/bzip2/scripts; bash run_all.sh; popd
	pushd superopt-tests/tsvc/scripts; bash run_all.sh; popd
	pushd superopt-tests/semalign/scripts; bash run_all.sh; popd

debian::
	rm -rf qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/
	mkdir -p qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/bin
	mkdir -p qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/superopt/build/etfg_i386
	mkdir -p qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/superopt/build/i386_i386
	cp superopt/build/etfg_i386/qcc superopt/build/etfg_i386/eq superopt/build/etfg_i386/eqgen qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/superopt/build/etfg_i386
	strip qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/superopt/build/etfg_i386/qcc
	strip qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/superopt/build/etfg_i386/eq
	strip qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/superopt/build/etfg_i386/eqgen
	cp superopt/build/i386_i386/harvest qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/superopt/build/i386_i386
	strip qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/superopt/build/i386_i386/harvest
	mkdir -p qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/llvm-project/build/bin
	cp llvm-project/build/bin/clang-8 qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/llvm-project/build/bin
	strip qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/llvm-project/build/bin/clang-8
	mkdir -p qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/llvm-build/bin
	cp llvm-build/bin/llvm2tfg qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/llvm-build/bin
	strip qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/llvm-build/bin/llvm2tfg
	ln -s qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/llvm-build/bin/clang-8 qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/superopt-project/llvm-build/bin/clang
	ln -s ../superopt-project/llvm-build/bin/llvm2tfg qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/bin/llvm2tfg
	ln -s ../superopt-project/superopt/build/etfg_i386/qcc qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/bin/qcc
	ln -s ../superopt-project/superopt/build/etfg_i386/eq qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/bin/eq
	ln -s ../superopt-project/superopt/build/etfg_i386/eqgen qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/bin/eqgen
	ln -s ../superopt-project/superopt/build/i386_i386/harvest qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/bin/harvest

.PHONY: all ci install ci_install testinit test eqtest
