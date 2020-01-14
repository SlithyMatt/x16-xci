#ifndef TILE_LAYOUT_H
#define TILE_LAYOUT_H

#include "config.h"
#include <stdint.h>

#define TILEMAP_MAX_WIDTH 40
#define TILEMAP_MAX_HEIGHT 25
#define TILEMAP_SIZE (2*TILEMAP_MAX_WIDTH*TILEMAP_MAX_HEIGHT)

typedef struct {
   uint8_t map[TILEMAP_SIZE];
} tilemap_t;

// Converts a single ASCII tile descriptor to 2-byte binary tile
int asc2tile(const char *descriptor, int pal_offset, uint8_t *tile);

// Converts an ASCII string to 2-byte binary ASCII character tiles
int str2tiles(const char *str, int pal_offset, uint8_t *tiles);

// Parses a tile layout tile into a tilemap
int tile_layout(const char *filename, tilemap_t *tilemap);

// Converts a list of ASCII tile descriptors to 2-byte binary tiles
int cfg2tiles(xci_val_list *values, int pal_offset, uint8_t *tiles);

#endif
