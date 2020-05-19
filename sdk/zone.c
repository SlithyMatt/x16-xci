#include "zone.h"
#include "config.h"
#include "level.h"
#include "hex2bin.h"
#include <stdio.h>
#include <stdint.h>

#define UPPER_FILE_MAX 31104

int parse_zone_config(int zone, const char *cfg_fn) {
   xci_config_t cfg;
   xci_config_node_t *node;
   int num_levels = 0;
   int tiles_found = 0;
   int sprites_found = 0;
   char bin_fn[13];
   uint8_t buffer[UPPER_FILE_MAX];
   int buf_size;
   FILE *ifp;
   FILE *ofp;

   if (parse_config(cfg_fn, &cfg) < 0) {
      printf("parse_zone_config: error parsing config source (%s)\n", cfg_fn);
      return -1;
   }
   node = cfg.nodes;
   while (node != NULL) {
      switch (node->key) {
         case LEVEL:
            if (node->num_values < 1) {
               printf("parse_zone_config: no filename specified for level\n");
               return -1;
            }
            if (parse_level_config(zone,num_levels,node->values->val) < 0) {
               printf("parse_zone_config: error parsing level config file (%s)\n",
                      node->values->val);
               return -1;
            }
            num_levels++;
            break;
         case TILES_HEX:
            tiles_found = 1;
            sprintf(bin_fn,"%03dTILES.BIN", zone);
            if (hex2bin_file(node->values->val, bin_fn) < 0) {
               printf("parse_game_config: error parsing tiles file %s\n",
                      node->values->val);
               return -1;
            }
            break;
         case SPRITES_HEX:
            sprites_found = 1;
            sprintf(bin_fn,"%03dSPRTS.BIN", zone);
            if (hex2bin_file(node->values->val, bin_fn) < 0) {
               printf("parse_game_config: error parsing tiles file %s\n",
                      node->values->val);
               return -1;
            }
            break;
         default:
            printf("parse_zone_config: WARNING: unexpected key (%s)\n",
                idx2key(node->key));
      }
      node = node->next;
   }

   if (!tiles_found) {
      // copy default upper tiles
      ifp = fopen("TILES.BIN", "rb");
      fseek(ifp,256*32,SEEK_SET);
      sprintf(bin_fn,"%03dTILES.BIN", zone);
      ofp = fopen(bin_fn, "wb");
      buf_size = fread(buffer, sizeof(uint8_t), UPPER_FILE_MAX, ifp);
      fclose(ifp);
      fwrite(buffer, sizeof(uint8_t), buf_size, ofp);
      fclose(ofp);
   }

   if (!sprites_found) {
      // copy default upper sprites
      ifp = fopen("SPRITES.BIN", "rb");
      fseek(ifp,256*128,SEEK_SET);
      sprintf(bin_fn,"%03dSPRTS.BIN", zone);
      ofp = fopen(bin_fn, "wb");
      buf_size = fread(buffer, sizeof(uint8_t), UPPER_FILE_MAX, ifp);
      fclose(ifp);
      fwrite(buffer, sizeof(uint8_t), buf_size, ofp);
      fclose(ofp);
   }

   return num_levels;
}
