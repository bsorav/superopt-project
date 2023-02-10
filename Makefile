export SUPEROPT_PROJECT_DIR ?= $(PWD)
export SUPEROPT_INSTALL_DIR ?= $(SUPEROPT_PROJECT_DIR)/usr/local
SUPEROPT_INSTALL_FILES_DIR ?= $(SUPEROPT_INSTALL_DIR)
SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_DIR)/build
SUDO = # sudo not available to students

SHELL := /bin/bash -O failglob
export SUPEROPT_TARS_DIR ?= $(SUPEROPT_PROJECT_DIR)/tars
#Z3=z3-4.8.10
Z3=z3-4.8.14
#Z3_PKGNAME=$(Z3)-x64-ubuntu-18.04
Z3_PKGNAME=$(Z3)-x64-glibc-2.31
#Z3_PATH=$(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3/$(Z3_PKGNAME)
Z3_DIR=$(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3
Z3_BINPATH=$(Z3_DIR)/${Z3_PKGNAME}
#Z3_LIB_PATH=$(Z3_PATH)/bin
Z3_LIB_PATH=$(Z3_BINPATH)/bin

Z3v487=z3-4.8.7
Z3v487_DIR=$(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3v487
Z3v487_BINPATH=$(Z3v487_DIR)/usr

.PHONY: all
all: install

.PHONY: build
build: tars
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superoptdbs

.PHONY: clean
clean:
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt clean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project clean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superoptdbs clean

.PHONY: distclean
distclean:
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt distclean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project distclean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superoptdbs distclean

.PHONY: install
install: build
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR) cleaninstall
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR) linkinstall

.PHONY: linkinstall
linkinstall::
	$(SUDO) mkdir -p $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) mkdir -p $(SUPEROPT_INSTALL_DIR)/include
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-link $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-dis $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-as $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/opt $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llc $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/ld $(SUPEROPT_INSTALL_DIR)/bin/qcc-ld
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/as $(SUPEROPT_INSTALL_DIR)/bin/qcc-as
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_INSTALL_DIR)/bin/eq32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_INSTALL_DIR)/bin/eqgen32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/qcc-codegen $(SUPEROPT_INSTALL_DIR)/bin/qcc-codegen32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/codegen $(SUPEROPT_INSTALL_DIR)/bin/codegen32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/debug_gen $(SUPEROPT_INSTALL_DIR)/bin/debug_gen32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/ctypecheck $(SUPEROPT_INSTALL_DIR)/bin/ctypecheck32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_INSTALL_DIR)/bin/harvest32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/smt_helper_process $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/qd_helper_process $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/eq $(SUPEROPT_INSTALL_DIR)/bin/eq
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/eqgen $(SUPEROPT_INSTALL_DIR)/bin/eqgen
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/qcc-codegen $(SUPEROPT_INSTALL_DIR)/bin/qcc-codegen
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/codegen $(SUPEROPT_INSTALL_DIR)/bin/codegen
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/debug_gen $(SUPEROPT_INSTALL_DIR)/bin/debug_gen
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/x64_x64/harvest $(SUPEROPT_INSTALL_DIR)/bin/harvest
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/ctypecheck $(SUPEROPT_INSTALL_DIR)/bin/ctypecheck
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm2tfg $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang $(SUPEROPT_INSTALL_DIR)/bin/clang-qcc
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang $(SUPEROPT_INSTALL_DIR)/bin/clang
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang++ $(SUPEROPT_INSTALL_DIR)/bin/clang++
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/harvest-dwarf $(SUPEROPT_INSTALL_DIR)/bin/harvest-dwarf
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_INSTALL_DIR)
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libLockstepDbg.a $(SUPEROPT_INSTALL_DIR)/lib/libLockstepDbg32.a
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/libLockstepDbg.a $(SUPEROPT_INSTALL_DIR)/lib/libLockstepDbg.a
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libmymalloc.a $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_INSTALL_DIR)
	$(SUDO) ln -sf $(Z3_BINPATH)/bin/z3 $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(Z3_LIB_PATH)/libz3.so* $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) ln -sf $(Z3_BINPATH)/include/z3_*.h $(SUPEROPT_INSTALL_DIR)/include
	$(SUDO) ln -sf $(Z3v487_BINPATH)/bin/z3 $(SUPEROPT_INSTALL_DIR)/bin/z3v487
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_INSTALL_DIR)/bin
	#$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/boolector $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/build/qcc $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/build/ooelala $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/build/clang12 $(SUPEROPT_INSTALL_DIR)/bin

.PHONY: cleaninstall
cleaninstall::
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-link
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-dis
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-as
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/opt
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llc
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc-ld
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc-as
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/eq
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/eqgen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc-codegen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/codegen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/debug_gen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/smt_helper_process
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qd_helper_process
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/lib/libLockstepDbg.a
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/lib/libmymalloc.a
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/harvest
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm2tfg
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang-qcc
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang++
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/harvest-dwarf
	#$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/harvest-dwarf32
	$(SUDO) rm -rf $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) rm -rf $(SUPEROPT_INSTALL_DIR)/superoptdbs
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/yices_smt2
	#$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/boolector
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/cvc4

.PHONY: printpaths
printpaths:
	@echo "SUPEROPT_PROJECT_DIR = $(SUPEROPT_PROJECT_DIR)"
	@echo "SUPEROPT_INSTALL_DIR = $(SUPEROPT_INSTALL_DIR)"
	@echo "SUPEROPT_INSTALL_FILES_DIR = $(SUPEROPT_INSTALL_FILES_DIR)"
	@echo "SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_BUILD)"
	@echo "SUPEROPT_TARS_DIR = $(SUPEROPT_TARS_DIR)"
	@echo "ICC = $(ICC)"
