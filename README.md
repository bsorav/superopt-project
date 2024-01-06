---
title: Modeling Local Variables for Translation Validation
geometry: margin=2cm
---

# Getting started {#getting-started}

## Recommended machine configuration {#machine-config}

The recommended machine for running this artifact would have at least:

 * 8 physical CPUs
 * 32 GiB of RAM
 * 120 GiB disk space
 * Internet connection

## Setup {#setup}

The artifact is packaged as a Docker application.  Installation of Docker is covered [here](https://docs.docker.com/engine/install/).
Follow these steps for building and installing Dynamo:

1. [Install Docker Engine](https://docs.docker.com/engine/install/) and set it up.
2. Go to the top-level directory of the artifact and build the Docker image.  Note that internet connectivity is required in this step.
   
     ```
     make docker-build
     ```
   This process can take a while depending upon your internet connection bandwidth.  
3. Run a container with the built image.
     
     ```
     make docker-run
     ```
4. (Inside the container) Build and install the artifact:
     
     ```
     make
     ```
     
Dynamo is now ready for use.  Different `make` targets are provided for reproducing the individual results of the paper.  For example, use `make bzip2_results && make gen_bzip2_tables` for reproducing the [bzip2 experiment](#bzip2) results (table 4 of the paper).  Other targets are discussed in a [later section](#running-instructions).

We will refer to the default directory of the container, `/home/eqcheck/artifact`, as the 'top-level directory' in subsequent sections.

## Running Dynamo on the example C function {#run-example}

1. To test the setup, you may run Dynamo on the example C function shown in Fig 1 of the paper.
2. The C source code for the example is present at path: `superopt-tests/demo/sample.c`.
3. Execute `make demo_results` (in top-level directory) to run this unit test.
4. The command will perform the following actions in sequence:
    1. Compile the C code to generate (unoptimized) ${\tt LLVM}_d$ IR and optimized x86 assemblies using GCC and Clang/LLVM.
    2. Pass the ${\tt LLVM}_d$ IR and assembly pair to Dynamo for refinement (equivalence) check.
    3. Display the result of each invocation -- a `passed`/`FAILED` status.
    4. Generate files containing the summary of each run.
5. The appearance of messages as shown below would confirm a successful run:
   ```
   build/demo/eqcheck.sample.gcc.eqchecker.O3.i386.s/sample-sample.gcc.eqchecker.O3.i386.ALL.
   log passed
   build/demo/eqcheck.sample.clang.eqchecker.O3.i386.s/sample-sample.clang.eqchecker.O3.i386.
   ALL.log passed
   ```

6. The run summary files (in `superopt-tests/` directory) can be transformed to user-friendly CSV files (with similar headers as table 4) by running `make gen_demo_tables` which will generate `tab_demo_gcc.csv` and `tab_demo_clang.csv`.
7. The whole procedure should take around 15 minutes on the recommended machine configuration.

Instructions for interpreting the generated CSV files are discussed in a [later section](#howto-csv)

# Step-by-Step instructions for running the benchmarks {#running-instructions}

The following subsections assume that the [setup](#setup) is complete and Dynamo is built, installed, and ready for use.

## Reproducing Fig 8 results {#graphs-gen}

To reproduce the results and graphs in figure 8 of the paper, run the following sequence of commands in the top-level directory:

```
make lt_results tsvc_results      # execute the benchmarks (in parallel) and collect run summaries
make gen_graphs                   # generate the graphs from collected run summaries
```

Dynamo is executed twice for each function in the benchmark suites [`localmem-tests`](#localmem) and [`TSVC_prior_work_locals`](#tsvc), always using the "slower" non-full interval encoding in the second run.

It takes around 75 hours to finish both set of benchmarks in a non-parallel (single CPU) run.

The graphs are generated in the same directory and can be copied to the host from the container using the following commands:

```
docker cp artifact-container:/home/eqcheck/artifact/graph_lt.pdf .
docker cp artifact-container:/home/eqcheck/artifact/graph_tsvc.pdf .
```

Note that the runtimes are sensitive to the counter-examples returned by the SMT solvers and may be vary (in rare cases, extremely) under certain circumstances.

**Generating Table 4 like table for fig 8 benchmarks**

After executing the benchmarks, run `make gen_lt_tables` and `make gen_tsvc_tables` for generating table 4 like table for benchmarks in figure 8 of the paper (see [this section](#howto-csv) for explanation of the CSV file).

The names of the generated files are printed by the above commands and correspond to run configuration as shown below.

* `tab_lt_<compiler>.csv`: [`localmem-tests`](#localmem) run for compiler `<compiler>`.  Example: `tab_lt_clang.csv` for the Clang/LLVM run.
* `tab_lt_<compiler>_s.csv`: [`localmem-tests`](#localmem) run for compiler `<compiler>` with forced non-full interval encoding ("slow" encoding).
* `tab_tsvc_g.csv`: [`TSVC_prior_work_globals`](#tsvc) run
* `tab_tsvc_l.csv`: [`TSVC_prior_work_locals`](#tsvc) run
* `tab_tsvc_l_s.csv`: [`TSVC_prior_work_locals`](#tsvc) run with forced non-full interval encoding ("slow" encoding)

### Absence of Intel C Compiler (ICC)

The Intel C Compiler (ICC) is not packaged with this artifact, instead pre-compiled binaries are provided (see `icc_bins.tgz` file).  These binaries are automatically copied to appropriate paths during the build process and the final results include the data from ICC runs.

**Building ICC binaries (instead of using the provided ones)**

It is possible to use an installed `icc` for building the binaries though it requires multiple steps.  The following changes are required:

1. Install `icc` inside the container -- build the container and install `icc` before building and installing Dynamo.
2. Disable extraction of `icc_bins.tgz` in top-level `Makefile`: Comment line 36:
   ```
   $(MAKE) -C $(SUPEROPT_PROJECT_DIR) install_icc_bins
   ```

3. Export `ICC_INSTALL_DIR` environment variable (put it in `.bashrc`/`.zshrc` or similar place) which locates path of ICC installation (the default is usually `/opt/intel/oneapi/compiler/latest/linux`) .  The `icc` binary is then assumed to be located at `${ICC_INSTALL_DIR}/bin/intel64/icc`.  Note that the experiments reported in the paper used version `2021.8.0`.

4. Update timestamp of the C sources so that a rebuild is triggered:
   ```
   touch /home/eqcheck/artifact/superopt-test/localmem-tests/*.c
   ```
5. Run `make lt_results`
   * All binaries will be re-generated including ICC ones.
   * An error should only happen if the path `ICC_INSTALL_DIR` is not correct or `icc` is not configured properly for building 32-bit binaries.

## Reproducing Table 4 results {#bzip2-tab-gen}

To reproduce the [`bzip2`](#bzip2) results and table 4 of the paper, run the following sequence of commands in the top-level directory:

```
make bzip2_results          # execute the benchmarks (in parallel) and collect run summaries
make gen_bzip2_tables       # generate the data for table 4 as a CSV file
```

It takes around 80 hours to finish the benchmarks in a non-parallel (single CPU) run.

The output is produced in the form of a CSV file named `tab_bzip2_short.csv` in the same directory.  The CSV file structure is explained in the following section.

### Description of the CSV file {#howto-csv}

The CSV file shares same headers as table 4 in the paper and contains summary for a single benchmark,compiler pair.  The headers are explained below.

1. `name`: The name of the C function.
2. `passing`: boolean indicating success of the equivalence check.
3. `ALOC`: assembly lines of code corresponding to the C function.
4. `# of locals`: number of `alloc` instructions in the ${\tt LLVM}_d$ input.
5. `eqT`: Time taken by Dynamo for computing equivalence.
6. `Nodes`: Number of nodes in the product graph.
7. `Edges`: Number of edges in the product graph.
8. `EXP`: Product graphs explored by the best-first search.
9. `BT`: Number of backtrackings in the best-first search.
10. `# of q`: Number of SMT queries made by Dynamo during the equivalence check.
11. `Avg. qT`: Avg. time taken (in seconds) by the SMT solvers in discharging a query.
12. `Frac_q^i`: Fraction of total SMT queries which used full interval encoding.

It is important to note the final numbers may differ slightly from the paper numbers due to counter-example driven nature of the algorithm.  However, the difference is expected to be small.

## Running Dynamo on custom code {#run-custom-code}

Dynamo can be made to run on custom code by editing the `sample.c` file in `superopt-tests/demo`.
The following steps describe how to achieve it.

1. Edit `sample.c` to add the C code.
2. Run `make demo_results` in top-level directory.
   * `sample.c` will be compiled to x86 assembly using GCC and Clang/LLVM at `O3` optimization level to generate assembly files.
     * Compilation is triggered only if the C source is _newer_ than the assembly file or the assembly file is missing.
   * The assembly files are generated in `superopt-tests/build/demo` directory with names:
     * `sample.gcc.eqchecker.O3.i386.s`
     * `sample.clang.eqchecker.O3.i386.s`
   * The `O3` part in name represents the optimization level. At `O1` optimization level, the file names will have `O1` in place of `O3`.  Similarly for `O2`.
3. Run `make gen_demo_tables` in top-level directory to get run summary.
   * The format of the generated CSV files (`tab_demo_gcc.csv` and `tab_demo_clang.csv`) is explained in [previous section](#howto-csv).

The result of the run will appear in the form of output messages

```
build/demo/eqcheck.sample.gcc.eqchecker.O3.i386.s/sample-sample.gcc.eqchecker.O3.i386.ALL.log
<passed/FAILED>
build/demo/eqcheck.sample.clang.eqchecker.O3.i386.s/sample-sample.clang.eqchecker.O3.i386.ALL.log
<passed/FAILED>
```

A "passed" output will indicate a successful run.
Detailed passing status for each function can be seen in the CSV file.

> Note that due to availability of untrusted compiler-hints for Clang/LLVM compilations, results for Clang/LLVM equivalence checks are expected to be better (than GCC) in most cases.

### Inspecting and editing the generated assembly {#asm}

As mentioned in previous section, the assembly files are created inside the `superopt-tests/build/demo` directory with names reflecting the optimization level.
These files can be inspected and edited and Dynamo can be made to run on the edited files.

The following steps describe the process:

1. [Generating the `.s` files] If required, run `make demo_results` to generate the assembly files.
2. [Editing] The files are generated at paths `superopt-tests/build/demo/sample.gcc.eqchecker.O3.i386.s` and `superopt-tests/build/demo/sample.clang.eqchecker.O3.i386.s` and can be inspected and edited using a text editor. Example: using the installed `vim` editor:

    ```
    vim superopt-tests/build/demo/sample.gcc.eqchecker.O3.i386.s
    ```
3. [Re-running with edited assembly] Run `make demo_results` to run Dynamo on the edited assembly.
    *  If the source C file is edited/modified then running `make demo_results` will overwrite the edited assembly file.
    * Avoid modifying the C source file while editing the assembly file.

### Running with different optimization level {#optlevel}

To select a different optimization level, edit line 21 of `superopt-tests/demo/Makefile`:

```
cmds_normal_run: eqtest_i386_O3
```

Change `O3` to desired optimization level (out of `O1`, `O2`, `O3`).  For example, to select `O1`, change `eqtest_i386_O3` to `eqtest_i386_O1`:

```
cmds_normal_run: eqtest_i386_O1
```

Use `make demo_results` to build and run again.

### Running with different unroll factor {#unroll}

To select a different unroll factor level, edit lines 10 and 12 of `superopt-tests/demo/Makefile`:

```
UNROLL4_GCC := $(PROGS)

UNROLL4_CLANG := $(PROGS)
```

Change `4` to desired unroll factor.  For example, to select `8`, change `UNROLL4_GCC` and `UNROLL4_CLANG` to `UNROLL8_GCC` and `UNROLL8_CLANG` respectively:

```
UNROLL8_GCC := $(PROGS)

UNROLL8_CLANG := $(PROGS)

```

Use `make demo_results` to build and run again.

### Running with forced non-full interval encoding {#slow-encoding}

To additionally run the benchmark with forced non-full interval encoding (partial interval or array encoding), make the following changes in the `demo/Makefile` file:

1. Delete `#` from line 27: `cmds: cmds_normal_run # cmds_slow_run`
2. Delete first `#` from line 31: `collect_csv: csv_eqcheck_normal_gcc_O3 csv_eqcheck_normal_clang_O3 # csv_eqcheck_slow_gcc_O3 ...`
3. Delete `#` from lines 35, 36: `# mv csv_eqcheck_slow_...`
4. Use `make demo_results` to build and run again.

## Benchmarks and directory structure {#path-info}

### Source code of the benchmarks

The benchmarks are present in the `superopt-tests` directory.
Three benchmark suites are available:

 * local allocation programming patterns benchmarks (`localmem-tests`)
 * vectorization benchmarks (`TSVC_prior_work_globals` and `TSVC_prior_work_locals`)
 * bzip2 (`bzip2_locals`)

#### Local allocation programming patterns benchmark suite {#localmem}

 - The `localmem-tests` directory contains the 18 benchmarks
   - 17 of them are from table 3 of the paper and contain one C function each.
   - 1 new benchmark, `vilN`, is included to address scalability questions raised by the reviewers.
     - This benchmarks contains 4 functions: `vil1`, `vil2`, `vil3`, `vil4`
 - The benchmarks are compiled using three compilers -- GCC, Clang/LLVM, and ICC -- at O3 optimization level with vectorization disabled through compiler flags and pragma(s).

#### Vectorization benchmark suite {#tsvc}

 - Two versions of the TSVC suite of vectorization benchmarks are present:
   - 'globals' version where all arrays are preallocated global variables.
   - 'locals' version  where the arrays are allocated as local variables.
 - The `TSVC_prior_work_globals` directory contains the 'globals' version
 - The `TSVC_prior_work_locals` directory contains the 'locals' version
 - Each version contains 23 C functions.
 - The benchmarks are compiled using Clang/LLVM compiler at O3 optimization level with vectorization enabled using `-msse4.2` compiler flag.

#### bzip2 benchmark {#bzip2}

  - The `bzip2_locals` directory contains the `bzip2.c` file.
  - In the provided default configuration, it contains 72 C functions.
  - The benchmark is compiled using Clang/LLVM compiler in 3 configurations: `O1-` which is essentially `O1` with some optimizations disabled (see the paper for details), `O1`, and `O2`.

### Input, Output and intermediate files

The input files to Dynamo viz. unoptimized LLVM IR and optimized assembly code generated by the compiler are created inside a benchmark specific 'run' directory and can be inspected after finishing the equivalence check.

For source file `<SRC>` of benchmark suite `<BMC>`, compiled using compiler `<COMP>` and optimization level `<OPT>`, the location of its 'run' directory is given by:
  
  ```
  superopt-test/build/<BMC>/eqcheck.<SRC>.<COMP>.eqchecker.<OPT>.i386.s
  ```

> An exception to this are benchmarks compiled using `O1-` flag in which case the 'run' directory is: `superopt-tests/build/<BMC>/clangv.<SRC>.O1-`

For example, for [`localmem-tests`](#localmem) benchmark `as` compiled using `GCC` at `O3`, the 'run' directory is

  ```
  superopt-test/build/localmem-tests/eqcheck.as.gcc.eqchecker.O3.i386.s
  ```

The 'run' directory of a benchmark is organized as follows:

 - `prepare` directory contains a copy the input C source (`*.c`) and the compiled object (`*.o`) files.
 - `pointsto` directory contain the graph representation of the C source (`*.etfg`).
 - `submit.<function_name>` directory contains the graph representation of the assembly program (`*.tfg`), the run log (`stdout`) and, if found, the proof file (`eq.proof`).

The format of the graph representation files (`*.etfg` and `*.tfg`) and proof file (`eq.proof`) is discussed in [next section](#howto-interp)


# Interpreting the input and output files {#howto-interp}

## Interpreting the graph representation (`.tfg` and `.etfg`) files {#howto-interp-tfg}

The `.tfg` and `.etfg` files contain the serialized representation of the transition graph of a function.
Both files are composed of similar building blocks and have a hierarchical structure.  _Headers_ in the files are prefixed by `=`.  For example, `=Node`, `=Edge` etc.

Important headers (in order as they appear) are explained as follows.

1. `=FunctionName`: Identifies name of the C function.
2. `=TFG`: Beginning of the control flow graph of the C function previously identified by `=FunctionName`.
3. `=Nodes`: List of PCs (program points/locations) in this graph.
    1. The PC identifier is encoded as a 3-tuple: `<part0>%<part1>%<part2>`.
    2. Start PC is `L0%0%d` and exit PC is `E0%0%d`.
4. `=Edges:` List of edges in this graph -- an edge is characterized by a pair of from,to-PCs.
5. `=Input`: List of formal arguments of the C function.  Each argument gets a separate `=Input` header.
6. `=Output`: Return values of the function.  Includes:
    1. The return value/register (if the return type is non-void)
    2. Heap memory
    3. Globals modified by this function
    4. The return address
7. `=Symbol-map`: A list of global C symbols (include global objects) that appear in the C file of the function.  Contains additional information such as name (as it appears in LLVM's symbol map), size, alignment and "constness" (0 == non-const, 1 == const) separated by ':'.
8. `=memlabel_map.<numeric_id>`: The points-to analysis associates a potentially points-to set with each memory operation's target address and stores it in a mapping.  This is dump for the same.
9. `=Edge`: A graph edge has the following children fields:
    1. `=Edge.EdgeCond`: The edge condition in _expr_ format (explained below).
    2. `=Edge.StateTo`: Compressed transfer function for this edge: list of mappings from state variable to _expr_.
        1. Has 0 or more _(statevar, expr)_ tuple as children
        2. Each tuple is formatted as: `=<state-variable name>` followed by _expr_ for this state-variable.
    3. `=Edge.Assumes`: List of assumptions associated with the edge: these are the (absence of) UB conditions associated with the transfer function of the edge.  A U error is triggered if any of these assumes is falsified.
       * For example, the no-multiplication-overflow condition associated with `alloc` is represented as:

         ```
         =EdgeAssume.0
         1 : input.src.llvm-%add : BV:32
         2 : 32 { 0x20 +1.0e1025 } : INT
         3 : bvsign_ext(1, 2) : BV:64
         4 : 4 { 0x4 +1.47e129 } : BV:32
         5 : bvzero_ext(4, 2) : BV:64
         6 : bvmul(3, 5) : BV:64
         7 : 63 { 0x3f +1.0e1025 } : INT
         8 : bvextract(6, 7, 2) : BV:32
         9 : 0 { 0x0 +1.0e129 } : BV:32
         10 : eq(8, 9) : BOOL
         ```
       * Here, a multiplication of `input.src.llvm-%add` by `4` is being asserted to not overflow.
        
10. `=Locs`: _Locs_ are set of state variables which are considered for the points-to analysis, invariant inference and other analyses.  This includes LLVM variables, x86 registers, and memory elements whose address is a known (symbolic or numeric) constant and memories (segmented into heap, global variables, locals, and stack).  Locs are associated with a unique numeric identifier.
11. `=Liveness`: Result of liveness-analysis.  Lists locs (represented with locid) live at each PC.
12. `=TFGdone`: TFG end string.

### Structures of common fields {#common-fields}

1. Expression or _expr_: A well-formed expression involving state variables, constants, and operators is represented as a DAGs.  The format is:
    
    ```
    <expr_id> : <op> : <type>
    ```
    where `<op>` can be a state element or an SMT-like operator referencing other expressions using `<expr_id>`s.  E.g. `bvadd(123, input.src.llvm-%0)` is represented as:

    ```
    1 : 123 : BV:32
    2 : input.src.llvm-%0 : BV:32
    3 : bvadd(1, 2) : BV:32
    ```

2. Predicate or _pred_: A predicate encodes `(lhs == rhs)` in the following structure:
    
    ```
    =Comment
    <string>
    =LhsExpr
    <expr>
    =RhsExpr
    <expr>
    =predicate done
    ```
    For example, the following predicate asserts that state variables `input.src.llvm-%1` and `input.dst.exreg.0.5` have same value.
    
    ```
    =Comment
    linear2-32
    =LhsExpr
    1 : input.src.llvm-%1 : BV:32
    =RhsExpr
    1 : input.dst.exreg.0.5 : BV:32
    =predicate done
    ```
4. Pathset representation or the serial-parallel digraph (SP-graph):  The SP-graph is defined recursively as:
    1. epsilon (empty edge)      `(epsilon)`
    2. Singular edge             `<from_pc> => <to_pc>`
    3. A parallel combination    `( <sp_graph> + <sp_graph> )`
    4. A serial combination      `( <sp_graph> * <sp_graph> )`

## Interpreting the output product graph (`eq.proof`) file {#howto-intrep-proof}

The `eq.proof` utilizes similar structure (heading style) and building blocks as a `.tfg` file.
It contains the serialized representation of the product graph.

* A product graph node is a pair of input graphs' nodes.
* A product graph edge is a pair of input graphs' pathsets (set of simple paths).
* Each product graph node has a set of inductive invariants which are provable at that node.

Important bits (in the order as they appear) are:

1. `=FunctionName`: Name of the corresponding C function.
2. `=result`: Will be 1 if equivalence check succeeded.
3. `=corr_graph`: Beginning of dump of the product graph ("correlation graph").  This is followed by `=src_tfg` (graph for ${\tt LLVM}_d$, $C$) and `=dst_tfg` (graph for x86 assembly, $A$) dumps.:
   * The `=dst_tfg` dump includes the annotated edges for `alloc` and `dealloc`.
4. `=cg_graph`: Beginning of graph structure serialization of the product graph.
5. `=Nodes`: List of product graph PC identifiers.  Formatted as `<C_pc_id>_<A_pc_id>`.
6. `=Edges`: List of product graph edges.
7. `=Edge` list: Each entry in the list describes a product graph edge.  Constituent pathsets from C and A are listed under `=Edge.src_tfg_full_pathset` and `=Edge.dst_tfg_full_pathset` respectively.
8. `=Invariant state at node` list: Each entry in the list describes set of invariants at corresponding node (PC) of the product graph.  The interesting part is the list of predicates where beginnig of each predicate is identified by a line containing `pred <num>`:
    1. The predicate is structured as explained in previous section.
    2. An example of a predicate which asserts that the heaps are equal at PC `Lfor.body%1%d_L26%1%bbentry` follows
       ```
       =pc Lfor.body%1%d_L26%1%bbentry inductive-invariants smallest_point_cover 1 type arr pred 0
       =Comment
       guess--memeq-memlabel-mem-may-straddle-symbol.1-heap
       =LhsExpr
       1 : input.src.llvm-mem.Lfor.cond%1%bbentry : ARRAY[BV:32 -> BV:8]
       2 : input.src.llvm-mem.alloc.Lif.end3%1%bbentry : ARRAY[BV:32 -> MEMLABEL]
       3 : input.dst.mem.L26%1%bbentry : ARRAY[BV:32 -> BV:8]
       4 : input.dst.mem.alloc.L24%1%bbentry : ARRAY[BV:32 -> MEMLABEL]
       5 : memlabel-mem-may-straddle-symbol.1-heap : MEMLABEL
       6 : memmasks_are_equal(1, 2, 3, 4, 5) : BOOL
       =RhsExpr
       1 : 1 { 0x1 } : BOOL
       =predicate done
       ```
    3. The operator `memmasks_are_equal` is similar to $\Pi_{\overrightarrow{i}}(M_{P_1}, M_{P_2})$ operator in the paper and returns `true` iff the first and third memory operands agree on addresses identified by region label in fifth operand using the allocation state arrays in second and fourth operand respectively.
    4. In this particular example, the memory arrays `input.src.llvm-mem.Lfor.cond%1%bbentry` (the ${\tt LLVM}_d$ memory array) and `input.dst.mem.L26%1%bbentry` (the x86 memory array) are asserted to be equal in the heap memory region `memlabel-mem-may-straddle-symbol.1-heap` (the `memlabel-mem-may-straddle-symbol.1` part is not relevant here and may be safety ignored) where the addresses corresponding to heap memory region are identified using allocation state arrays `input.src.llvm-mem.alloc.Lif.end3%1%bbentry` and `input.dst.mem.alloc.L24%1%bbentry` respectively.
9. `=well-formedness-conditions for <edge>` list: Each entry in the list describes a well-formedness condition that must be satisfied by the associated product graph edge.  A well-formedness condition is represented by a tuple of src-path component, dst-path component, and a predicate: (`src_pathset`,`dst_pathset`,`pred`):
   1. The `src_pathset` is the src ($C$) path component of the product graph edge that must be traversed before evaluating the predicate.
   2. The `dst_pathset` is the dst ($A$) path component of the product graph edge that must be traversed before evaluating the predicate.
   3. The `pred` is the predicate that must evaluate to true after executing the corresponding path components from the from PC of the product graph edge.
   4. An example of a well-formedness condition predicate which asserts that at function call edge `esp` must be aligned by 16 is given below.
   
      ```
      =well-formedness-conditions for Llor.lhs.false%1%fcallStart_L12%1%fcallStart=>Llor.lhs.
      false%1%fcallEnd_L12%1%fcallEnd edge-wf-cond src_path
      =well-formedness-conditions for Llor.lhs.false%1%fcallStart_L12%1%fcallStart=>Llor.lhs.
      false%1%fcallEnd_L12%1%fcallEnd edge-wf-cond src_path.graph_edge_composition
      (epsilon)
      =well-formedness-conditions for Llor.lhs.false%1%fcallStart_L12%1%fcallStart=>Llor.lhs.
      false%1%fcallEnd_L12%1%fcallEnd edge-wf-cond dst_path
      =well-formedness-conditions for Llor.lhs.false%1%fcallStart_L12%1%fcallStart=>Llor.lhs.
      false%1%fcallEnd_L12%1%fcallEnd edge-wf-cond dst_path.graph_edge_composition
      (epsilon)
      =well-formedness-conditions for Llor.lhs.false%1%fcallStart_L12%1%fcallStart=>Llor.lhs.
      false%1%fcallEnd_L12%1%fcallEnd edge-wf-cond pred.0
      =Comment
      wfcond.from_pcLlor.lhs.false%1%fcallStart_L12%1%fcallStart.to_pcLlor.lhs.false%1%fcallE
      nd_L12%1%fcallEnd-fcall-sp-is-aligned
      =LhsExpr
      1 : input.dst.exreg.0.4.L11%2%d : BV:32
      2 : 16 { 0x10 +1.0e1025 } : INT
      3 : islangaligned(1, 2) : BOOL
      =RhsExpr
      1 : 1 { 0x1 } : BOOL
      =predicate done
      ```
   5. Here, `(epsilon)` represents an empty path, `input.dst.exreg.0.4.L11%2%d` represents the `esp` register, and `islangaligned` is a predicate which holds iff the first operand is at least aligned by the (integral) value of the second operand.
   6. Note that both `src_pathset` and `dst_pathset` components are empty paths in this case.

# Archived results {#archived-files}

We have included archived results in the `archived-results` directory.

* The `eq.proof` files for all benchmarks are present in the archive `eq.proof.tar.xz`.
* The graphs from figure 8 and table 4 are present in `figs_and_tabs.tar.xz`.
  * The files generated by `make gen_bzip2_tables` (`tab_bzip2_short.csv` and `tab_bzip2_full.tex`) can be matched against the provided files in `figs_and_tabs.tar.xz`.
* The run summary files are present in `run_summaries.tar.xz`.  These can be matched against files generated by a run in `superopt-tests/` directory.
