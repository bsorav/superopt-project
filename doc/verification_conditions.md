A Short Factsheet on Correlation Algorithm
==========================================

* A TFG does not have explicit error-going edges
  * Instead, error conditions of an edge are modeled through `assumes` (negation of which triggers UB) and `wfconds` (negation of which triggers WF failure) --- together they are "absence of error" conditions of the edge.
* A CG edge is composed of a src pathset and a dst pathset (a pathset is a set of mutually exclusive paths that begin at a common starting node and end at a common ending node)
* Because TFG does not have explicit error-going edges, the correlation of error-going paths is implicit in a CG edge.:
  * We discharge separate verification conditions for absence of unsafe UB in dst pathset ("unsafe UB in dst": src is safe but dst is not safe).

Verification Conditions discharged by eq
========================================

eq discharges the following kinds of queries, all of which are formulated as DHT queries:

1. (CoverageA) dst pathset is executable (`PRED_COMMENT_DST_EDGECOND_PROVES_FALSE`):

   ```
   Pre  /\  src-is-ub-free  =>  ~(dst-pathset-cond-wo-assumes-wfconds)
   ```
   
   If the query is unsat, then dst pathset is not executable and does not need to be correlated.
   
   * Note that we do not test for an error-free execution (`dst-pathset-cond-wo-assumes-wfconds` excludes the "absence of error" conditions)
   * This is because for (Safety) we need to consider the unsafe UB violations in dst.
     * If we were to consider only the error-free executions (through `dst-pathset-cond-w-assumes-wfconds` -- note the `w-assumes...` instead of `wo-assumes...`), then we would (unsoundly) miss proving absence of unsafe UB in a dst that potentially executes UB.
   * Because the dst TFG is non-blocking (at least one outgoing edge at non-exit node will execute), this ensures that we do not miss any error-going path.

2. (CoverageC) CG edge executes: dst pathset implies src pathset (`WFCOND_DST_EDGECOND_IMPLIES_SRC_EDGECOND`):

   ```
   Pre  /\  src-is-ub-free  /\  cg-edge-assumes  =>  (dst-pathset-cond-w-assumes-wfconds => src-pathset-cond-wo-assumes-wfconds)
   ```
   
   In an execution where neither src executes error nor dst executes error, an error-free execution of dst pathset implies an error-free execution of src pathset.
   If either src or dst executes error, then this error-free coverage VC holds trivially.
   `cg-edge-assumes` are _determinizing_ conditions for non-deterministic operations in src (e.g., value of an `alloc_ptr`).

3. (Safety) dst does NOT execute unsafe UB (`PRED_COMMENT_DST_WFCOND...`):

   ```
   Pre  /\  src-is-ub-free  /\  cg-edge-assumes  =>  dst-is-ub-free
   ```
   
   `dst-is-ub-free = (dst-path-cond-w-assumes-wfconds => absence-of-ub-assume)`, i.e., an error-free execution does not trigger UB.

4. (MAC) dst does not perform stray heap accesses (`PRED_COMMENT_UNALLOC_ACCESS`):

   ```
   Pre  /\  src-is-ub-free  /\  cg-edge-assumes  => (src-is-safe  =>  dst-is-safe)
   ```
   
   `dst-is-safe = (dst-path-cond-w-assumes-wfconds => access-is-safe-pred)`, i.e., an error-free execution does not make stray heap access.

5. (Uncorrel-(de)alloc) uncorrelated (de)alloc instructions are unreachable in a CG edge (`WFCOND_UNCORRELATED_SRC_ALLOC_DEALLOC_UNREACHABLE` and `WFCOND_UNCORRELATED_DST_ALLOC_DEALLOC_UNREACHABLE`):
   1. src uncorrelated (de)alloc is unreachable:
    
    ```
    Pre  /\  src-is-ub-free  /\  cg-edge-assumes  =>  (dst-pathset-cond-w-assumes-wfconds => src-path-cond-wo-assumes-wfconds)
    ```
    
   2. dst uncorrelated (de)alloc is unreachable:

    ```
    Pre  /\  src-is-ub-free  /\  cg-edge-assumes  =>  ~(dst-path-cond-w-assumes-wfcond)
    ```
    
   In both cases, we do not need correlation if dst executes error.

6. (mem.{data,alloc}Eq) establishing mem.data and mem.alloc equality at a CG node (also applicable for establishing equality of fcall args and return values, d2s, and invariant inference)

   ```
   Hoare Triple: { Pre  /\  src-is-ub-free  /\  cg-edge-assumes } CG-edge { post }
   ```

   Recall that because we do not have explicit error edges, `CG-edge`'s execution indicates error-free execution.
