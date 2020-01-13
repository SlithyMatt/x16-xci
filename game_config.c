#include "game_config.h"
#include "config.h"
#include "menu.h"
#include "title_screen.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MAX_GAME_CONFIG_BIN 0x2000

#define PAL_SIZE 32

uint8_t init_pal[16*16*2];

int concat_string_val(const xci_val_list *vals, uint8_t *str) {
   xci_val_list_t *val = vals;
   int i = 0;
   char temp_str[STRING_LEN_MAX*2] = ""; // contain possible overflow

   while (val != NULL) {
      strcat(temp_str, val->val);
      i += strlen(val->val);
      if (val->next != NULL) {
         strcat(temp_str, " ");
         i++;
      }
      if (i > STRING_LEN_MAX) {
         printf("concat_string_val: string too long");
         return -1;
      }
      val = val->next;
   }

   for (i = 0; i < STRING_LEN_MAX; i++) {
      str[i] = (uint8_t)temp_str[i];
   }

   return 0;
}

void fill_pal() {
   int i;
   // copy palette offset 0 to offsets 1-14
   for (i = 16; i < 240; i += 16) {
      memcpy(&init_pal[i], init_pal, 16);
   }
   memset(&init_pal[240], 0, 16); // offset 15 all black
}

int parse_game_config(const char* cfg_fn) {
   xci_config_t cfg;
   xci_config_node_t *node;
   game_config_t *cfg_bin = malloc(MAX_GAME_CONFIG_BIN);
   uint8_t *bin = (uint8_t *)cg_bin;
   menu_config_t *menu_cfg = NULL;
   int menu_size = 0;
   int menu_offset = 0;
   int tb_offset = 0;
   int inv_offset = 0;
   int title_screen_size = 0;
   int title_screen_offset = sizeof(game_config_t) - sizeof(title_screen_config_t);
   int cursor;
   cfg_bin->title_screen[0] = title_screen_offset & 0x00FF;
   cfg_bin->title_screen[1] = (title_screen_offset & 0xFF00) >> 8;
   cfg_bin->menu[0] = 0;
   cfg_bin->menu[1] = 0;
   cfg_bin->toolbar[0] = 0;
   cfg_bin->toolbar[1] = 0;
   cfg_bin->inventory[0] = 0;
   cfg_bin->inventory[1] = 0;

   if (parse_config(cfg_fn, &cfg) == 0) {
      node = cfg.nodes;
      while (node != NULL) {
         switch (node->key) {
            case TITLE:
               if (concat_string_val(node->values, cfg_bin->title) < 0) {
                  printf("parse_game_config: Error parsing game title");
                  return -1;
               }
               break;
            case AUTHOR:
               if (concat_string_val(node->values, cfg_bin->author) < 0) {
                  printf("parse_game_config: Error parsing game author");
                  return -1;
               }
               break;
            case PALETTE:
               if (node->num_values < 1) {
                  printf("parse_game_config: no filename specified for palette\n");
                  return -1
               }
               if (hex2bin(node->values->val, init_pal, PAL_SIZE) < PAL_SIZE) {
                  printf("parse_game_config: %s has insufficient data (%d bytes required)\n",
                         node->values->val, PAL_SIZE);
               }
               fill_pal();
               break;
            case TILES:
               if (node->num_values < 1) {
                  printf("parse_game_config: no filename specified for tiles\n");
                  return -1
               }
               if (hex2bin_file(node->values->val, "TILES.BIN") < 0) {
                  printf("parse_game_config: error parsing tiles file %s\n",
                         node->values->val);
               }
               break;
            case SPRITES:
               if (node->num_values < 1) {
                  printf("parse_game_config: no filename specified for sprites\n");
                  return -1
               }
               if (hex2bin_file(node->values->val, "SPRITES.BIN") < 0) {
                  printf("parse_game_config: error parsing sprites file %s\n",
                         node->values->val);
               }
               break;
            case MENU:
               if (node->num_values < 1) {
                  printf("parse_game_config: no filename specified for menu\n");
                  return -1
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
                  tb_offset = menu_offset + tb_offset;
                  inv_offset = menu_offset + inv_offset;
                  cfg_bin->toolbar[0] = tb_offset & 0x00FF;
                  cfg_bin->toolbar[1] = (tb_offset & 0xFF00) >> 8;
                  cfg_bin->inventory[0] = inv_offset & 0x00FF;
                  cfg_bin->inventory[1] = (inv_offset & 0xFF00) >> 8;
               }
               break;
            case TITLE_SCREEN:
               if (node->num_values < 1) {
                  printf("parse_game_config: no filename specified for menu\n");
                  return -1
               }
               title_screen_size =
                  parse_title_screen_config(node->values->val, cfg_bin->title_screen_cfg);
               if (title_screen_size < 0) {
                  printf("parse_game_config: error parsing title_screen file %s\n",
                         node->values->val);
                  return -1;
               }
               menu_offset = title_screen_offset+title_screen_size;
               if (menu_cfg == NULL) {
                  menu_cfg = &bin[menu_offset];
               } else {
                  memcpy(&bin[menu_offset], menu_cfg);
                  free (menu_cfg);
               }
               cfg_bin->menu[0] = menu_offset & 0x00FF;
               cfg_bin->menu[1] = (menu_offset & 0xFF00) >> 8;
               if (menu_size > 0) {
                  tb_offset = menu_offset + tb_offset;
                  inv_offset = menu_offset + inv_offset;
                  cfg_bin->toolbar[0] = tb_offset & 0x00FF;
                  cfg_bin->toolbar[1] = (tb_offset & 0xFF00) >> 8;
                  cfg_bin->inventory[0] = inv_offset & 0x00FF;
                  cfg_bin->inventory[1] = (inv_offset & 0xFF00) >> 8;
               }
               break;
            case INIT_CURSOR:
               if (node->num_values < 1) {
                  printf("parse_game_config: no value specified for init_cursor\n");
                  return -1
               }
               cursor = atoi(node->values->val);
               cfg_bin->cursor[0] = cursor & 0x00FF;
               cfg_bin->cursor[1] = (cursor & 0xFF00) >> 8;
               break;
            default:
               printf("parse_game_config: WARNING: unexpected key (%s)\n",
                      idx2key(node->key));
         }
         node = node->next;
      }
   }

   // TODO: check for all required keys

   return 0;
}
