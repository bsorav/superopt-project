# Motivation

Consider the following program:
```
int foo(...) {
  ...
  ...
  ... #100+ lines of code
  return ...;
}
```
The proof obligations that will be created for validating a compilation of this
program (even at O0) will involve huge transfer functions, resulting in
large first-order-logic (FOL) expressions submitted to the SMT solver.  This causes
the SMT solver (and perhaps our expression handling logic) to take a long time.

# Hypothesis

For a compilation at `O0` optimization level (no optimizations enabled),
our equivalence checker must ensure that all equivalence
expressions (that are expected to be equivalent) submitted to the
SMT solver are easy to discharge, if not trivial enough to be decided syntactically (i.e.,
without having to go to the SMT solver).
This means that the only SMT timeouts should be due to queries that
were actually inequivalent.  In other words, as long as the search
algorithm for correlations and invariants (Counter) is effective, we
should always be able to complete such equivalence proofs.

# Current issues

- Validating translations of large functions takes an inordinately high time, and fails in many cases due to SMT query timeouts.  Testcase: `bzip2/bzip2.c`

- Validating translations of small functions that mix memory and floating point result in SMT query timeouts.  Testcases: in the `fp/` directory

- There are perhaps more issues

# Proposed solution : relate intermediate values and use that to incrementally relate the final values

Let the src program have 100 instructions that roughly look like the following:
```
%1 = ...
%2 = ...
...
%100 = %99*2
```
This also includes store instructions, etc., where a store instruction returns a new memory state in the output variable.

Let the dst program have 100 instructions that roughly look like the following:
```
r1.1 = ...
r2.1 = ...
...
r1.2 = ...
....
%r3.100 = r2.99 << 1
```
Notice that the suffix number `.<n>` represents the SSA version for that register. Again, memory is also treated as a variable (just like in src).

`d2s` maintains a function from dst values (`r1.1`, `r2.1`, ..., `r1.2`, ..., `r3.100`) to zero or more src values (drawn from `%1`, `%2`, ...), with the
following semantics:  _an ordered pair (d,s) exists in this relation iff: whenever execution starts at the beginning of this acyclic program in a state that satisfies the precondition (or invariants) at the beginning of two programs and ends at the end of these two programs, if `d` is defined during this execution in the dst program, then `s` will also be defined in the src program such that their values will be equal, i.e., d=s_.

Some subtleties:
- Notice the antecedant, "if `d` is defined during this execution in the dst program".  `d` may not be defined if the program has multiple paths (e.g., due to if-then-else) and the path containing `d` has not executed
- This formulation relies on the programs being in SSA form for precision.  However, this formulation works on both SSA and non-SSA forms.  If the programs are not SSA, the precision (i.e., the number of inferred d2s relationships) may be lower than ideal.
- Memories cannot be usually equated across a src and dst program.  Instead, we use `memmasks_are_equal` to equate memory regions.  The definition of `d2s` can be adapted to support this in a straightforward manner.

## How does that help

- Consider a query that attempts to relate `%100 = %r3.100` which we call the _postcondition_ or _post_.  Now, the WP of this query in FOL will be rather large and may overwhelm the SMT solver.
- Let us say that we already had `(%99, %r2.99)` as an ordered pair in our `d2s` function.  When we take the WP of _post_, we can do "intemediate substitution using d2s" so that we get the FOL expression `%99*2=%99<<1` (instead of the original `%99*2=%r2.99 << 1`).  This (even after taking the WP of %99) is much easier to discharge for the SMT solver.
- In fact, this intermediate substitution can be done even during the identification of the `(d,s)` pairs:  the pairs are identified in a topologically-sorted order, where the the later pairs make use of the already-known relationships.

# Code pointers

- The `cg_with_dst_to_src_submap` class in `include/eq/cg_with_dst_to_src_submap.h` implements the logic by overriding existing functions.
  - It is thus easy to switch off `d2s` as we only need to revert to the original implementations of the overridden functions
  - You can use the `--disable-d2s` command-line flag to disable d2s
  - A `d2s_state` (of type `d2s_state_t`) is associated with each CG edge that maintains the `d2s` relationships for that edge
