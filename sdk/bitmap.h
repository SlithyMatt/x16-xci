#ifndef BITMAP_H
#define BITMAP_H

#include <stdint.h>

int conv_bitmap(const char *raw_fn, const char *xci_fn, uint8_t *pal);

int conv_bitmap_addr(const char *raw_fn, const char *xci_fn,
                     uint8_t *pal, int address);

void create_black_bitmap(const char *xci_fn, int height);

#endif // BITMAP_H
