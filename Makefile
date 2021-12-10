include Make.conf

export SUPEROPT_PROJECT_DIR ?= $(PWD)
export SUPEROPT_INSTALL_DIR ?= $(SUPEROPT_PROJECT_DIR)/usr/local
SUPEROPT_INSTALL_FILES_DIR ?= $(SUPEROPT_INSTALL_DIR)
SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_DIR)/build
# PARALLEL_LOAD_PERCENT ?= 100  # parallel will start new jobs until number of processes fall below this value

SHELL := /bin/bash
export SUPEROPT_TARS_DIR ?= $(SUPEROPT_PROJECT_DIR)/tars

all: install

build:
	# unzip dbs
	$(MAKE) -C superoptdbs
	# build superopt
	pushd superopt && ./configure --use-ninja && popd;
	$(MAKE) -C superopt solvers
	cmake --build superopt/build/etfg_i386 --target eq
	cmake --build superopt/build/etfg_i386 --target smt_helper_process
	cmake --build superopt/build/etfg_i386 --target eqgen
	cmake --build superopt/build/etfg_i386 --target debug_gen
	cmake --build superopt/build/i386_i386 --target harvest
	cmake --build superopt/build/etfg_x64 --target eq
	cmake --build superopt/build/etfg_x64 --target smt_helper_process
	# build our llvm fork and custom llvm-based libs and utils
	pushd llvm-project && $(MAKE) install && $(MAKE) all && popd

linkinstall:
	mkdir -p $(SUPEROPT_INSTALL_DIR)/bin
	mkdir -p $(SUPEROPT_INSTALL_DIR)/include
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-link $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-dis $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-as $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/opt $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llc $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/ld $(SUPEROPT_INSTALL_DIR)/bin/qcc-ld
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/as $(SUPEROPT_INSTALL_DIR)/bin/qcc-as
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_INSTALL_DIR)/bin/eq32
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_INSTALL_DIR)/bin/eqgen32
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/debug_gen $(SUPEROPT_INSTALL_DIR)/bin/debug_gen32
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_INSTALL_DIR)/bin/harvest32
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/smt_helper_process $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/eq $(SUPEROPT_INSTALL_DIR)/bin/eq
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/eqgen $(SUPEROPT_INSTALL_DIR)/bin/eqgen
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/debug_gen $(SUPEROPT_INSTALL_DIR)/bin/debug_gen
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/x64_x64/harvest $(SUPEROPT_INSTALL_DIR)/bin/harvest
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/ctypecheck $(SUPEROPT_INSTALL_DIR)/bin/ctypecheck
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm2tfg $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang $(SUPEROPT_INSTALL_DIR)/bin/clang
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/harvest-dwarf $(SUPEROPT_INSTALL_DIR)/bin/harvest-dwarf
	ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_INSTALL_DIR)
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libmymalloc.a $(SUPEROPT_INSTALL_DIR)/lib
	ln -sf $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_INSTALL_DIR)
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3/usr/bin/z3 $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3/usr/lib/libz3.so* $(SUPEROPT_INSTALL_DIR)/lib
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3/usr/include/z3_*.h $(SUPEROPT_INSTALL_DIR)/include
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_INSTALL_DIR)/bin
	ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_INSTALL_DIR)/bin

cleaninstall::
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-link
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-dis
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-as
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/opt
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/llc
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc-ld
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc-as
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/eq
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/eqgen
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc-codegen
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/codegen
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/debug_gen
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/smt_helper_process
	rm -f $(SUPEROPT_INSTALL_DIR)/lib/libLockstepDbg.a
	rm -f $(SUPEROPT_INSTALL_DIR)/lib/libmymalloc.a
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/harvest
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm2tfg
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang-qcc
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/harvest-dwarf
	rm -rf $(SUPEROPT_INSTALL_DIR)/lib
	rm -rf $(SUPEROPT_INSTALL_DIR)/superoptdbs
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/yices_smt2
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/boolector
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/cvc4
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/ooelala
	rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang12

install::
	$(MAKE) build
	$(MAKE) linkinstall
	pushd superopt-tests && ./configure && $(MAKE) && popd

run::
	$(MAKE) -C superopt-tests eqtest_i386

run_paper_ex:
	$(MAKE) -C superopt-tests run_paper_ex

printpaths:
	@echo "SUPEROPT_PROJECT_DIR = $(SUPEROPT_PROJECT_DIR)"
	@echo "SUPEROPT_INSTALL_DIR = $(SUPEROPT_INSTALL_DIR)"
	@echo "SUPEROPT_INSTALL_FILES_DIR = $(SUPEROPT_INSTALL_FILES_DIR)"
	@echo "SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_BUILD)"
	@echo "SUPEROPT_TARS_DIR = $(SUPEROPT_TARS_DIR)"
	@echo "ICC = $(ICC)"

.PHONY: all build linkinstall cleaninstall install run run_paper_ex printpaths
