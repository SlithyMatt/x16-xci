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

int parse_title_screen_config(const char *cfg_fn, title_screen_config_t *cfg_bin) {
   uint8_t *bin = (uint8_t *)cfg_bin;
   int size = 2;
   xci_config_t cfg;
   xci_config_node_t *node;
   xci_val_list_t *val;
   int num;
   end_anim_t *end;

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
            if (conv_bitmap(node->values->val, "TTL.BM.BIN",
                            &init_pal[BITMAP_PAL_OFFSET]) < 0) {
               printf("parse_title_screen_config: error converting bitmap\n");
               return -1;
            }
            break;
         case MUSIC:
            if (node->num_values < 1) {
               printf("parse_title_screen_config: no filename specified for music\n");
               return -1;
            }
            if (vgm2x16opm(node->values->val, "TTL.MUS.BIN") < 0) {
               printf("parse_title_screen_config: error converting music VGM file (%s)\n",
                      node->values->val);
               return -1;
            }
            break;
         case SPRITE_FRAMES:
         case SPRITE:
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

   delete_config(&cfg);

   end = (end_anim_t *)&bin[size];
   end->key = END_ANIM;
   end->loops = 0;
   size += sizeof(end_anim_t);

   return size;
}
