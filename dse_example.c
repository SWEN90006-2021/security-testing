//This program is a modification of an example published by ADALogics
//https://github.com/AdaLogics/adacc/blob/master/examples/afl-sample.c

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

int foo(char *arr, int count) {
    int i = 0;

    for (i = 0; i < count; i++) {
      if (arr[i] == 'A' + i) return i;
    }

    if (*(int*)(arr) != 0x4d4f4f42) {
        return i;
    }
    return 0;
}

int main(int argc, char* argv[]) {
    // open file
    FILE *f = fopen(argv[1], "rb");

    // get file size
    fseek(f, 0, SEEK_END);
    long fsize = ftell(f);

    // read file contents
    fseek(f, 0, SEEK_SET);
    char *string = (char*)malloc(fsize + 1);
    fread(string, 1, fsize, f);
    fclose(f);

    // call into target
    int retval = foo(string, fsize);

    free(string);
    return retval;
}
