#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  char *type;
  int size;
  char *data;
} chunk_t;

chunk_t* find_BOOM(FILE *fp) {
  char signature[5];
  signature[4] = 0; //NULL terminated string
  chunk_t* chunkBOOM = NULL;

  // check the signature
  if (fread(signature, 4, 1, fp)) {
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
    char ctype[5];
    ctype[4] = 0; //NULL terminated string
    unsigned int csize;
    char *cdata = NULL;

    // read chunk type
    if (fread(ctype, 4, 1, fp)) {
      if (fread(&csize, 4, 1, fp)) {

        cdata = (char *) malloc(csize);
        if (cdata == NULL) {
          printf("Error! malloc fails\n");
          goto end;
        }
        
        if (fread(cdata, csize, 1, fp)) {
          if (!strcmp(ctype, "BOOM") && csize == 8) {
            chunkBOOM = (chunk_t *) malloc(sizeof(chunk_t));
            if (chunkBOOM == NULL) {
              printf("Error! malloc fails\n");
              goto end;
            }

            chunkBOOM->type = (char *) malloc(5);
            if (chunkBOOM->type == NULL) {
              printf("Error! malloc fails\n");
              goto end;
            }
            memcpy(chunkBOOM->type, ctype, 5);

            chunkBOOM->size = csize;

            chunkBOOM->data = (char *) malloc(csize);
            if (chunkBOOM->data == NULL) {
              printf("Error! malloc fails\n");
              goto end;
            }
            memcpy(chunkBOOM->data, cdata, csize);
            
            if (cdata != NULL) free(cdata);
            goto end;
          }
        } else {
          printf("Error while reading chunk data\n");
          goto end;
        }
      } else {
        printf("Error while reading chunk size\n");
        goto end;
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

  memcpy(&x, chunkBOOM->data, 4);
  memcpy(&y, &(chunkBOOM->data[4]), 4);
  
  if ((x + y > 283) && (x + y < 286)) {
    abort();
  }
}

int main(int argc, char** argv) {
  FILE *fp;

  if (argc < 2) {
    printf("No input file is given");
    exit(1);
  }

  if ((fp = fopen(argv[1],"rb")) == NULL){
    printf("Cannot open file\n");
    exit(1);
  }

  chunk_t *chunkBOOM = find_BOOM(fp);
  process_BOOM(chunkBOOM);

  if (chunkBOOM != NULL) {
    // free chunkBOOM
    free(chunkBOOM->type);
    free(chunkBOOM->data);
    free(chunkBOOM);
  }

  // close file 
  fclose(fp); 
  
  return 0;
}
