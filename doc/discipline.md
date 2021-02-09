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
