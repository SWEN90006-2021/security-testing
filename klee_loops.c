#include <klee/klee.h>
#include <stdlib.h>

int func(int x, int y) {
   int i = 0, j = 0, count = 0;
   if (x < 100 && y < 100) {
   for(i = 0; i < x; i++) {
      for(j = 0; j < y; j++) {
         count = count + 1;
	       if (count == 300) abort();
      }
   }
   }
   return 0;
}

int main() {
  int a, b;
  klee_make_symbolic(&a, sizeof(a), "a");
  klee_make_symbolic(&b, sizeof(b), "b");
  func(a, b);
  return 0;
}
