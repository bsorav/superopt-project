# Discipline for using the superopt-project repositories

We request all collaborators to follow the following rules to avoid
confusion among the different developers, and to ensure that the repository
remains well-structured and easy to use.

## Branch-management
- Do not clobber a branch that is being used by others unless you have already consulted with all relevant people who are working on that branch
- Instead if you would like to change something, please create another branch.  You may have to create that branch in all the different repositories that you modify (including the top-level repository).
- Please do not name branches on people (e.g., sorav). Instead name it on features. For example, if you are working on performance optimizations, you may want to call your branch 'perf'.  Also, please avoid naming branches with numbers, e.g., perf1, perf2, etc.  Use the same branch name on all the repositories.
- After you are done making changes to your branch, send a review request to the relevant people.  If you get consent, you (or your colleague) may merge your branch into an existing branch.

## Git commit message

Please use clear and descriptive git commit messages.  Among our current team members, perhaps Abhishek Rose's commit messages (and code comments) are clearest and most descriptive.  Please look through them to get a sense of what are good commit messages and code comments.

## Deterministic execution in the presence of pointer comparisons

Many data structures involve indexing based on pointer values.  Given that
pointer values can be random, to preserve determinism, we need to follow two
disciplines:
- All "managed" objects (that are de-duplicated) are allocated from a deterministic memory allocator (based on slight modifications to jemalloc)
- All "unmanaged" objects are allocated using `make_dshared` to generate `dshared_ptr` objects which cannot be compared through inequalities (the corresponding operators are deleted for these objects).

Thus the only occurrence of the `make_shared` function in the superopt/ code should be in support/dshared\_ptr.h

# Coding guidelines

Here is some basic information to help developers understand the source code layout, and some coding guidelines that try and ensure that the repository remains consistent and easy to use over time.

## Layered library architecture
- The source code is organized as layers of libraries, where a higher-level library may depend on the routines implemented in the lower-level library, but not vice-versa.  For example, the `tfg` library depends on the `expr` library, but not vice-versa.
- The names of the libraries and their dependence order is evident from the "libs" line in `superopt/CMakeLists.txt`
- A single library is formed by all the .cpp (also .ypp, .l, etc.) files in the corresponding directories.  For example, the `tfg` library corresponds to the `tfg` directory. Similarly, the `eqchecker` library corresponds to the `eq` and `egen` directory.
- The following coding discipline ensures that this one-way dependence property is preserved
  - A file belonging to the higher-level library can only include files from its own library or lower-level libraries (relative to itself).
  - The include headers in a file must be listed in the order of the libraries that they represent (from lower-level to higher-level). This discipline is not currently implemented globally in all files yet; but we expect this to be followed, so over time, the entire repository follows this discipline.
- It is a good practice to have an include subdirectory in `include/` for each `lib` subdirectory, and put all the corresponding .h files in the include subdirectories

## Used Managed (Smart) Pointers
- Please completely avoid new/malloc
- Instead use make\_dshared to create dynamic objects.  Unlike make\_shared, the pointers returned by make\_dshared (of type dshared\_ptr) cannot be compared using less-than, greater-than, etc.  The "d" stands for deterministic (deterministic because the control flow is independent of the values of these pointers).
- Also, avoid using the "get()" functions in these managed pointer classes; instead pass the full smart pointer objects around.
- If you need to use pointers that are comparable (e.g., for performance reasons), please use the hash-consing manager class that produces de-duped references
- In other words, the "make\_shared" word should never appear in our code
- Similarly, "new" and "malloc" should be completely avoided (except in legacy code)
- Also, never construct a shared\_ptr/dshared\_ptr object from a raw pointer as it prevents the use of "shared\_from\_this()"
- When storing a pointer in heap objects, use "dshared\_ptr" instead of raw pointers
  - may need to use "this-&gt;shared\_from\_this()"
