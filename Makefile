export SUPEROPT_PROJECT_DIR ?= $(PWD)
export SUPEROPT_INSTALL_DIR ?= $(SUPEROPT_PROJECT_DIR)/usr/local
SUPEROPT_INSTALL_FILES_DIR ?= $(SUPEROPT_INSTALL_DIR)
SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_DIR)/build
SUDO ?= 

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
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/binlibs
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project install
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superoptdbs
	cd $(SUPEROPT_PROJECT_DIR)/superopt-tests && ./configure

.PHONY: install
install: build
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR) cleaninstall
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR) linkinstall
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR) install_icc_bins

.PHONY: install_icc_bins
install_icc_bins: icc_bins.tgz
	mkdir -p $(SUPEROPT_PROJECT_DIR)/superopt-tests/build/localmem-tests
	tar xmvf $(SUPEROPT_PROJECT_DIR)/icc_bins.tgz -C $(SUPEROPT_PROJECT_DIR)/superopt-tests/build/localmem-tests

.PHONY: clean
clean:
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/binlibs clean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt clean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project clean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superoptdbs clean

.PHONY: distclean
distclean:
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/binlibs clean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt distclean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/llvm-project distclean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superoptdbs distclean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/superopt-tests distclean
	$(MAKE) -C $(SUPEROPT_PROJECT_DIR)/tars distclean
	git clean -df
	rm -rf $(SUPEROPT_INSTALL_DIR)

.PHONY: linkinstall
linkinstall:
	$(SUDO) mkdir -p $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) mkdir -p $(SUPEROPT_INSTALL_DIR)/include
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-link $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-dis $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm-as $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/opt $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llc $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eq $(SUPEROPT_INSTALL_DIR)/bin/eq32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/eqgen $(SUPEROPT_INSTALL_DIR)/bin/eqgen32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/i386_i386/harvest $(SUPEROPT_INSTALL_DIR)/bin/harvest32
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/vir_gen $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/smt_helper_process $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/etfg_i386/qd_helper_process $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/llvm2tfg $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang $(SUPEROPT_INSTALL_DIR)/bin/clang
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/clang++ $(SUPEROPT_INSTALL_DIR)/bin/clang++
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/share $(SUPEROPT_INSTALL_DIR)
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/scan-build $(SUPEROPT_INSTALL_DIR)/bin/scan-build
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/scan-view $(SUPEROPT_INSTALL_DIR)/bin/scan-view
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/bin/harvest-dwarf $(SUPEROPT_INSTALL_DIR)/bin/harvest-dwarf
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/llvm-project/build/lib $(SUPEROPT_INSTALL_DIR)
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superoptdbs $(SUPEROPT_INSTALL_DIR)
	$(SUDO) ln -sf $(Z3_BINPATH)/bin/z3 $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(Z3_LIB_PATH)/libz3.so* $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) ln -sf $(Z3_BINPATH)/include/z3_*.h $(SUPEROPT_INSTALL_DIR)/include
	$(SUDO) ln -sf $(Z3v487_BINPATH)/bin/z3 $(SUPEROPT_INSTALL_DIR)/bin/z3v487
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/yices_smt2 $(SUPEROPT_INSTALL_DIR)/bin
	$(SUDO) ln -sf $(SUPEROPT_PROJECT_DIR)/superopt/build/third_party/cvc4 $(SUPEROPT_INSTALL_DIR)/bin

.PHONY: cleaninstall
cleaninstall:
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-link
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-dis
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm-as
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/opt
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llc
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/eq
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/eqgen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/vir_gen
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/smt_helper_process
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/qd_helper_process
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/harvest
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/llvm2tfg
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/clang++
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/harvest-dwarf
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/yices_smt2
	$(SUDO) rm -f $(SUPEROPT_INSTALL_DIR)/bin/cvc4
	$(SUDO) rm -rf $(SUPEROPT_INSTALL_DIR)/lib
	$(SUDO) rm -rf $(SUPEROPT_INSTALL_DIR)/superoptdbs

.PHONY: printpaths
printpaths:
	@echo "SUPEROPT_PROJECT_DIR = $(SUPEROPT_PROJECT_DIR)"
	@echo "SUPEROPT_INSTALL_DIR = $(SUPEROPT_INSTALL_DIR)"
	@echo "SUPEROPT_INSTALL_FILES_DIR = $(SUPEROPT_INSTALL_FILES_DIR)"
	@echo "SUPEROPT_PROJECT_BUILD = $(SUPEROPT_PROJECT_BUILD)"
	@echo "SUPEROPT_TARS_DIR = $(SUPEROPT_TARS_DIR)"
	@echo "ICC_INSTALL_DIR = $(ICC_INSTALL_DIR)"

.PHONY: oopsla24_results lt_results tsvc_results bzip2_results demo_results
oopsla24_results lt_results tsvc_results bzip2_results demo_results:
	$(MAKE) -C superopt-tests $@

.PHONY: gen_bzip2_tables
gen_bzip2_tables:
	python3 bzip2_tables.py -d superopt-tests

.PHONY: gen_demo_tables
gen_demo_tables:
	python3 gen_tables.py superopt-tests/demo_gcc.csv    -o tab_demo_gcc.csv
	python3 gen_tables.py superopt-tests/demo_clang.csv  -o tab_demo_clang.csv

.PHONY: gen_graphs
gen_graphs:
	MPLBACKEND=pdf python3 plot_grouped_bars.py -s -d superopt-tests

.PHONY: docker-build
docker-build:
	docker build -t eqchecker .

.PHONY: docker-run
docker-run:
	docker run --name artifact-container -it eqchecker:latest /bin/zsh

.PHONY: docker-shell
docker-shell:
	docker exec -it artifact-container /bin/bash
