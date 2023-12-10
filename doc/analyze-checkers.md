# Analyzer checkers

The checkers listed below may be enabled/disabled using the -enable-checker and
-disable-checker options.  A default group of checkers is run unless explicitly disabled.
Exactly which checkers constitute the default group is a function of the operating system in
use; they are listed with --help-checkers.

## core.CallAndMessage

Check for logical errors for function calls (e.g., uninitialized arguments, null function pointers).
```
void test() {
   void (*foo)(void);
   foo = 0;
   foo(); // warn: function pointer is null
 }
```

## core.DivideZero

Check for division by zero.
```
void test(int z) {
  if (z == 0)
    int x = 1 / z; // warn
}

void test() {
  int x = 1;
  int y = x % 0; // warn
}
```

## core.NonNullParamChecker

Check for null pointers passed as arguments to a function whose arguments are references or marked with the ‘nonnull’ attribute.
```
int f(int *p) __attribute__((nonnull));

void test(int *p) {
  if (!p)
    f(p); // warn
}
```

## core.NullDereference
Check for dereferences of null pointers.
```
// C
void test(int *p) {
  if (p)
    return;

  int x = p[0]; // warn
}

// C
void test(int *p) {
  if (!p)
    *p = 0; // warn
}
```

## core.StackAddressEscape
Check that addresses to stack memory do not escape the function.
```
char const *p;

void test() {
  char const str[] = "string";
  p = str; // warn
}

void* test() {
   return __builtin_alloca(12); // warn
}

void test() {
  static int *x;
  int y;
  x = &y; // warn
}
```

## core.UndefinedBinaryOperatorResult
Check for undefined results of binary operators.
```
void test() {
  int x;
  int y = x + 1; // warn: left operand is garbage
}
```

## core.VLASize
Check for declarations of VLA of undefined or zero size.
```
void test() {
  int x;
  int vla1[x]; // warn: garbage as size
}

void test() {
  int x = 0;
  int vla2[x]; // warn: zero size
}
```

## core.uninitialized.ArraySubscript
Check for uninitialized values used as array subscripts.
```
void test() {
  int i, a[10];
  int x = a[i]; // warn: array subscript is undefined
}
```

## core.uninitialized.Assign
Check for assigning uninitialized values.
```
void test() {
  int x;
  x |= 1; // warn: left expression is uninitialized
}
```
## core.uninitialized.Branch
Check for uninitialized values used as branch conditions.
```
void test() {
  int x;
  if (x) // warn
    return;
}
```

## core.uninitialized.CapturedBlockVariable
Check for blocks that capture uninitialized values.
```
void test() {
  int x;
  ^{ int y = x; }(); // warn
}
```

## core.uninitialized.UndefReturn
Check for uninitialized values being returned to the caller.
```
int test() {
  int x;
  return x; // warn
}
```

## deadcode.DeadStores
Check for values stored to variables that are never read afterwards.
```
void test() {
  int x;
  x = 1; // warn
}
```

## security.insecureAPI.UncheckedReturn
Warn on uses of functions whose return values must be always checked.
```
void test() {
  setuid(1); // warn
}
```

## security.insecureAPI.getpw
Warn on uses of the ‘getpw’ function.
```
void test() {
  char buff[1024];
  getpw(2, buff); // warn
}
```

## security.insecureAPI.gets
Warn on uses of the ‘gets’ function.
```
void test() {
  char buff[1024];
  gets(buff); // warn
}
```

## security.insecureAPI.mkstemp
Warn when ‘mkstemp’ is passed fewer than 6 X’s in the format string.
```
void test() {
  mkstemp("XX"); // warn
}
```

## security.insecureAPI.mktemp
Warn on uses of the mktemp function.
```
void test() {
  char *x = mktemp("/tmp/zxcv"); // warn: insecure, use mkstemp
}
```

## security.insecureAPI.vfork
Warn on uses of the deprecated `vfork` function, use `posix_spawn` or `fork` instead.
```
void test() {
  vfork(); // warn
}
```

## unix.API
Check calls to various UNIX/Posix functions: open, pthread_once, calloc, malloc, realloc, alloca.
```

// Currently the check is performed for apple targets only.
void test(const char *path) {
  int fd = open(path, O_CREAT);
    // warn: call to 'open' requires a third argument when the
    // 'O_CREAT' flag is set
}

void f();

void test() {
  pthread_once_t pred = {0x30B1BCBA, {0}};
  pthread_once(&pred, f);
    // warn: call to 'pthread_once' uses the local variable
}

void test() {
  void *p = malloc(0); // warn: allocation size of 0 bytes
}

void test() {
  void *p = calloc(0, 42); // warn: allocation size of 0 bytes
}

void test() {
  void *p = malloc(1);
  p = realloc(p, 0); // warn: allocation size of 0 bytes
}

void test() {
  void *p = alloca(0); // warn: allocation size of 0 bytes
}

void test() {
  void *p = valloc(0); // warn: allocation size of 0 bytes
}
```

## unix.Malloc
Check for memory leaks, double free, and use-after-free problems. Traces memory managed by malloc()/free().
```
void test() {
  int *p = malloc(1);
  free(p);
  free(p); // warn: attempt to free released memory
}

void test() {
  int *p = malloc(sizeof(int));
  free(p);
  *p = 1; // warn: use after free
}

void test() {
  int *p = malloc(1);
  if (p)
    return; // warn: memory is never released
}

void test() {
  int a[] = { 1 };
  free(a); // warn: argument is not allocated by malloc
}

void test() {
  int *p = malloc(sizeof(char));
  p = p - 1;
  free(p); // warn: argument to free() is offset by -4 bytes
}
```


## unix.MallocSizeof
Check for dubious malloc arguments involving sizeof.
```
void test() {
  long *p = malloc(sizeof(short));
    // warn: result is converted to 'long *', which is
    // incompatible with operand type 'short'
  free(p);
}
```

## unix.Vfork
Check for proper usage of vfork.
```
int test(int x) {
  pid_t pid = vfork(); // warn
  if (pid != 0)
    return 0;

  switch (x) {
  case 0:
    pid = 1;
    execl("", "", 0);
    _exit(1);
    break;
  case 1:
    x = 0; // warn: this assignment is prohibited
    break;
  case 2:
    foo(); // warn: this function call is prohibited
    break;
  default:
    return 0; // warn: return is prohibited
  }

  while(1);
}
```

## unix.cstring.BadSizeArg
Check the size argument passed into C string functions for common erroneous patterns. Use -Wno-strncat-size compiler option to mute other strncat-related compiler warnings.
```
void test() {
  char dest[3];
  strncat(dest, """""""""""""""""""""""""*", sizeof(dest));
    // warn: potential buffer overflow
}
```

## unix.cstring.NullArg
Check for null pointers being passed as arguments to C string functions: strlen, strnlen, strcpy, strncpy, strcat, strncat, strcmp, strncmp, strcasecmp, strncasecmp, wcslen, wcsnlen.
```
int test() {
  return strlen(0); // warn
}
```