- The `add_edge` function is overridden so that
  - Each time an edge is added to a CG, we initialize the `d2s` mappings based on the current set of invariants (and counterexamples) at the from-PC of that edge
- The `graph_counter_example_translate_on_edge_helper` is overridden so that
  - Each time a counterexample executes on this edge, the `d2s_state` is _weakened_ so that if any `(d,s)` mapping is violated by the counterexample, it is removed
- `computeWP` is overridden so that
  - intermediate substitutions are implemented based on the current `d2s` state
- `cg_edge_pth_collect_preds_using_atom_func` is overridden so that
  - The predicates that are generated on each edge are opportunistically substituted using intermediate d2s substitutions

## `add_edge`
- The `cg_create_new_d2s_state` function creates an initial d2s state where each dst variable `d` can be related with all src variables `s`.
- The `graph_update_structures_for_pcs_with_changed_invstates` function updates the outgoing dst paths to enumerate at each pcpair in CG (this is orthogonal to the d2s logic)
- `corr_graph_update_dst_to_src_submaps_for_cg_edge` and `cg_update_d2s_helper` are functions that update the d2s state based on the current state of invariants at the from-PC.  The most significant function here is `d2s_state_update`.
- The new `d2s_state` contains a copy of the src and dst paths, such that all the variables in the copied paths are SSA-renamed (over and above any SSA naming that may have existed in the original paths)


## `graph_counter_example_translate_on_edge_helper`
- `cg_with_d2s_CE_translate_on_d2s_paths` translates the counterexample on the copied paths to obtain evaluations of the SSA-renamed variables assigned in the copied paths.  Notice that the evaluations for the SSA-renamed input variables are initialized before executing the counterexample.
- Finally, `d2s_state_register_counterexample` calls `d2s_candidates_weaken_using_CE` to remove the violated `(d,s)` pairs.

## `computeWP`
- `computeWP_and_rename_at_from_pc` is used to compute WP on the copied paths (with SSA renaming) and the rename back to non-SSA-names at the from PC (after computing WP)

## `d2s_candidates_update` (called from `d2s_state_update`)
- Picks a `(d,s)` pair in order to check (`identify_d2s_candidate_to_check`)
- Checks `(d,s)` to see if they are equal.  Uses existing `d2s_state` mappings during this check
  - If equal, this mapping is added to the new d2s state
  - If not equal, this mapping is not added to the new d2s state
    - Any counterexamples generated in this case automatically weaken the d2s state (using lower layers of abstraction) and so the next picked `(d,s)` pair will be chosen accordingly.
- The above procedure is repeated until a _fixed point_ is reached
  - A fixpoint computation is required because the existing `(d,s)` mappings are used during each check.
  - Thus, for soundness, it is necessary that in a given iteration, all picked `(d,s)` pairs are correct before we can return
  - The fixpoint solution is guaranteed to be reached and to be optimal

# Getting started

1. Clone the `perf-18.1.2` branch of the `superopt-project` repo (and update the submodules)
2. Run `make run_tests_bzip2` in the `superopt-tests` directory
3. Run `show-results build/bzip2/clangv.bzip2.O0` to see the progress of these tests
4. You may find that one or more of the following equivalence checks time out. The `[qtN]` annotation indicates that `N` SMT queries timed out
   - loadAndRLEsource
   - qSort3
   - sendMTFValues
   - sortIt
