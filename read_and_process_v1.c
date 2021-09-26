#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIG_LEN 5
#define CTYPE_LEN 5
#define CSIZE_LEN 4

typedef struct {
  char *type;
  int size;
  char *data;
} chunk_t;

chunk_t* find_BOOM(FILE *fp) {
  char signature[SIG_LEN];
  signature[SIG_LEN - 1] = 0; //NULL terminated string
  chunk_t* chunkBOOM = NULL;

  // check the signature
  if (fread(signature, SIG_LEN - 1, 1, fp)) {
    if (strcmp(signature, "ABCD")) {
      printf("Error! Invalid file signature\n");
      goto end;
    }
  } else {
    printf("Error! Invalid file\n");
    goto end;
  }

  // read the content until the end of the file
  // or until a BOOM chunk is found
  while(!feof(fp)) {
    char ctype[CTYPE_LEN];
    ctype[CTYPE_LEN - 1] = 0; //NULL terminated string
    unsigned int csize;
    char *cdata = NULL;

    // read chunk type
    if (fread(ctype, CTYPE_LEN - 1, 1, fp)) {
      if (fread(&csize, CSIZE_LEN, 1, fp)) {

        cdata = (char *) malloc(csize);        
        if (fread(cdata, csize, 1, fp)) {
          if (!strcmp(ctype, "BOOM")) {
            chunkBOOM = (chunk_t *) malloc(sizeof(chunk_t));
            chunkBOOM->type = (char *) malloc(CTYPE_LEN);
            memcpy(chunkBOOM->type, ctype, CTYPE_LEN - 1);
            chunkBOOM->size = csize;
            chunkBOOM->data = (char *) malloc(csize);
            memcpy(chunkBOOM->data, cdata, csize);
            if (cdata != NULL) free(cdata);
            goto end;
          }
        }
      }
    } else {
      if (feof(fp)) {
        printf("End of file\n");
        break;
      }
      printf("Error while reading chunk type\n");
      goto end;
    }
    
    // free cdata before reading the next chunk
    if (cdata != NULL) free(cdata);
  }

end:
  return chunkBOOM;
}

void process_BOOM(chunk_t *chunkBOOM) {
  unsigned int x, y;
  if (chunkBOOM == NULL) return;
  abort();
}

void main(int argc, char** argv) {
  FILE *fp;
  if ((fp = fopen(argv[1],"rb")) == NULL){
    printf("Error! No input file is given.\n");
    exit(1);
  }
  chunk_t *chunkBOOM = find_BOOM(fp);
  process_BOOM(chunkBOOM);
  fclose(fp); 
}
