#ifndef TILE_LAYOUT_H
#define TILE_LAYOUT_H

#include <stdint.h>

#define TILEMAP_MAX_WIDTH 40
#define TILEMAP_MAX_HEIGHT 25
#define TILEMAP_SIZE (2*TILEMAP_MAX_WIDTH*TILEMAP_MAX_HEIGHT)

typedef struct {
   uint8_t map[TILEMAP_SIZE];
} tilemap_t;

int tile_layout(const char* filename, tilemap_t* tilemap);

#endif
