SUPEROPT_PROJECT_DIR = $(PWD)
SUPEROPT_INSTALL_DIR ?= $(SUPEROPT_PROJECT_DIR)/usr/local
SUPEROPT_INSTALL_FILES_DIR ?= $(SUPEROPT_INSTALL_DIR)

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
	mkdir -p $(SUPEROPT_INSTALL_DIR)/bin
	mkdir -p $(SUPEROPT_INSTALL_DIR)/lib
	mkdir -p $(SUPEROPT_INSTALL_DIR)/superoptdbs/etfg_i386
	mkdir -p $(SUPEROPT_INSTALL_DIR)/superoptdbs/i386_i386
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm-link $(SUPEROPT_INSTALL_DIR)/bin/llvm-link
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm-as $(SUPEROPT_INSTALL_DIR)/bin/llvm-as
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/opt $(SUPEROPT_INSTALL_DIR)/bin/opt
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llc $(SUPEROPT_INSTALL_DIR)/bin/llc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/ld $(SUPEROPT_INSTALL_DIR)/bin/qcc-ld
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/lib/LLVMSuperopt.so $(SUPEROPT_INSTALL_DIR)/lib/LLVMSuperopt.so
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_INSTALL_DIR)/bin/eq
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_INSTALL_DIR)/bin/eqgen
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/qcc $(SUPEROPT_INSTALL_DIR)/bin/qcc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/smt_helper_process $(SUPEROPT_INSTALL_DIR)/bin
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_INSTALL_DIR)/bin/harvest
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm2tfg $(SUPEROPT_INSTALL_DIR)/bin/llvm2tfg
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang-8 $(SUPEROPT_INSTALL_DIR)/bin/clang-qcc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_INSTALL_DIR)
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_INSTALL_DIR)
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_INSTALL_DIR)/bin
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_INSTALL_DIR)/bin

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
	pushd superopt-tests; make clean && ./configure && make; popd
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
	$(info Checking if SUPEROPT_INSTALL_DIR is equal to /usr/local)
	@if [ "$(SUPEROPT_INSTALL_DIR)" = "/usr/local" ]; then\
		echo "yes";\
		rm -rf qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION);\
		mkdir -p qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/DEBIAN;\
		cp DEBIAN.control qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/DEBIAN/control;\
		mkdir -p qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local;\
		cp -r $(SUPEROPT_INSTALL_FILES_DIR)/* qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local;\
		strip qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/bin/*;\
		strip qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)/usr/local/lib/*;\
		dpkg-deb --build qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION);\
	else\
		echo "Rebuild with SUPEROPT_INSTALL_DIR=/usr/local to create a debian package";\
	fi

.PHONY: all ci install ci_install testinit test eqtest
