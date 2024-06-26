export SUPEROPT_PROJECT_DIR ?= $(CURDIR)
export SUPEROPT_INSTALL_DIR ?= $(SUPEROPT_PROJECT_DIR)/usr/local
SUPEROPT_INSTALL_FILES_DIR ?= $(SUPEROPT_INSTALL_DIR)
SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_DIR)/build
SUDO ?= #sudo # sudo is not available in CI

SHELL := /bin/bash -O failglob
export SUPEROPT_TARS_DIR ?= $(SUPEROPT_PROJECT_DIR)/tars

Z3=z3-4.8.14
Z3_PKGNAME=$(Z3)-x64-glibc-2.31
Z3_DIR=$(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3
Z3_BINPATH=$(Z3_DIR)/${Z3_PKGNAME}
Z3_LIB_PATH=$(Z3_BINPATH)/bin

Z3v487=z3-4.8.7
Z3v487_DIR=$(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/z3v487
Z3v487_BINPATH=$(Z3v487_DIR)/usr

.PHONY: all
all: install

.PHONY: build
build: $(SUPEROPT_TARS_DIR)
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project install
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superoptdbs
	cd $(SUPEROPT_PROJECT_DIR)/superopt-tests && ./configure # && make && cd -
	# build qcc, ooelala, clang12
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR) $(SUPEROPT_PROJECT_DIR)/build/qcc $(SUPEROPT_PROJECT_DIR)/build/ooelala $(SUPEROPT_PROJECT_DIR)/build/clang12

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
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt-tests distclean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/tars distclean
	if [ -d "$(SUPEROPT_PROJECT_DIR)/vscode-extension" ]; then $(MAKE) -C $(SUPEROPT_PROJECT_DIR)/vscode-extension distclean; fi
	git clean -df
	rm -rf $(SUPEROPT_INSTALL_DIR)

.PHONY: install
install: build
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR) cleaninstall
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR) linkinstall

$(SUPEROPT_PROJECT_BUILD)/qcc: Makefile
	mkdir -p $(SUPEROPT_PROJECT_BUILD)
	echo "$(SUPEROPT_INSTALL_DIR)/bin/clang-qcc $(CLANG_I386_EQCHECKER_FLAGS)" '$$*' > $@
	chmod +x $@

$(SUPEROPT_PROJECT_BUILD)/ooelala: Makefile
	mkdir -p $(SUPEROPT_PROJECT_BUILD)
	echo "$(SUPEROPT_INSTALL_DIR)/bin/clang --dyn_debug=disableSemanticAA -Xclang -load -Xclang $(SUPEROPT_INSTALL_DIR)/lib/UnsequencedAliasVisitor.so -Xclang -add-plugin -Xclang unseq " '$$*' > $@
	chmod +x $@

$(SUPEROPT_PROJECT_BUILD)/clang12: Makefile
	mkdir -p $(SUPEROPT_PROJECT_BUILD)
	echo "$(SUPEROPT_INSTALL_DIR)/bin/clang --dyn_debug=disableSemanticAA " '$$*' > $@
	chmod +x $@

.PHONY: docker-build
docker-build:
	docker build -t eqchecker .

.PHONY: docker-run
docker-run:
	docker run -p 80:80 -p 2222:22 -p 8181:8181 -it eqchecker:latest /bin/zsh

.PHONY: tarball
tarball:
	cd .. && tar --exclude-vcs -cjf superopt-project.tbz2 superopt-project && cd -

.PHONY: linkinstall
linkinstall:
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
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/vir_gen $(SUPEROPT_INSTALL_DIR)/bin
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
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/share $(SUPEROPT_INSTALL_DIR)
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/scan-build $(SUPEROPT_INSTALL_DIR)/bin/scan-build
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/scan-view $(SUPEROPT_INSTALL_DIR)/bin/scan-view
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
cleaninstall:
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
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/vir_gen
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
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qcc
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/ooelala
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang12

