#ifndef HEX2BIN_H
#define HEX2BIN_H

#include <stdint.h>

int hex2bin_file(const char* hex_fn, const char* bin_fn);

int hex2bin_file_addr(const char* hex_fn, const char* bin_fn, int address);

size_t hex2bin(const char* hex_fn, uint8_t* bin, size_t max);

#endif // HEX2BIN_H
