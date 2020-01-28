#include "game_config.h"
#include "config.h"
#include "menu.h"
#include "title_screen.h"
#include "hex2bin.h"
#include "zone.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MAX_GAME_CONFIG_BIN 0x3EFF

#define IN_PAL_SIZE 32
#define OUT_PAL_SIZE 512

#define PAL_BIN_FN   "PAL.BIN"
#define MAIN_BIN_FN  "MAIN.BIN"

uint8_t init_pal[OUT_PAL_SIZE];

void fill_pal() {
   int i;
   // copy palette offset 0 to offsets 1-14
   for (i = 32; i < 480; i += 32) {
      memcpy(&init_pal[i], init_pal, 32);
   }
   memset(&init_pal[480], 0, 32); // offset 15 all black
}

int parse_game_config(const char *cfg_fn) {
   xci_config_t cfg;
   xci_config_node_t *node;
   game_config_t *cfg_bin = malloc(MAX_GAME_CONFIG_BIN);
   uint8_t *bin = (uint8_t *)cfg_bin;
   menu_config_t *menu_cfg = NULL;
   int menu_size = 0;
   int menu_offset = 0;
   int tb_offset = 0;
   int inv_offset = 0;
   int title_screen_size = 0;
   int title_screen_offset = sizeof(game_config_t) - sizeof(title_screen_config_t);
   int num;
   FILE *ofp;

   cfg_bin->menu[0] = 0;
   cfg_bin->menu[1] = 0;
   cfg_bin->toolbar[0] = 0;
   cfg_bin->toolbar[1] = 0;
   cfg_bin->inventory[0] = 0;
   cfg_bin->inventory[1] = 0;

   if (parse_config(cfg_fn, &cfg) < 0) {
      printf("parse_game_config: error parsing config source (%s)\n", cfg_fn);
   }
   node = cfg.nodes;
   while (node != NULL) {
      switch (node->key) {
         case TITLE:
            if (concat_string_val(node->values, cfg_bin->title, STRING_LEN_MAX) < 0) {
               printf("parse_game_config: Error parsing game title");
               return -1;
            }
            break;
         case AUTHOR:
            if (concat_string_val(node->values, cfg_bin->author, STRING_LEN_MAX) < 0) {
               printf("parse_game_config: Error parsing game author");
               return -1;
            }
            break;
         case PALETTE_HEX:
            if (node->num_values < 1) {
               printf("parse_game_config: no filename specified for palette\n");
               return -1;
            }
            if (hex2bin(node->values->val, init_pal, IN_PAL_SIZE) < IN_PAL_SIZE) {
               printf("parse_game_config: %s has insufficient data (%d bytes required)\n",
                      node->values->val, IN_PAL_SIZE);
            }
            fill_pal();
            break;
         case TILES_HEX:
            if (node->num_values < 1) {
               printf("parse_game_config: no filename specified for tiles\n");
               return -1;
            }
            if (hex2bin_file(node->values->val, "TILES.BIN") < 0) {
               printf("parse_game_config: error parsing tiles file %s\n",
                      node->values->val);
            }
            break;
         case SPRITES_HEX:
            if (node->num_values < 1) {
               printf("parse_game_config: no filename specified for sprites\n");
               return -1;
            }
            if (hex2bin_file(node->values->val, "SPRITES.BIN") < 0) {
               printf("parse_game_config: error parsing sprites file %s\n",
                      node->values->val);
            }
            break;
         case MENU_XCI:
            if (node->num_values < 1) {
               printf("parse_game_config: no filename specified for menu\n");
               return -1;
            }
            if (menu_cfg == NULL) {
               menu_cfg = malloc(MAX_GAME_CONFIG_BIN);
            }
            menu_size = parse_menu_config(node->values->val, menu_cfg,
                                          &tb_offset, &inv_offset);
            if (menu_size < 0) {
               printf("parse_game_config: error parsing menu file %s\n",
                      node->values->val);
               return -1;
            }
            if (menu_offset > 0) {
               if ((menu_offset + menu_size) > MAX_GAME_CONFIG_BIN) {
                  printf("parse_game_config: config too large\n");
                  return -1;
               }
               tb_offset = menu_offset + tb_offset;
               inv_offset = menu_offset + inv_offset;
               num = cfg_bin->menu[0] + menu_cfg->controls[0];
               menu_cfg->controls[0] = num & 0x00FF;
               menu_cfg->controls[1] = cfg_bin->menu[1] + menu_cfg->controls[1] + (num >> 8);
               num = cfg_bin->menu[0] + menu_cfg->about[0];
               menu_cfg->about[0] = num & 0x00FF;
               menu_cfg->about[1] = cfg_bin->menu[1] + menu_cfg->about[1] + (num >> 8);
               cfg_bin->toolbar[0] = tb_offset & 0x00FF;
               cfg_bin->toolbar[1] = (tb_offset & 0xFF00) >> 8;
               cfg_bin->inventory[0] = inv_offset & 0x00FF;
               cfg_bin->inventory[1] = (inv_offset & 0xFF00) >> 8;
            }
            break;
         case TITLE_SCREEN:
            if (node->num_values < 1) {
               printf("parse_game_config: no filename specified for menu\n");
               return -1;
            }
            title_screen_size =
               parse_title_screen_config(node->values->val, &cfg_bin->title_screen_cfg);
            if (title_screen_size < 0) {
               printf("parse_game_config: error parsing title_screen file %s\n",
                      node->values->val);
               return -1;
            }
            menu_offset = title_screen_offset+title_screen_size;
            if (menu_cfg == NULL) {
               menu_cfg = (menu_config_t *)&bin[menu_offset];
            } else {
               memcpy(&bin[menu_offset], menu_cfg, menu_size);
               free (menu_cfg);
               menu_cfg = (menu_config_t *)&bin[menu_offset];
            }
            cfg_bin->menu[0] = menu_offset & 0x00FF;
            cfg_bin->menu[1] = (menu_offset & 0xFF00) >> 8;
            if (menu_size > 0) {
               if ((menu_offset + menu_size) > MAX_GAME_CONFIG_BIN) {
                  printf("parse_game_config: config too large\n");
                  return -1;
               }
               tb_offset = menu_offset + tb_offset;
               inv_offset = menu_offset + inv_offset;
               num = cfg_bin->menu[0] + menu_cfg->controls[0];
               menu_cfg->controls[0] = num & 0x00FF;
               menu_cfg->controls[1] = cfg_bin->menu[1] + menu_cfg->controls[1] + (num >> 8);
               num = cfg_bin->menu[0] + menu_cfg->about[0];
               menu_cfg->about[0] = num & 0x00FF;
               menu_cfg->about[1] = cfg_bin->menu[1] + menu_cfg->about[1] + (num >> 8);
               cfg_bin->toolbar[0] = tb_offset & 0x00FF;
               cfg_bin->toolbar[1] = (tb_offset & 0xFF00) >> 8;
               cfg_bin->inventory[0] = inv_offset & 0x00FF;
               cfg_bin->inventory[1] = (inv_offset & 0xFF00) >> 8;
            }
            break;
         case INIT_CURSOR:
            if (node->num_values < 1) {
               printf("parse_game_config: no value specified for init_cursor\n");
               return -1;
            }
            init_cursor = atoi(node->values->val);
            cfg_bin->cursor[0] = init_cursor & 0x00FF;
            cfg_bin->cursor[1] = (init_cursor & 0xFF00) >> 8;
            break;
         case ZONE:
            if (node->num_values < 1) {
               printf("parse_game_config: no filename specified for level\n");
               return -1;
            }
            num = parse_zone_config(cfg_bin->zones,node->values->val);
            if (num < 0) {
               printf("parse_game_config: error parsing zone file (%s)\n", node->values->val);
               return -1;
            }
            cfg_bin->zone_levels[cfg_bin->zones] = num;
            cfg_bin->zones++;
            break;
         default:
            printf("parse_game_config: WARNING: unexpected key (%s)\n",
                   idx2key(node->key));
      }
      node = node->next;
   }

   // TODO: check for all required keys

   delete_config(&cfg);

   ofp = fopen(PAL_BIN_FN, "wb");
   if (ofp == NULL) {
      printf("parse_game_config: error writing to %s\n", PAL_BIN_FN);
      return - 1;
   }
   // X16 binary file header
   fputc(0, ofp);
   fputc(0, ofp);
   // Write palette binary file
   fwrite(init_pal, 1, OUT_PAL_SIZE, ofp);
   fclose(ofp);

   ofp = fopen(MAIN_BIN_FN, "wb");
   if (ofp == NULL) {
      printf("parse_game_config: error writing to %s\n", MAIN_BIN_FN);
      return - 1;
   }
   // X16 binary file header
   fputc(0, ofp);
   fputc(0, ofp);
   // Write main binary file
   fwrite(cfg_bin, 1, menu_offset+menu_size, ofp);
   free(cfg_bin);
   fclose(ofp);

   return 0;
}
