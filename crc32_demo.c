#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "crc32.h"

int main(int argc, char** argv) {
    FILE *fp;
    if (argc < 2) exit(1);
    if ((fp = fopen(argv[1],"rb")) == NULL){
        printf("Error! No input file is given.\n");
        exit(1);
    }

    // Get file size
    fseek(fp , 0L , SEEK_END);
    long lSize = ftell(fp);
    rewind(fp);

    if (lSize < 12) {
        printf("Error! The file is too small.\n");
        exit(1);
    }

    uint32_t x;

    // Read the first 4 bytes
    if (fread(&x, 4, 1, fp)) {
        // Copy data to a buffer
        char* buffer = (char *)malloc(lSize - 4);
        if (!buffer) {
            printf("Memory allocation failed.\n");
            exit(1);
        }

        fread(buffer, lSize - 4, 1 ,fp);
        uint32_t checksum = crc32((const uint8_t *)buffer, lSize - 4);

        if (x == checksum) {
            printf("x = 0x%08X\n", x);
            printf("CRC32 = 0x%08X\n", checksum);
            abort();
        } else {
            printf("x = 0x%08X\n", x);
            printf("CRC32 = 0x%08X\n", checksum);
            //do something else that have several branching statements
            if ((x > 1000) && (x < 1000000)) {
                if ((x > 2000) && (x < 3000)) {
                    if (x == 2500) {
                        printf("x = 0x%08X\n", x);
                    } else {
                        printf("x = 0x%08X\n", x);
                    }
                }
            }
        }

        free(buffer);
        return 0;
    }

    printf("Failed to read the file.\n");
    return 1;
}
