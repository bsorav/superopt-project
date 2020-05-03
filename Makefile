include Make.conf

export SUPEROPT_PROJECT_DIR ?= $(PWD)
SUPEROPT_INSTALL_DIR ?= $(SUPEROPT_PROJECT_DIR)/usr/local
SUPEROPT_INSTALL_FILES_DIR ?= $(SUPEROPT_INSTALL_DIR)
SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_DIR)/build
SUDO ?= sudo # sudo is not available in CI

SHELL := /bin/bash
export SUPEROPT_TARS_DIR ?= ~/tars
Z3=z3-4.8.7

MAJOR_VERSION=0
MINOR_VERSION=1
PACKAGE_REVISION=0
PACKAGE_NAME=qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)

all:: $(SUPEROPT_PROJECT_BUILD)/qcc
	make -C superopt debug
	make -C llvm-project
	make -C superoptdbs

$(SUPEROPT_PROJECT_BUILD)/qcc: Make.conf Makefile
	mkdir -p $(SUPEROPT_PROJECT_BUILD)
	echo "$(SUPEROPT_INSTALL_DIR)/bin/clang-qcc $(CLANG_I386_EQCHECKER_FLAGS)" '$$*' > $@
	chmod +x $@

linkinstall::
	$(SUDO) mkdir -p $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) mkdir -p $(SUPEROPT_INSTALL_DIR)/include
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-link $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-as $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/opt $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llc $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/ld $(SUPEROPT_INSTALL_DIR)/bin/qcc-ld
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/qcc-codegen $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/codegen $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/debug_gen $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/smt_helper_process $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libLockstepDbg.a $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libmymalloc.a $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm2tfg $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang-8 $(SUPEROPT_INSTALL_DIR)/bin/clang-qcc
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_INSTALL_DIR)
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_INSTALL_DIR)
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3/usr/bin/z3 $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3/usr/lib/libz3.so $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3/usr/include/z3_*.h $(SUPEROPT_INSTALL_DIR)/include
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/build/qcc $(SUPEROPT_INSTALL_DIR)/bin

cleaninstall::
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-link
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-as
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/opt
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llc
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc-ld
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/eq
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/eqgen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc-codegen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/codegen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/debug_gen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/smt_helper_process
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/lib/libLockstepDbg.a
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/lib/libmymalloc.a
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/harvest
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm2tfg
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang-qcc
	$(SUDO) rm -rf $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) rm -rf $(SUPEROPT_INSTALL_DIR)/superoptdbs
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/yices_smt2
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/cvc4
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc
	rm -f $(SUPEROPT_PROJECT_BUILD)/qcc

release::
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/bin
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/lib
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/superoptdbs/etfg_i386
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/superoptdbs/i386_i386
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-link $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm-link
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-as $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm-as
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/opt $(SUPEROPT_INSTALL_FILES_DIR)/bin/opt
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llc $(SUPEROPT_INSTALL_FILES_DIR)/bin/llc
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/ld $(SUPEROPT_INSTALL_FILES_DIR)/bin/qcc-ld
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_INSTALL_FILES_DIR)/bin/eq
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_INSTALL_FILES_DIR)/bin/eqgen
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/qcc-codegen $(SUPEROPT_INSTALL_FILES_DIR)/bin/qcc-codegen
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/codegen $(SUPEROPT_INSTALL_FILES_DIR)/bin/codegen
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/debug_gen $(SUPEROPT_INSTALL_FILES_DIR)/bin/debug_gen
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/smt_helper_process $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libLockstepDbg.a $(SUPEROPT_INSTALL_FILES_DIR)/lib
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libmymalloc.a $(SUPEROPT_INSTALL_FILES_DIR)/lib
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_INSTALL_FILES_DIR)/bin/harvest
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm2tfg $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm2tfg
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang-8 $(SUPEROPT_INSTALL_FILES_DIR)/bin/clang-qcc
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_INSTALL_FILES_DIR)/
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_INSTALL_FILES_DIR)
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -lrtv $(SUPEROPT_PROJECT_DIR)/build/qcc $(SUPEROPT_INSTALL_FILES_DIR)/bin
	cd /tmp && tar xf $(SUPEROPT_TARS_DIR)/$(Z3)-x86_64.pkg.tar.xz && rsync -lrtv usr/ $(SUPEROPT_INSTALL_FILES_DIR) && cd -
	$(SUDO) rsync -lrtv $(SUPEROPT_INSTALL_FILES_DIR)/* $(SUPEROPT_INSTALL_DIR)

ci::
	make ci_install
	make ci_test

build::
	# unzip dbs
	make -C superoptdbs
	# build superopt
	pushd superopt && ./configure --use-ninja && popd;
	make -C superopt solvers
	cmake --build superopt/build/etfg_i386 --target eq
	cmake --build superopt/build/etfg_i386 --target smt_helper_process
	cmake --build superopt/build/etfg_i386 --target eqgen
	cmake --build superopt/build/etfg_i386 --target qcc-codegen
	cmake --build superopt/build/etfg_i386 --target codegen
	cmake --build superopt/build/etfg_i386 --target debug_gen
	cmake --build superopt/build/i386_i386 --target harvest
	# build our llvm fork and custom llvm-based libs and utils
	pushd llvm-project && make install && make all && popd
	# build qcc
	make $(SUPEROPT_PROJECT_BUILD)/qcc

ci_install::
	make build
	make release

ci_test::
	make testinit
	make gentest
	make eqtest

# multiple steps for jenkins pipeline view
testinit::
	pushd superopt-tests && ./configure && (make clean; true) && make && popd

gentest::
	make -C superopt-tests gentest

eqtest::
	make -C superopt-tests runtest

oopsla_test::
	$(MAKE) gen_oopsla_test
	$(MAKE) eq_oopsla_test

gen_oopsla_test::
	$(MAKE) -C superopt-tests gen_oopsla_test

eq_oopsla_test::
	$(MAKE) -C superopt-tests run_oopsla_test

typecheck_test::
	make -C superopt-tests typecheck_test

codegen_test::
	make -C superopt-tests codegen_test

install::
	make build
	make linkinstall

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
		dpkg-deb --build $(PACKAGE_NAME);\
		echo "$(PACKAGE_NAME) created successfully. Use 'sudo apt install $(PACKAGE_NAME).deb' to install";\
	else\
		echo "Rebuild with SUPEROPT_INSTALL_DIR=/usr/local to create a debian package";\
	fi

printpaths:
	@echo "SUPEROPT_PROJECT_DIR = $(SUPEROPT_PROJECT_DIR)"
	@echo "SUPEROPT_INSTALL_DIR = $(SUPEROPT_INSTALL_DIR)"
	@echo "SUPEROPT_INSTALL_FILES_DIR = $(SUPEROPT_INSTALL_FILES_DIR)"
	@echo "SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_BUILD)"
	@echo "SUPEROPT_TARS_DIR = $(SUPEROPT_TARS_DIR)"
	@echo "ICC = $(ICC)"

pushdebian::
	scp $(PACKAGE_NAME).deb sbansal@xorav.com:

.PHONY: all ci install ci_install testinit gentest eqtest printpaths
