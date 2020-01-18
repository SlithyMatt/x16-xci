#include "animation.h"
#include "tile_layout.h"
#include <stdio.h>
#include <stdlib.h>

#define MAX_SPRITE_FRAMES 31
#define SPRITE_HFLIP 0x40
#define SPRITE_VFLIP 0x80

int parse_animation_node(const xci_config_node_t *node, uint8_t *bin) {
   xci_val_list_t *val = node->values;
   sprite_frames_t *sprite_frames_bin = (sprite_frames_t *)bin;
   sprite_pos_t *sprite_bin = (sprite_pos_t *)bin;
   sprite_hide_t *sprite_hide_bin = (sprite_hide_t *)bin;
   sprite_move_t *sprite_move_bin = (sprite_move_t *)bin;
   wait_t *wait_bin = (wait_t *)bin;
   tile_row_t *tile_row_bin = (tile_row_t *)bin;
   int size = 0;
   int num;
   int pal;
   int i;

   switch (node->key) {
      case SPRITE_FRAMES:
         if (node->num_values < 3) {
            printf("parse_animation_node: sprite_frames requires at least 3 values\n");
            return -1;
         }
         sprite_frames_bin->key = SPRITE_FRAMES;
         sprite_frames_bin->index = atoi(val->val);
         val = val->next;
         sprite_frames_bin->pal_offset = atoi(val->val);
         val = val->next;
         sprite_frames_bin->num_frames = node->num_values - 2;
         if (sprite_frames_bin->num_frames > MAX_SPRITE_FRAMES) {
            printf("parse_animation_node: sprite_frames has too many frames\n");
            return -1;
         }
         size = sizeof(sprite_frames_t);
         while (val != NULL) {
            num = atoi(val->val);
            bin[size++] = num & 0x00FF;
            bin[size] = (num & 0xFF00) >> 8;
            i = 1;
            if (num >= 10) {
               i++;
               if (num >= 100) {
                  i++;
               }
            }
            if (val->val[i] == 'H') {
               bin[size] = bin[size] | SPRITE_HFLIP;
               i++;
               if (val->val[i] == 'V') {
                  bin[size] = bin[size] | SPRITE_VFLIP;
               }
            } else if (val->val[i] == 'V') {
               bin[size] = bin[size] | SPRITE_VFLIP;
               i++;
               if (val->val[i] == 'H') {
                  bin[size] = bin[size] | SPRITE_HFLIP;
               }
            }
            size++;

            val = val->next;
         }
         break;
      case SPRITE:
         if (node->num_values < 3) {
            printf("parse_animation_node: sprite requires 3 values\n");
            return -1;
         }
         sprite_bin->key = SPRITE;
         sprite_bin->index = atoi(val->val);
         val = val->next;
         num = atoi(val->val);
         sprite_bin->x[0] = num & 0x00FF;
         sprite_bin->x[1] = (num & 0xFF00) >> 8;
         val = val->next;
         sprite_bin->y = atoi(val->val);
         size = sizeof(sprite_pos_t);
         break;
      case SPRITE_HIDE:
         if (node->num_values < 1) {
            printf("parse_animation_node: no value specified for sprite_hide");
            return -1;
         }
         sprite_hide_bin->key = SPRITE_HIDE;
         sprite_hide_bin->index = atoi(val->val);
         size = sizeof(sprite_hide_t);
         break;
      case TILES:
         if (node->num_values < 4) {
            printf("parse_animation_node: tiles requires 4 values\n");
            return -1;
         }
         tile_row_bin->key = TILES;
         pal = atoi(val->val);
         val = val->next;
         tile_row_bin->x = atoi(val->val);
         val = val->next;
         tile_row_bin->y = atoi(val->val);
         val = val->next;
         tile_row_bin->width = node->num_values - 3;
         size = sizeof(tile_row_t);
         num = cfg2tiles(val, pal, &bin[size]);
         if (num < 0) {
            printf("parse_animation_node: error parsing tiles values\n");
            return -1;
         }
         size += num;
         break;
      case WAIT:
         if (node->num_values < 1) {
            printf("parse_animation_node: no value specified for wait\n");
            return -1;
         }
         wait_bin->key = WAIT;
         wait_bin->jiffys = atoi(val->val);
         size = sizeof(wait_t);
         break;
      case SPRITE_MOVE:
         if (node->num_values < 5) {
            printf("parse_animation_node: sprite_move requires 5 values\n");
            return -1;
         }
         sprite_move_bin->key = SPRITE_MOVE;
         sprite_move_bin->index = atoi(val->val);
         val = val->next;
         sprite_move_bin->frame_delay = atoi(val->val);
         val = val->next;
         sprite_move_bin->num_frames = atoi(val->val);
         val = val->next;
         sprite_move_bin->x = atoi(val->val);
         val = val->next;
         sprite_move_bin->y = atoi(val->val);
         size = sizeof(sprite_move_t);
         break;
      default:
         printf("parse_animation_node: %s is not an animation key\n", idx2key(node->key));
         return -1;
   }

   return size;
}