5. Look at the `stdout` file for one of the functions, say `submit.loadAndRLEsource/stdout` and search for `WARNING : Solver timeout`
6. You may find a dump of the `decide_hoare_triple` query in a line that looks like the following.  We call this file the DHT dump (DHT stands for `decide_hoare_triple`)
```
decide_hoare_triple query timed out with timeout-all-proof-path-optimizations-num-smt-queries-is-1! filename /tmp/smt-solver-tmp-files/sbansal.2494373/decide_hoare_triple.exit.memeq.symbol.13.from_pcLwhile.body%1%fcallEnd_Lwhile.body.inum50%1%fcallEnd.path_hash391e58fbe992d7c8cbad28ebb997827.pre97.0.gz
```
7. Save the DHT dump.  Inside the DHT dump, you will find the exact DHT query, which will also include the `d2s_state` on the CG edge on which the DHT query was executeed.  You can use the `decide_hoare_triple` tool (in `tools/decide_hoare_triple.cpp`) to execute the query in this DHT dump.
8. Identify why the query was not trivial.  The query may not be fast because of one of the following reasons
   a. The query was not provable, and so `d2s` did not help (perhaps expectedly).  Please see "How to tell if a query is expected to be provable"
   b. The query was provable, but `d2s` did not help. This is perhaps unexpected because we are only validating an `O0` compilation where no optimizations are present, and so `d2s` should ideally have been able to correlate all intermediate dst values.  In this case, identify how we could (manually) change the d2s state in the DHT dump so that the query may become fast to discharge.  
9. Once we have identified the missing pieces of information in the `d2s_state`, we should identify the logic that needs to be implemented in the `d2s` framework to solve this problem in the future (automatically).

## How to tell if a query is expected to be provable
- As the correlation algorithm proceeds, edges are added incrementally, one at a time, to a CG.
- Multiple CGs are explored in a search tree, and a best-first-search algorithm is employed (Counter)
- Each enumerated (potentially partial) CG is given a distinct name (e.g., `simpleSort.A1.B5.C2.D2.E2.F1.G1.H1.I1.J1.K1.L1.M1`) which names the path from the root of the search tree to this CG in the search tree.  The letters `A`, `B`, ... represent the levels of the tree, and the numbers represent the index of the edge that needs to be followed at that level, e.g., follow the fifth edge in the outgoing edges at level `B` of the `A1` node in the search tree.
- At `O0`, the required CG is the trivial CG that has a one-to-one correspondence between paths in the src (LLVM) program and the dst (assembly program)
- One of the common questions that a developer needs to ask is: "Are we on the correct CG?", i.e., are we looking at the correct set of correlated paths (for the correlations performed so far).
  - To facilitate this, we use the debugging headers to label the basic blocks in the assembly program with their LLVM counterparts.
  - For example, if a basic block in the assembly program starts at the 20th instruction (called `i20`), and it corresponds to the basic block named `while.cond` in the LLVM program, then the corresponding PC is `Lwhile.cond.inum20%1%bbentry`
    - A PC is divided into three parts, separated by the `%` delimiter.  The first part is called the index
      - The `while.cond` label is due to the corresponding LLVM basic block (which is always identifiable at `O0`)
      - The `inum20` corresponds to `i20`
    - The second part is called the subindex
      - For assembly, this subindex is usually `0`
      - For LLVM, this subindex represents the index of the corresponding instruction in the basic block, counting only non-phi instructions.  For example, the first non-phi instruction in the basic block has a PC with subindex 0, the second has subindex 1, and so on...
    - The third part is called the subsubindex
      - If a single (LLVM or assembly) instruction requires multiple edges for its logical modeling, then we use the subsubindex to name the intermediate PCs.
      - We also use subsubindex to explicitly identify PCs that mark the start of a basic block (using a subsubindex of `bbentry`) from others (using a subsubindex of `d` which stands for "default")
  - To check if we are on the correct path, search for the last phrase `Chose (for CE propagation)...` or `Chose (after CE propagation)..`.  You can be sure that the current query is being discharged on this chosen CG.
  - You can take a look at the edge correlations to convince yourself that the current correlation is the correct (or expected one) by checking that all the PCs in the CG are formed by the correlated PCs in the src and dst programs
    - For example, at `O0`, `Lwhile.cond%1%bbentry_Lwhile.cond.inum20%1%bbentry` seems like a correct PC correlation, because the LLVM PC and the LLVM name of the assembly PC as obtained through the debugging headers are identical, `while.cond` in this case.  On the other hand, `Lwhile.cond%1%bbentry_Lwhile.cond2.inum30%1%bbentry` would be an incorrect PC correlation.
    - Further the unroll factors (indicated by `mu` and `delta` values) should be 1 for all the edges at `O0`
