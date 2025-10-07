#include <klee/klee.h>

int swap(unsigned int x, unsigned int y) {
  if(x < y) {
    x = x + y;
    y = x - y;
    x = x - y;
  }
  klee_assume(x >= y);
  return 0;
}

int main() {
  unsigned int a, b;
  klee_make_symbolic(&a, sizeof(a), "a");
  klee_make_symbolic(&b, sizeof(b), "b");
  return swap(a, b);
}
