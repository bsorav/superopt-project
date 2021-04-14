#define N 100
int A[N];

int sum(int n, unsigned j)
{
  int ret = 0;
  if (j >= N) {
    j = N-1;
  } else {
    ret += A[j];
  }
  for (int i = 1; i < n; ++i) {
    ret += i*A[j];
  }
  return ret;
}

