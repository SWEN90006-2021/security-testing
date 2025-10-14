#include <stdio.h>
#include <stdlib.h>

#define BUF_SIZE 4

void good_bad(char buf[BUF_SIZE]) {
  int count = 0;
  if (buf[0] == 'b') count++;
  if (buf[1] == 'a') count++;
  if (buf[2] == 'd') count++;
  if (buf[3] == '!') count++;
  if (count == 4) abort();
}

int main(int argc, char* argv[]) {
  FILE *fp;
  if (argc < 2) exit(1);
  if ((fp = fopen(argv[1],"rb")) == NULL){
    printf("Error! No input file is given.\n");
    exit(1);
  }
  
  //Get file size
  long lSize;
  char *buffer;
  fseek(fp , 0L , SEEK_END);
  lSize = ftell(fp);
  rewind(fp);

  if (lSize < BUF_SIZE) {
    printf("Error! The file is too small.\n");
    exit(1);
  }
  
  //Copy data to a buffer
  buffer = (char *)malloc(BUF_SIZE);
  fread(buffer, BUF_SIZE,1 ,fp);
  good_bad(buffer);
  free(buffer);
  return 0;
}
