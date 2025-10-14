#include "crc32.h"

// Precomputed CRC32 table (polynomial 0xEDB88320)
static uint32_t crc32_table[256];
static int table_initialized = 0;

// Initialize the CRC32 table
void init_crc32_table() {
    if (table_initialized) return;
    uint32_t crc;
    for (int i = 0; i < 256; i++) {
        crc = i;
        for (int j = 0; j < 8; j++) {
            if (crc & 1)
                crc = (crc >> 1) ^ 0xEDB88320;
            else
                crc >>= 1;
        }
        crc32_table[i] = crc;
    }
    table_initialized = 1;
}

// Compute the CRC32 checksum
uint32_t crc32(const uint8_t *data, size_t length) {
    init_crc32_table(); // ensure table is initialized
    uint32_t crc = 0xFFFFFFFF;
    for (size_t i = 0; i < length; i++) {
        uint8_t index = (uint8_t)((crc ^ data[i]) & 0xFF);
        crc = (crc >> 8) ^ crc32_table[index];
    }
    return crc ^ 0xFFFFFFFF;
}