.PHONY: release
release:
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/bin
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/lib
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/superoptdbs/etfg_i386
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/superoptdbs/i386_i386
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/superoptdbs/etfg_x64
	mkdir -p $(SUPEROPT_INSTALL_FILES_DIR)/superoptdbs/i386_x64
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-link $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm-link
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-dis $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm-dis
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-as $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm-as
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/opt $(SUPEROPT_INSTALL_FILES_DIR)/bin/opt
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llc $(SUPEROPT_INSTALL_FILES_DIR)/bin/llc
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/ld $(SUPEROPT_INSTALL_FILES_DIR)/bin/qcc-ld
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/binutils-2.21-install/bin/as $(SUPEROPT_INSTALL_FILES_DIR)/bin/qcc-as
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_INSTALL_FILES_DIR)/bin/eq32
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_INSTALL_FILES_DIR)/bin/eqgen32
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/qcc-codegen $(SUPEROPT_INSTALL_FILES_DIR)/bin/qcc-codegen32
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/codegen $(SUPEROPT_INSTALL_FILES_DIR)/bin/codegen32
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/debug_gen $(SUPEROPT_INSTALL_FILES_DIR)/bin/debug_gen32
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/ctypecheck $(SUPEROPT_INSTALL_FILES_DIR)/bin/ctypecheck32
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/eq $(SUPEROPT_INSTALL_FILES_DIR)/bin/eq
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/eqgen $(SUPEROPT_INSTALL_FILES_DIR)/bin/eqgen
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/qcc-codegen $(SUPEROPT_INSTALL_FILES_DIR)/bin/qcc-codegen
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/codegen $(SUPEROPT_INSTALL_FILES_DIR)/bin/codegen
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/debug_gen $(SUPEROPT_INSTALL_FILES_DIR)/bin/debug_gen
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/ctypecheck $(SUPEROPT_INSTALL_FILES_DIR)/bin/ctypecheck
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libLockstepDbg.a $(SUPEROPT_INSTALL_FILES_DIR)/lib/libLockstepDbg32.a
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/libLockstepDbg.a $(SUPEROPT_INSTALL_FILES_DIR)/lib/libLockstepDbg.a
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/libmymalloc.a $(SUPEROPT_INSTALL_FILES_DIR)/lib
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_INSTALL_FILES_DIR)/bin/harvest32
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/vir_gen $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/smt_helper_process $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_x64/qd_helper_process $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/x64_x64/harvest $(SUPEROPT_INSTALL_FILES_DIR)/bin/harvest
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm2tfg $(SUPEROPT_INSTALL_FILES_DIR)/bin/llvm2tfg
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang $(SUPEROPT_INSTALL_FILES_DIR)/bin/clang-qcc
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang $(SUPEROPT_INSTALL_FILES_DIR)/bin/clang
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang++ $(SUPEROPT_INSTALL_FILES_DIR)/bin/clang++
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/harvest-dwarf $(SUPEROPT_INSTALL_FILES_DIR)/bin/harvest-dwarf
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_INSTALL_FILES_DIR)/
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_INSTALL_FILES_DIR)
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/build/qcc $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/build/ooelala $(SUPEROPT_INSTALL_FILES_DIR)/bin
	rsync -Lrtv $(SUPEROPT_PROJECT_DIR)/build/clang12 $(SUPEROPT_INSTALL_FILES_DIR)/bin
	cd /tmp && tar xf $(SUPEROPT_TARS_DIR)/$(Z3_PKGNAME).zip && rsync -Lrtv usr/ $(SUPEROPT_INSTALL_FILES_DIR) && cd -
	$(SUDO) rsync -Lrtv $(SUPEROPT_INSTALL_FILES_DIR)/* $(SUPEROPT_INSTALL_DIR)

add_compilerai_server_user::
	sudo $(SUPEROPT_PROJECT_DIR)/compiler.ai-scripts/add-user-script.sh compilerai-server compiler.ai123

install_compilerai_server::
	sudo bash compiler.ai-scripts/afterInstall.sh

start_compilerai_server::
	sudo bash compiler.ai-scripts/startApp.sh

stop_compilerai_server::
	sudo bash compiler.ai-scripts/stopApp.sh

compiler_explorer_preload_files:: # called from afterInstall.sh
	mkdir -p compiler.ai-scripts/compiler-explorer/lib/storage/data/eqcheck_preload
	cp superopt-tests/build/TSVC_prior_work/*.xml superopt-tests/build/TSVC_new/*.xml compiler.ai-scripts/compiler-explorer/lib/storage/data/eqcheck_preload

MAJOR_VERSION=0
MINOR_VERSION=1
PACKAGE_REVISION=0
PACKAGE_NAME=qcc_$(MAJOR_VERSION).$(MINOR_VERSION)-$(PACKAGE_REVISION)

.PHONY: debian
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

.PHONY: pushdebian
pushdebian::
	scp $(PACKAGE_NAME).deb sbansal@xorav.com:

.PHONY: printpaths
printpaths:
	@echo "SUPEROPT_PROJECT_DIR = $(SUPEROPT_PROJECT_DIR)"
	@echo "SUPEROPT_INSTALL_DIR = $(SUPEROPT_INSTALL_DIR)"
	@echo "SUPEROPT_INSTALL_FILES_DIR = $(SUPEROPT_INSTALL_FILES_DIR)"
	@echo "SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_BUILD)"
	@echo "SUPEROPT_TARS_DIR = $(SUPEROPT_TARS_DIR)"
	@echo "ICC = $(ICC)"
