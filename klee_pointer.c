#include <klee/klee.h>
#include <stdlib.h>

int* func(int x, int y) {
  int* p = 0; //p=NULL
  int s = x + y;
  if(s != 0){
    p = malloc(s);
  }else if(y == 0){
    p = malloc(x);
  }
  klee_assume(p != 0);
  return p;
}

int main() {
  int a, b;
  klee_make_symbolic(&a, sizeof(a), "a");
  klee_make_symbolic(&b, sizeof(b), "b");
  func(a, b);
  return 0;
}
