#ifndef ANIMATION_H
#define ANIMATION_H

#include "config.h"
#include <stdint.h>

typedef struct sprite_frames {
   uint8_t key; // must be xci_key_t::SPRITE_FRAMES
   uint8_t index;
   uint8_t pal_offset;
   uint8_t num_frames;
   // followed by num_frames 2-byte sprite frame indexes
} sprite_frames_t;

typedef struct sprite_pos {
   uint8_t key; // must be xci_key_t::SPRITE
   uint8_t index;
   uint8_t x[2];
   uint8_t y;
} sprite_pos_t;

typedef struct sprite_hide {
   uint8_t key; // must be xci_key_t::SPRITE_HIDE
   uint8_t index;
} sprite_hide_t;

typedef struct sprite_debug {
   uint8_t key; // must be xci_key_t::SPRITE_DEBUG
   uint8_t index;
} sprite_debug_t;

typedef struct sprite_move {
   uint8_t key; // must be xci_key_t::SPRITE_MOVE
   uint8_t index;
   uint8_t frame_delay;
   uint8_t num_frames;
   uint8_t x;
   uint8_t y;
} sprite_move_t;

typedef struct xci_wait {
   uint8_t key; // must be xci_key_t::WAIT
   uint8_t jiffys;
} wait_t;

typedef struct tile_row {
   uint8_t key; // must be xci_key_t::TILES
   uint8_t x;
   uint8_t y;
   uint8_t width;
   // followed by width 2-byte tile definitions
} tile_row_t;

int parse_animation_node(const xci_config_node_t *node, uint8_t *bin);

#endif // ANIMATION_H
