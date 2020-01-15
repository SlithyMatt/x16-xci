#ifndef BITMAP_H
#define BITMAP_H

#include <stdint.h>

int conv_bitmap(const char *raw_fn, const char *xci_fn, uint8_t *pal);

int conv_bitmap_addr(const char *raw_fn, const char *xci_fn,
                     uint8_t *pal, int address);

#endif // BITMAP_H
