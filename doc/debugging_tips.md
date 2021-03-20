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
$ eq --debug=oopsla_log,eqcheck,update_invariant_state_over_edge,decide_hoare_triple_dump,prove_using_local_sprel_expr_guesses_dump,smt_query=2,ce_add=2,ce_translate=2 a.etfg a.tfg
```

# Debugging old\_preds != new\_preds

```
eq32 --dyn_debug=eqcheck,ce_add=2,smt_query=2,ce_eval=2,add_point_using_ce=2,ce_translate=2 --unroll-factor=4 a.c a.s
```

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
