#ifndef CRC32_H
#define CRC32_H

#include <stdint.h>
#include <stddef.h>

void init_crc32_table(void);
uint32_t crc32(const uint8_t *data, size_t length);

#endif
