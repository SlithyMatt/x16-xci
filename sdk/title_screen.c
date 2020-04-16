#include "title_screen.h"
#include "config.h"
#include "game_config.h"
#include "animation.h"
#include "bitmap.h"
#include "vgm2x16opm.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define BITMAP_PAL_OFFSET (16*2)

#define TITLE_BITMAP_FN "TTL_BM.BIN"

int parse_title_screen_config(const char *cfg_fn, title_screen_config_t *cfg_bin) {
   uint8_t *bin = (uint8_t *)cfg_bin;
   int size = 2;
   xci_config_t cfg;
   xci_config_node_t *node;
   xci_val_list_t *val;
   int num;
   int bitmap_defined = 0;

   if (parse_config(cfg_fn, &cfg) < 0) {
      printf("parse_title_screen_config: error parsing config source (%s)\n", cfg_fn);
      return -1;
   }
   node = cfg.nodes;
   while (node != NULL) {
      switch (node->key) {
         case DURATION:
            if (node->num_values < 1) {
               printf("parse_title_screen_config: no value specified for duration\n");
               return -1;
            }
            num = atoi(node->values->val);
            cfg_bin->duration[0] = num & 0x00FF;
            cfg_bin->duration[1] = (num & 0xFF00) >> 8;
            break;
         case BITMAP:
            if (node->num_values < 1) {
               printf("parse_title_screen_config: no filename specified for bitmap\n");
               return -1;
            }
            if (conv_bitmap(node->values->val, TITLE_BITMAP_FN,
                            &init_pal[BITMAP_PAL_OFFSET]) < 0) {
               printf("parse_title_screen_config: error converting bitmap\n");
               return -1;
            }
            bitmap_defined = 1;
            break;
         case MUSIC:
            if (node->num_values < 1) {
               printf("parse_title_screen_config: no filename specified for music\n");
               return -1;
            }
            if (vgm2x16opm_f(node->values->val, "TTL_MUS.BIN") < 0) {
               printf("parse_title_screen_config: error converting music VGM file (%s)\n",
                      node->values->val);
               return -1;
            }
            break;
         case SPRITE_FRAMES:
         case SPRITE:
         case SPRITE_HIDE:
         case TILES:
         case WAIT:
         case SPRITE_MOVE:
            num = parse_animation_node(node, &bin[size]);
            if (num < 0) {
               printf("parse_title_screen_config: error parsing %s\n",
                      idx2key(node->key));
               return -1;
            }
            size += num;
            break;
         default:
            printf("parse_title_screen_config: WARNING: unexpected key (%s)\n",
                   idx2key(node->key));
      }
      node = node->next;
   }

   if (!bitmap_defined) {
      create_black_bitmap(TITLE_BITMAP_FN, 240);
   }

   delete_config(&cfg);

   bin[size++] += END_ANIM;

   return size;
}
