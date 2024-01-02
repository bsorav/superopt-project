# Dynamo -- Modeling Local Variables for Translation Validation

# Table of contents
1. [Getting started](#getting-started) 
   1. [Ideal machine configuration](#machine-config)
   2. [Setup](#setup)
   3. [Running equivalence checker for an example function](#run-paper-ex)
2. [Step-by-Step instructions for running the benchmarks](#running-instructions)
   1. [Directory Structure](#path-info)
   2. [Reproducing the Table 2 results](#table2-gen)
   3. [Running a particular benchmark category with either Best-First or Depth-First Strategy](#individual-results)
   4. [Reproducing the discovered bug in diet libc library](#run-dietlibc-ex)
   5. [Running equivalence checker on custom code](#run-custom-code)
3. [HOWTO: Interpret the input and output files](#howto-IO)
   1. [Interpreting the input CFG (.tfg and .etfg) files](#howto-interpret-tfg)
   2. [Interpreting the output product-CFG (.proof) file](#howto-interpret-proof)
   3. [Interpreting the output log (.eqlog) file](#howto-interpret-eqlog)
4. [Archived output (.csv) files](#archived-files)

# Getting started <a name="getting-started"></a>

## Ideal machine configuration <a name="machine-config"></a>

An ideal machine for running this artifact would have at least:

 * 8 physical CPUs
 * 32 GiB of RAM
 * 100 GiB disk space
 * Internet connection

## Setup <a name="setup"></a>

The artifact is packaged as a Docker application.  Installation of Docker is covered [here](https://docs.docker.com/engine/install/).
Follow these steps for building and running the equivalence checker based on Dynamo:

1. [Install Docker Engine](https://docs.docker.com/engine/install/) and set it up.  Make sure you are able to run the [hello-world example](https://docs.docker.com/get-started/#test-docker-installation).
2. Go to the top-level directory of the source tree and build the Docker image.  Note that internet connectivity is required in this step.
   ```
   make docker-build
   ```
   This process can take a while depending upon your internet connection bandwidth.  
3. Run a container with the built image.
   ```
   make docker-run
   ```
4. (Inside the container) Build the artifact and install the equivalence checker.
   ```
   make
   ```

Dynamo is now ready for use.  Different `make` targets are provided for reproducing the individual results of the paper.  For example, use `make tableresults` for reproducing the full table 2 results.  Other targets are discussed in [later sections](#running-instructions).

## Running equivalence checker for an example function <a name = "run-paper-ex"></a>

1. To test the above set-up, you may run the equivalence checker on the example function shown in Fig 1 of the paper.
2. The source code for the example is present at path: `superopt-tests/paper_ex`.
   1. The two implementations of function `nestedLoop` in `paper_ex_src.c` and `paper_ex_dst.c` respectively are compared for equivalence.
3. Execute `make run_paper_ex` to run this unit test.
4. After executing this command, the source code will be compiled to generate unoptimized LLVM IR and optimized x86 assembly. Further, the CFGs will be constructed for the unoptimized LLVM IR and the optimized assembly and given as input to equivalence checker.
   1. The `paper_ex_src.c` version is compiled to unoptimized LLVM IR and `paper_ex_dst.c` is compiled to optimized x86 assembly.
5. The equivalence checker using Dynamo will then try to construct a product-CFG that proves bisimulation.
6. The appearance of message `/home/user/artifact/superopt-tests/build/paper_ex/eqlogs/nestedLoop.gcc.BFS.eqlog passed - [5.39]` would confirm a successful run (`5.39` may not match).
   1. There will be other messages as well but they can be safely ignored.
   2. The number in square brackets is the time taken (in seconds) for constructing the product-CFG.  It is 5.39 seconds in the above case.
   3. The `.eqlog` file listed above contains log of this run and other useful information.
7. The whole procedure including step 4 and 5 should take close to 2 minutes.

Instructions for interpreting the results (the `.eqlog` file and `.proof` file) are discussed in a [later section](#howto-IO)


# Step-by-Step instructions for running the benchmarks <a name = "running-instructions"></a>

## Directory Structure <a name = "path-info"></a>

### Source code

The benchmarks are in `superopt-tests` directory.  Three benchmark suites are available: micro local allocation benchmarks (`localmem-tests`), micro vectorization benchmarks (`TSVC\_prior\_work\_globals` and `TSVC\_prior\_work\_locals`), and bzip2 (unmodified `bzip2_locals` and modified `bzip2_modified`).

**Micro local allocation benchmarks**
 - `TSVC_prior_work` directory contains the 28 TSVC benchmark functions which have already been demonstrated by SPA.
 - `TSVC_new` directory contains the TSVC benchmark functions for which Dynamo is the first to automatically generate equivalence proofs (they were not demonstrated by SPA).
 - The TSVC benchmark functions are compiled using recent versions of production compilers, namely, GCC-8, Clang/LLVM-11, and ICC-18.0.3 with `-O3 -msse4.2` compiler flags (highest optimization levels) to generate optimized x86-32 binaries.

**Micro vectorization benchmarks**
 - For LORE loop nests, we use one representative pattern for a set of structurally-similar program/transformation pairs, irrespective of the compiler that generated it. The space of additional transformations performed in this category (that are not covered by TSVC functions) include loop splitting, loop fusion for bounded number of iterations, loop unswitching, and summarization of loop with small and constant bounds.
 - We consider total 16 different loop nest patterns. For each of these 16 patterns, we test two variations: one where the loop bodies involve a memory write contained in `LORE_mem_write` directory , and another where at least one of the loop bodies does not involve a memory write contained in `LORE_no_mem_write` directory.
 - Among the 16 variations that involve a memory write in the loop bodies, the compilers produce non-bisimilar transformations for five of them. Thus we show results for 11 loop nest patterns where loop bodies have memory writes, and 16 loop nest patterns where the loop bodies do not have memory writes. Further, for each loop nest variation, we test across two different unroll factors (μ = 4 and μ = 8). The patterns with unroll factor 8 are due to compilations generated by LLVM-11 or by GCC-8 with the appropriate pragma switch.

**bzip2 benchmarks**

### Input, Output and intermediate files

The input files viz. unoptimized LLVM IR and optimized assembly code generated by the compiler; the intermediate `.tfg` and `.etfg` files; and the output `.eqlog` and `.proof` files are present in the `superopt-tests/build/BMC` directory, where `BMC` represents the benchmark (one of `TSVC_prior_work`, `TSVC_new`, `LORE_mem_write`, `LORE_no_mem_write`).

There is a structure in naming and location of these files.  To give an example, for a source file `foo.c` of `BMC` benchmark suite:
 - The unoptimized LLVM IR is stored at the path `superopt-tests/build/BMC/foo.bc.eqchecker.O0`.
 - The optimized assembly code generated by compiler `CC` is stored at the path `superopt-tests/build/BMC/foo.CC.eqchecker.O3.i386`.
 - The intermediate `.etfg` file corresponding to the unoptimized IR is stored at the path `superopt-tests/build/BMC/foo.bc.eqchecker.O0.ll.ALL.etfg`.
 - The intermediate `.tfg` file corresponding to the optimized assembly code is stored at the path `superopt-tests/build/BMC/foo.CC.eqchecker.O3.i386.ALL.tfg`.
 - The output `.eqlog` and `.proof` files corresponding to the function `bar`, compiler `CC` and correlation search strategy `BFS` are generated at the path `superopt-tests/build/BMC/eqlogs/bar.CC.BFS.eqlog` and `superopt-tests/build/BMC/eqlogs/bar.CC.BFS.proof` respectively.
 - The output `.eqlog` and `.proof` files corresponding to the function `foo`, compiler `CC` and correlation search strategy `DFS` are generated at the path `superopt-tests/build/BMC/eqlogs/foo.CC.DFS.eqlog` and `superopt-tests/build/BMC/eqlogs/foo.CC.DFS.proof` respectively.

The format of the intermediate input files and output files is discussed in a [later section](#howto-IO).

## Reproducing Table 2 results <a name = "table2-gen"></a>

To reproduce the table 2 results, run `make tableresults` from `/home/user/artifact/` directory of the docker container.  The equivalence checker tool is run for all four benchmark categories with both BFS and DFS strategy to reproduce the results.  The benchmarks runs in parallel if multiple CPUs are available to the docker container.

The output is produced in the form of a CSV file at path `/home/user/artifact/table2.csv`.  This output CSV is generated by combining the statistics from the generated `.eqlog` files.

### Time taken for running the benchmarks

- It takes around 3 CPU-hours to run the `TSVC_prior_work` in BFS strategy.
- It takes around 11.5 CPU-hours to run the `TSVC_new` in BFS strategy.
- It takes around 2.5 CPU-hours to run the `LORE_mem_write` in BFS strategy.
- It takes around 4 CPU-hours to run the `LORE_no_mem_write` in BFS strategy.
- With a time limit of 5 hours and memory limit of 12 GB, it takes around 200 CPU-hours to run all benchmarks with DFS strategy.

### Description of the output CSV file

The CSV file mimics the structure of Table 2 in the paper.  The top row of the CSV lists the benchmarks with compiler/unroll-factor variations and subsequent rows list properties and results for each of these configurations.

The following list summarizes the properties.

1. `total-fns` and `failing-fns`: The total number and failing functions in the corresponding benchmark category.  Note that the total (and failing) count may differ from table 2 because the functions known to fail are not run in certain configurations and thus do not appear in data extracted from the run.  The number of passing functions (`total-fns` - `failing-fns`), however, should match the Table 2 numbers with exception of caveat mentioned at the end of this section.
2. `avg-ALOC` and `max-ALOC`: The average and maximum assembly lines of code in the optimized assembly.  This number is calculated by counting instructions in our internal representation and might be off by 2 or 4 because no-op instructions are ignored in our representation.
3. `avg-product-CFG-nodes`/`avg-product-CFG-edges` and `max-product-CFG-nodes`/`max-product-CFG-edges`: The average and maximum number of nodes and edges in the product-CFG generated by Dynamo.
4. `avg-total-CEs-node` and `avg-gen-CEs-node`: The average number of counterexamples per final product-CFG node ("Avg # of total CEs/node" in paper) and the average number of counterexamples that were generated (not propagated) per node through SMT queries ("Avg # of gen. CEs/node" in paper).
5. `BFS-avg-eqtime`: The average time taken (in seconds) to generate equivalence proof using the best-first search algorithm in each benchmark category ("Avg equivalence time" in paper).
6. `BFS-avg-paths-enum`, `BFS-avg-paths-pruned`, `BFS-avg-paths-expanded`: Statistics for the best-first search (BFS) algorithm: the number of correlation possibilities that were created (paths enumerated) before the complete product-CFG was found, the number of correlation possibilities that were remaining after pruning (paths pruned) and the number of correlation possibilities which were actually expanded further (paths expanded).
7. `DFS-avg-paths-enum`, `DFS-avg-paths-expanded`: Corresponding statistics for backtracking-based depth-first strategy (DFS) with static heuristic where counterexample-guided pruning and ranking is omitted. 
8. `avg-paths-expanded-DFS-by-BFS`: The ratio of the average number of paths expanded in DFS with-respect-to the average number of paths expanded in BFS.
9. `DFS-mem-timeout-reached`: The DFS strategy runs out of either time or memory resources for some of the benchmarks, this statistic count those cases.

It is important to note the final numbers may differ slightly from the paper numbers because the algorithm is counterexample driven which might come out different due to various reasons.  However, the difference is expected to be small.

### Note 0: Absence of Intel C Compiler (ICC)

The Intel C Compiler is not packaged with this artifact, instead pre-compiled binaries are provided (see `icc_bin.zip` file).  These binaries are automatically copied to appropriate paths when required and the final results include the data from ICC runs.

#### Building ICC binaries (instead of using the provided ones)

It is possible to use `icc` for building the binaries though it requires changes in multiple files.  The following changes are required:

1. Disable copying of of `icc_binaries` in top-level `Makefile`: Comment line #126:
```
  cp -r icc_binaries/* superopt-tests/build
```

2. export `ICC_INSTALL_DIR` environment variable (put it in .bashrc or similar place) which locates path of ICC installation (the default is usually `/opt/intel/system_studio_20XX`) .  The `icc` binary is then assumed to be located at `${ICC_INSTALL_DIR}/bin/icc`.  Note that the experiments reported in the paper used version `18.0.3`.

3. Enable generation of `icc` binaries in Makefile of each benchmark directory.  The following files need to be changed:
  * `superopt-tests/{LORE_mem_write,TSVC_new}/Makefile`: lines 54 and 55 need to be uncommented (i.e. remove # character).
  * `superopt-tests/LORE_no_mem_write/Makefile`: lines 55 and 56 need to be uncommented.
  * `superopt-tests/TSVC_prior_work/Makefile`: lines 52 and 53 need to be uncommented.

A `make testinit` in the top-level `Makefile` would now build the benchmarks using `icc` as well.  A failure in this step would indicate a bug in configuration.

## Running a particular benchmark category with either optimized encoding or unoptimized encoding <a name = "individual-results"></a>

The top level `Makefile` provides targets for running individual benchmarks with either BFS or DFS correlation search strategy.

For each benchmark,strategy pair, use the target template `oopsla_<benchmark>_<strategy>` for running it where `<benchmark>` is one of
* `tsvc_prior`
* `tsvc_new`
* `lore_mem_write`
* `lore_no_mem_write`

and `<strategy>` can be:
* `bfs` for best-first search
* `dfs` for depth-first search.

As an example, execute 
```
make oopsla_tsvc_prior_bfs
```
for running `TSVC_prior_work` benchmark functions with best-first search strategy and
```
make oopsla_lore_no_mem_write_dfs
```
for running `LORE_no_mem_write` benchmark functions with depth-first search.

## Running Dynamo on custom code <a name = "run-custom-code"></a>

Dynamo can be made to run on custom code by editing the `sample.c` file in `superopt-tests/demo`.
The following steps describe how to achieve it.

* Add the function in `sample.c`.
  * The `sample.c` implementation will be compiled to unoptimized LLVM bitcode and optimized x86 assembly using GCC and Clang/LLVM.
  * The equivalence checker is run only for functions named in `paper_func`.
* Run `make demo_results` from base directory of the artifact (`/home/eqcheck/artifact`)

The result of the run will appear in the form of message `build/demo/eqcheck.sample.gcc.eqchecker.O3.i386.s/sample-sample.gcc.eqchecker.O3.i386.ALL.log <passed/FAILED>`.  A "passed" output will indicate a successful run.

# HOWTO: Interpret the input and output files <a name="howto-IO"></a>

## Interpreting the input CFG (.tfg and .etfg) files <a name="howto-interpret-tfg"></a>

The .tfg and .etfg files are control flow graph (CFG) representations of x86 binary and LLVM bitcode respectively as required by the equivalence checker.  Both files have a hierarchical structure and share common attributes.  _Headers_ in the files are prefixed by `=`.  For example, `=Node`, `=Edge` etc.

Important headers (in order as they appear) are explained as follows.

1. `=FunctionName`: Identifies name of the C function.

2. `=TFG`: Beginning of control flow graph representation for the C function previously identified by `=FunctionName`.

3. `=Nodes`: List of PCs (program points/locations) in this CFG.
    1. The PC identifier is encoded as a 3-tuple: `<part0>%<part1>%<part2>`.
    2. Start PC is `L0%0%1` and exit PC is `E0%0%1`.

4. `=Edge`: A CFG edge is represented as an SP-graph with the following children fields:
    1. `=Edge.EdgeCond`: The edge condition in _expr_ format (explained below).
    2. `=Edge.StateTo`: Compressed transfer function for this edge.  State variables or domain of machine state includes: list of all LLVM variables, x86 registers and memory state variables. The compressed representation only contains mapping for state variables which were modified over this edge.  Further, the transfer function:
        1. Has 0 or more _(statevar, expr)_ tuple as children, and
        2. Each tuple is formatted as: `=<state-variable name>` followed by _expr_ for this state-variable.

5. `=Input`: List of arguments to the C function.  Each argument gets a separate `=Input` header.

6. `=Output`: The values returned by the function.  Includes:
    1. the return value/register (if the return type is non-void)
    2. heap
    3. global symbols modified by this function
    4. the return address.

7. `=Symbol-map`: A list of symbols that are used in the function.  Contains additional information such as name (as it appears in LLVM's symbol map), size, alignment and "constness" (0 == non-const, 1 == const) separated by ':'.

8. `=memlabel_map.<numeric_id>`: The alias analysis associates a potentially points-to set with each memory operation's target address and stores it in a mapping.  This is dump for the same.

9. `  =Locs`: _Locs_ are set of state variables which are considered for alias analysis, invariant inference and other analyses.  This includes LLVM variables, x86 registers, and memory elements whose address is a known (symbolic or numeric) constant and memories (segmented into heap, global variables and stack).  Locs are associated with a unique numeric identifier.

11. `=Liveness`: Result of liveness-analysis.  Lists locs (represented with locid) live at each PC.

12. `=sprel_maps`: Result of available expressions analysis.

13. `=String-contents`: Contents of read-only (RO) symbols from `.rodata` section of ELF which are referenced in this function.

14. `=Nextpc-map`: Map of targets for each call instruction.

15. `=TFGdone`: TFG end string.

### Structures of common fields <a name="common-fields"></a>

1. Expression or _expr_: Expressions involving state variables are represented as DAGs.  The format is:
    ```
    <expr_id> : <op> : <type>
    ```
    where `<op>` can be a state element or an SMT-like operator referencing other expressions using `<expr_id>`s.  E.g. `bvadd(123, input.src.llvm-%0)` is represented as:
    ```
    1 : 123 : BV:32
    2 : input.src.llvm-%0 : BV:32
    3 : bvadd(1, 2) : BV:32
    ```

2. Predicate or _pred_: A predicate encodes `(precond) => (lhs == rhs)` in the following structure:
    ```
    =Comment
    <string>
    =LocalSprelAssumptions:
    <this field can be safely ignored>
    =Guard
    <precondition (represented as an SP-graph) for this predicate>
    =LhsExpr
    <expr>
    =RhsExpr
    <expr>
    ```
    For example, the following predicate unconditionally asserts that state variable `input.src.llvm-%1` and `input.dst.exreg.0.5` have same value.
    ```
    =Comment
    linear2-32
    =LocalSprelAssumptions:
    =Guard
    (epsilon)
    =LhsExpr
    1 : input.src.llvm-%1 : BV:32
    =RhsExpr
    1 : input.dst.exreg.0.5 : BV:32
    ```
3. Pathset representation or the SP-graph:  The SP-graph is a recursively defined structure.
    1. epsilon (empty edge) is   `(epsilon)`
    2. Singular edge is          `<from_pc> => <to_pc>`
    3. A parallel combination is `( <sp_graph> + <sp_graph> )`
    4. A serial combination is   `( <sp_graph> * <sp_graph> )`

## Interpreting the output product-CFG (.proof) file <a name="howto-interpret-proof"></a>

The .proof is structured similar to .tfg file with same heading style.  The equivalence witness is a correlation graph (or product-CFG) and the .proof is essentially a dump of this structure.

* A correlation graph node is a tuple of input graphs' nodes.
* A correlation graph edge is a tuple of input graphs' pathsets.
* Each correlation graph node has a set of inductive invariants which are provable at that program point.

Important bits (in the order as they appear) are:

1. `=FunctionName`: Name of the corresponding C function.
2. `=result`: Will be 1 if equivalence check succeeded.
3. `=corr_graph`: Beginning of dump of the correlation graph.  This is followed by `=src_tfg` (CFG for LLVM bitcode i.e. C) and `=dst_tfg` (CFG for x86 assembly i.e. A) dumps.
4. `=eqcheck` (and `=eqcheck_info`): Dump of meta data information, can be safely ignored.
5. `=Nodes`: List of correlation graph PC identifiers formatted as `<src_cfg_pc_id>_<x86_cfg_pc_id>`.
6. `=Edges`: List of correlation graph edges as 2-tuple of from PC and to PC.
7. `=Edge` list: Each entry in the list describes a correlation graph edge.  Constituent pathsets from C and A are listed under `=Edge.src_edge_composition` and `=Edge.dst_edge_composition` respectively.
8. `=Invariant state` list: Each entry in the list describes set of invariants at each PC of the correlation graph.  The most interesting part of invariant state is the set of predicates (`pred`):
    1. A predicate is conveniently preceded by a line which lists the PC where it was proved and its "type" (which can be `arr`, `bv` among others).  The format of this line is `=pc <PC> invariant_state_eqclass <id> type <type> pred <pred_num>`.  Example: `=pc Lif.then%2%200003_L11%1%200003 invariant_state_eqclass 0 type arr pred 0`
    2. The predicate is structured as explained in previous section.
    3. Full example of a predicate which asserts that memory states are equal at PC `Lif.then%2%200003_L11%1%200003`:
       ```
       =pc Lif.then%2%200003_L11%1%200003 invariant_state_eqclass 0 type arr pred 0
       =Comment
       guess-mem-nonstack
       =LocalSprelAssumptions:
       =Guard
       (epsilon)
       =LhsExpr
       1 : 1 : BOOL
       =RhsExpr
       1 : input.src.llvm-mem : ARRAY[BV:32 -> BV:8]
       2 : input.dst.mem : ARRAY[BV:32 -> BV:8]
       3 : memlabel-mem-symbol.70.0-symbol.77.0-symbol.78.1-heap : MEMLABEL
       4 : memmasks_are_equal(1, 2, 3) : BOOL
       ```
       The operator `memmasks_are_equal` returns `true` iff its first two memory operands have same state in the regions specified by the third operand.  In this particular example, the memory state variables `input.src.llvm-mem` (i.e. LLVM input memory) and `input.dst.mem` (i.e. x86 input memory) are asserted to be equal in the global symbol memory regions and heap.

## Interpreting the output log (.eqlog) file <a name="howto-interpret-eqlog"></a>

Given the CFGs for LLVM bit code and x86 assembly, the equivalence checker tool generates a log file (`.eqlog`) while constructing the product-CFG.  This `.eqlog` file contains the input CFGs, the function name, SMT solver timeout, global timeout, path of the input `.tfg` and `.etfg` files and path of the output `.proof` file.  Further, it captures the input and output for high level functions shown in Fig 7 of the paper.  This includes: 
- The initial product-CFG returned by `initProductCFG()` function.
- _PCpair_ returned by `findIncompleteNode()` function for the constructed partial product-CFG.
- _FullPathSet_ in A in SP-graph notation as returned by `getNextPathsetRPO()` function and the associated _nexthop_ PC.
- The _FullPathSets_ in C enumerated by `getCandCorrelations()` function in SP-graph representation.  For each enumerated pathset, the delta, μ (mu), from PC (nC), anchor node to-PC (wC), number of paths in the pathset, number of edges, and minimum and maximum path length are captured in the log file.
- The outcome of `CEsSatisfyCorrelCriterion` and `InvRelatesHeapAtEachNode` checks for every pair of the above chosen pathset in A and enumerated pathset in C.
- The output of `computeRank()` function for pathset pairs which satisfy both the above checks.
- The number of new partial product-CFGs enumerated by `expandProductCFG()` function and the size of the frontier after adding these new product-CFGs (probable correlations). 
- The partial product-CFG chosen by function `removeMostPromising()`.

It also captures whether the tool is able to construct the final product-CFG that proves bisimulation or the tool reached a memory or time threshold.
In both the cases, the statistics/counters as shown in table 2 of paper are printed at the end of the file.

# Archived output (.csv) files <a name = "archived-files"></a>

We have included the .csv files for all benchmarks at the path `archived-results/oopsla-csvs.tar.xz`.
The numbers generated from `make gen_bzip2_tables` can be matched against provided files inside the archive (`tab_bzip2_short.csv` and `tab_bzip2_full.tex`).
