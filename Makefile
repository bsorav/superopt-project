export SUPEROPT_PROJECT_DIR = $(PWD)
SUPEROPT_INSTALL_DIR ?= $(SUPEROPT_PROJECT_DIR)/usr/local
SUPEROPT_INSTALL_FILES_DIR ?= $(SUPEROPT_INSTALL_DIR)

SHELL := /bin/bash
export SUPEROPT_TARS_DIR ?= ~/tars

MAJOR_VERSION=0
MINOR_VERSION=1
PACKAGE_REVISION=0

all::
	make -C superopt debug
	make -C llvm

release::
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/bin
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/lib
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/superoptdbs/etfg_i386
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/superoptdbs/i386_i386
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm-link $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm-link
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm-as $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm-as
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/opt $(SUPEROPT_INSTALL_FILES_DIR)/bin/opt
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llc $(SUPEROPT_INSTALL_FILES_DIR)/bin/llc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/ld $(SUPEROPT_INSTALL_FILES_DIR)/bin/qcc-ld
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/lib/LLVMSuperopt.so $(SUPEROPT_INSTALL_FILES_DIR)/lib/LLVMSuperopt.so
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_INSTALL_FILES_DIR)/bin/eq
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_INSTALL_FILES_DIR)/bin/eqgen
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/qcc $(SUPEROPT_INSTALL_FILES_DIR)/bin/qcc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/smt_helper_process $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_INSTALL_FILES_DIR)/bin/harvest
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-build/bin/llvm2tfg $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm2tfg
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang-8 $(SUPEROPT_INSTALL_FILES_DIR)/bin/clang-qcc
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_INSTALL_FILES_DIR)
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_INSTALL_FILES_DIR)
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -rtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_INSTALL_FILES_DIR)/bin
	sudo rsync -rtv $(SUPEROPT_INSTALL_FILES_DIR)/* $(SUPEROPT_INSTALL_DIR)
	#echo "Run 'sudo cp -r $(SUPEROPT_INSTALL_FILES_DIR)/* $(SUPEROPT_INSTALL_DIR)' to complete the release\n"

ci::
	make ci_install
	make testinit
	make gentest
	make eqtest

ci_install::
	# build superopt
	pushd superopt && ./configure --use-ninja && popd;
	make -C superopt solvers
	cmake --build superopt/build/etfg_i386 --target eq
	cmake --build superopt/build/etfg_i386 --target smt_helper_process
	cmake --build superopt/build/etfg_i386 --target eqgen
	cmake --build superopt/build/i386_i386 --target harvest
	# build llvm2tfg
	mkdir -p llvm-build
	pushd llvm-build && bash ../llvm/build.sh && popd
	# build our llvm fork
	pushd llvm-project && make install && make first && make all && popd

# multiple steps for jenkins pipeline view
testinit::
	pushd superopt-tests && ./configure && (make clean; true) && make && popd

gentest::
	make -C superopt-tests gentest

eqtest::
	make -C superopt-tests runtest

install::
	make ci_install

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

.PHONY: all ci install ci_install testinit gentest eqtest
