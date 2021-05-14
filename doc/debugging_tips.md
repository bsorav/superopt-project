# Vimrc

```
$ cp misc/vimrc ~/.vimrc
```
The vimrc file enables VIM folding and this makes etfg insns incredibly usable.

You can use z-a in VIM to fold all foldable sections


# Debugging pattern matching during codegen

```
$ codegen --dyn_debug=insn_match.peep_enumerate_transmaps.pc1.fetchlen1.peep_get_all_trans=2 a.etfg
```

# Debugging eqcheck

```
$ eq --dyn_debug=oopsla_log,eqcheck,update_invariant_state_over_edge,decide_hoare_triple_dump,prove_using_local_sprel_expr_guesses_dump,smt_query=2,ce_add=2,ce_translate=2 a.etfg a.tfg
```

# Debugging old\_preds != new\_preds

```
eq32 --dyn_debug=eqcheck,ce_add=2,smt_query=2,ce_eval=2,add_point_using_ce=2,ce_translate=2,decide_hoare_triple_dump,prove_using_local_sprel_expr_guesses_dump --unroll-factor=4 a.c a.s
```
1. Look for "propagating across &lt;edge&gt;"
2. Look for "edge = &lt;CG-EDGE&gt;[src: ..., dst: ...]
3. Follow the chain of "attempting propagation of counterexample across &lt;edge&gt;"
4. Look for "dst out ce" and "src out ce" strings to identify the break between src-side propagation and dst-side propagation. The counter example printed after "src out ce" is the final translated counterexample.
5. The hash on the counterexample is only meant to identify duplicate CEs (with exact same key-value pairs)
6. You can evaluate the final translated counterexample on the src=dst expression of the decide-hoare-triple query file
7. You can evaluate the intial counterexample (at the from-pcpair) on the src=dst expression of the prove-using-local-sprel-expr-guesses query file
8. Ideally they should both evaluate to FALSE, but at least one of them will likely evaluate to TRUE and that is the reason for this assertion failure
   - if the initial counterexample evaluation evaluates to TRUE, there is likely a bug in the expr-evaluation logic
   - if the final counterexample evaluation evaluates to TRUE, and the initial counterexample evaluation evaluates to FALSE, there is likely a bug in the counterexample-translation logic

# Record/Replay of SMT queries

The equivalence checker is designed to have a deterministic execution
(see doc/discipline.md). However, because we execute multiple solvers
in parallel, and return the results from the solvers that finish first,
there is an inherent non-determinism in the algorithm.  To capture
this non-determinism (during debugging), we provide extra record/replay
flags.  Here is the usage:

```
$ eq32 --record smt.log a.c.bc.etfg a.s.o.tfg
```
The command listed above will generate a log of all the SMT queries
and the returned results in `smt.log` file

```
$ eq32 --replay smt.log a.c.bc.etfg a.s.o.tfg
```
The command listed above will consume smt.log to obtain the SMT
responses for the SMT queries. Because the rest of the system is
deterministic, identical queries are expected during replay, and they
are answered with identical responses (identical to the responses
generated during the record phase).

The replay works even if you make debug edits to the program.  As long
as you don't create any new managed objects (through the hash-consing
manager class), any debug edits (e.g., print, cout, etc.) make no difference
to the determinism of the replayed execution.

Caveat: it seems that record and replay must be on the same machine. If
record and replay are on different machines, this does not work, perhaps
because of compiler/library incompatibility while compiling the
jemalloc library (not sure, needs investigation)
