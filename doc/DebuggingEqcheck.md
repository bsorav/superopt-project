# Debugging the equivalence checker

If you tried an equivalence check and it did not return the expected
result (e.g., you expected it to find an equivalence proof but it
could not), then you will need to dive deeper into what is happening.

## Understanding the output of the equivalence checking tool

1. The equivalence checker first converts the C program to LLVM IR, and also generates the object file from the assembly file. It then converts them into "transfer function graph" (TFG) files.  A TFG is similar to a CFG (control flow graph) and its edges are labeled with the corresponding edge condition and transfer function. The TFG file for the C source code has `.etfg` suffix while the TFG file for the assembly code has `.tfg` suffix. The equivalence checking tool `eq` can be applied directly to these TFG files too (thus avoiding repeated converstion of source code and assembly to TFG files).
2. The `eq` tool runs the best-first search (BFS) algorithm described in the OOPSLA 20 paper. To see it in action, search for lines containing "Chose product-TFG" in the tool's standard output.
3. These chosen product-TFGs represent the product programs chosen by the BFS algorithm at every step of the algorithm. An example output for a product-TFG is the following:
```
<MSG>45:02 : Chose product-TFG A65.B69 from a frontier of size 192...</MSG>
....
  Edges: (C L0%0%1 => C (line 12 at column 11) at mu 32 delta 1, A line 20 => A line 29 at mu 1 delta 1)
         (C (line 12 at column 11) => C (line 12 at column 11) at mu 32 delta 4, A line 29 => A line 29 at mu 1 delta 1)
  Nodes: (C L0%0%1, A line 20)
                L0%0%1_L0%0%1 contains 168 counterexamples
         (C (line 12 at column 11), A line 29)
                Lfor.body%1%1_L2%1%0 contains 163 counterexamples
                ismemlabel((@a + i*4 + 84), 4, memlabel-mem-symbol.1.0)
                ismemlabel((@b + i*4 + 28), 4, memlabel-mem-symbol.2.0)
                ismemlabel((@b + i*4 + 32), 4, memlabel-mem-symbol.2.0)
                ...
```
The first few lines show the edges in the product-TFG. The output is printed so that it is easily readable --- for example, we use the line and column numbers in the C source code file to name the program PCs in the source program.  Similarly, we use the line numbers in the assembly code file to name the program PCs in the assembly program.  For example, the line `(C (line 12 at column 11) => C (line 12 at column 11) at mu 32 delta 4, A line 29 => A line 29 at mu 1 delta 1)` indicates that if the source program loops from the starting PC (`line 12 at column 11`) to itself at unroll factor (`mu`) 32 and `delta` 4 (see OOPSLA 20 paper for what `mu` and `delta` mean), then the assembly program loops from line number 29 to itself.  In this case, this means that in this product program, 4 iterations of the source program are correlated with one iteration of the assembly program.
   The nodes are then listed (as their PC values) with the inferred invariants at each node.  The inferred invariants are printed informally for easy readability.  For formal representations of these invariants, you will have to enable more debugging flags (later).  With each node, we also list its "formal PC value" (e.g., `Lfor.body%1%1_L2%1%0` is the formal PC value for `(C (line 12 at column 11), A line 29)`) and the number of counterexamples we have added to that node so far (e.g., 163 for `(C (line 12 at column 11), A line 29)`).
   Each product-TFG has a name. In the example above, the name of the product-TFG is `A65.B69`.  This indicates that two edges have been added to the product-TFG so far, one in each step.  In the first step, it was the 65th choice among all the choices that were enumerated at that step. Similarly, this was the 69th  choice among all the choices enumerated while trying to expand `A65`.  This form of naming can help you understand the manner in which the BFS is proceeding, e.g., if it is backtracking or not.

Based on these investigations, you may be able to identify the "BFS step" at which the equivalence proof generation is failing.

# How to understand why the proof generation failed at a given "BFS step"
