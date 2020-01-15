#include "menu.h"
#include "game_config.h"
#include "config.h"
#include "inventory.h"
#include "tile_layout.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TOOLBAR_SIZE 512
#define MAX_INV_SIZE 1024

#define PO_SIZE (16*2)

#define MENU_PO_IDX 11
#define TEXT1_PO_IDX 12
#define TEXT2_PO_IDX 13
#define TEXT3_PO_IDX 14

#define MENU_PO (MENU_PO_IDX*PO_SIZE)
#define TEXT1_PO (TEXT1_PO_IDX*PO_SIZE)
#define TEXT2_PO (TEXT2_PO_IDX*PO_SIZE)
#define TEXT3_PO (TEXT3_PO_IDX*PO_SIZE)

#define TEXT_BG (6*2)
#define TEXT_FG (1*2)

#define MENU_BAR_LC 0
#define FIRST_MENU_HEADER 2
#define MENU_BAR_RC 78

#define MAX_MENU_ITEM_LABEL 10
#define MAX_TOOLBAR_LABEL 10

int init_cursor = 0;

const char menu_item_labels[NUM_MENU_ITEMS][MAX_MENU_ITEM_LABEL] = {
   "div",
   "new",
   "load",
   "save",
   "saveas",
   "exit",
   "music",
   "sfx",
   "controls",
   "about"
};

const char toolbar_labels[NUM_TOOLS][MAX_TOOLBAR_LABEL] = {
   "inventory",
   "walk",
   "run",
   "look",
   "use",
   "talk",
   "strike",
   "pin"
};

toolbar_action_t tool2idx(const char *tool_label) {
   char label_lc[MAX_TOOLBAR_LABEL];
   int i = 0;
   int cmp = -1;

   strn_tolower(label_lc, MAX_TOOLBAR_LABEL, tool_label);

   i = 0;
   while ((i < NUM_TOOLS) && cmp) {
      cmp = strcmp(label_lc,toolbar_labels[i]);
      if (cmp) {
         i++;
      }
   }

   if (cmp) {
      i = -1;
   }

   return i;
}


int parse_menu_config(const char *cfg_fn, menu_config_t *cfg_bin,
                      int *tb_offset, int *inv_offset) {
   uint8_t *bin = (uint8_t *) cfg_bin;
   xci_config_t cfg;
   xci_config_node_t *node;
   xci_val_list_t *val;
   uint8_t tb_bin[MAX_TOOLBAR_SIZE];
   toolbar_config_t *tb_cfg = (toolbar_config_t *)tb_bin;
   int tb_size = sizeof(toolbar_config_t);
   uint8_t inv_bin[MAX_INV_SIZE];
   inventory_config_t *inv_cfg = (inventory_config_t *)inv_bin;
   int inv_size = 0;
   int size = sizeof(menu_config_t);
   int num;
   int menu_header_idx = FIRST_MENU_HEADER;
   menu_header_t *last_menu_header = NULL;
   int menu_item;
   tilemap_t controls;
   int controls_inc = 0;
   tilemap_t about;
   int about_inc = 0;
   int tb_width = 0;
   int tb_height = 0;
   char menu_label[MAX_MENU_ITEM_LABEL];
   toolbar_button_t tb_button;
   int buttons_expected = 0;

   memset(cfg_bin,0,sizeof(menu_config_t));
   memset(tb_cfg,0,sizeof(toolbar_config_t));
   memset(inv_cfg,0,sizeof(inventory_config_t));

   if (parse_config(cfg_fn, &cfg) < 0) {
      printf("parse_menu_config: error parsing config source (%s)\n", cfg_fn);
      return -1;
   }
   node = cfg.nodes;
   while (node != NULL) {
      switch (node->key) {
         case MENU_BG:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_bg\n");
               return -1;
            }
            num = atoi(node->values->val);
            init_pal[MENU_PO+TEXT_BG] = init_pal[num*2];
            init_pal[MENU_PO+TEXT_BG+1] = init_pal[num*2+1];
            break;
         case MENU_FG:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_fg\n");
               return -1;
            }
            num = atoi(node->values->val);
            init_pal[MENU_PO+TEXT_FG] = init_pal[num*2];
            init_pal[MENU_PO+TEXT_FG+1] = init_pal[num*2+1];
            break;
         case MENU_LC:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_lc\n");
               return -1;
            }
            if (asc2tile(node->values->val, 0, &cfg_bin->bar[MENU_BAR_LC]) < 0) {
               printf("parse_menu_config: error parsing tile for menu_lc\n");
               return -1;
            }
            break;
         case MENU_SP:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_sp\n");
               return -1;
            }
            if (asc2tile(node->values->val, 0, cfg_bin->space) < 0) {
               printf("parse_menu_config: error parsing tile for menu_sp\n");
               return -1;
            }
            break;
         case MENU_RC:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_rc\n");
               return -1;
            }
            if (asc2tile(node->values->val, 0, &cfg_bin->bar[MENU_BAR_RC]) < 0) {
               printf("parse_menu_config: error parsing tile for menu_rc\n");
               return -1;
            }
            break;
         case MENU_DIV:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_div\n");
               return -1;
            }
            if (asc2tile(node->values->val, 0, cfg_bin->div) < 0) {
               printf("parse_menu_config: error parsing tile for menu_div\n");
               return -1;
            }
            break;
         case MENU_CHECK:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_check\n");
               return -1;
            }
            if (asc2tile(node->values->val, 0, cfg_bin->check) < 0) {
               printf("parse_menu_config: error parsing tile for menu_check\n");
               return -1;
            }
            break;
         case MENU_UNCHECK:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_uncheck\n");
               return -1;
            }
            if (asc2tile(node->values->val, 0, cfg_bin->uncheck) < 0) {
               printf("parse_menu_config: error parsing tile for menu_uncheck\n");
               return -1;
            }
            break;
         case MENU:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu\n");
               return -1;
            }
            cfg_bin->num_menus++;
            menu_header_idx += str2tiles(node->values->val, MENU_PO_IDX,
                                        &cfg_bin->bar[menu_header_idx]);
            cfg_bin->bar[menu_header_idx++] = cfg_bin->space[0];
            cfg_bin->bar[menu_header_idx++] = cfg_bin->space[1];
            cfg_bin->bar[menu_header_idx++] = cfg_bin->space[0];
            cfg_bin->bar[menu_header_idx++] = cfg_bin->space[1];
            last_menu_header = (menu_header_t *)&bin[size];
            last_menu_header->num_items = 0;
            size++;
            break;
         case MENU_ITEM:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for menu_item\n");
               return -1;
            }
            menu_item = 0;
            strn_tolower(menu_label, MAX_MENU_ITEM_LABEL, node->values->val);
            while (menu_item != NUM_MENU_ITEMS) {
               if (strcmp(menu_item_labels[menu_item], menu_label) == 0) {
                  break;
               }
               menu_item++;
            }
            if (menu_item == NUM_MENU_ITEMS) {
               printf("parse_menu_config: unrecognized menu item (%s)\n",
                      node->values->val);
               return -1;
            }
            last_menu_header->num_items++;
            bin[size++] = menu_item;
            break;
         case CONTROLS:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for controls\n");
               return -1;
            }
            if (tile_layout(node->values->val, &controls) < 0) {
               printf("parse_menu_config: error parsing controls file (%s)\n",
                      node->values->val);
               return -1;
            }
            controls_inc = 1;
            break;
         case ABOUT:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for about\n");
               return -1;
            }
            if (tile_layout(node->values->val, &about) < 0) {
               printf("parse_menu_config: error parsing about file (%s)\n",
                      node->values->val);
               return -1;
            }
            about_inc = 1;
            break;
         case TEXT1_BG:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for text1_bg\n");
               return -1;
            }
            num = atoi(node->values->val);
            init_pal[TEXT1_PO+TEXT_BG] = init_pal[num*2];
            init_pal[TEXT1_PO+TEXT_BG+1] = init_pal[num*2+1];
            break;
         case TEXT1_FG:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for text1_fg\n");
               return -1;
            }
            num = atoi(node->values->val);
            init_pal[TEXT1_PO+TEXT_FG] = init_pal[num*2];
            init_pal[TEXT1_PO+TEXT_FG+1] = init_pal[num*2+1];
            break;
         case TEXT2_BG:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for text2_bg\n");
               return -1;
            }
            num = atoi(node->values->val);
            init_pal[TEXT2_PO+TEXT_BG] = init_pal[num*2];
            init_pal[TEXT2_PO+TEXT_BG+1] = init_pal[num*2+1];
            break;
         case TEXT2_FG:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for text2_fg\n");
               return -1;
            }
            num = atoi(node->values->val);
            init_pal[TEXT2_PO+TEXT_FG] = init_pal[num*2];
            init_pal[TEXT2_PO+TEXT_FG+1] = init_pal[num*2+1];
            break;
         case TEXT3_BG:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for text3_bg\n");
               return -1;
            }
            num = atoi(node->values->val);
            init_pal[TEXT3_PO+TEXT_BG] = init_pal[num*2];
            init_pal[TEXT3_PO+TEXT_BG+1] = init_pal[num*2+1];
            break;
         case TEXT3_FG:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for text3_fg\n");
               return -1;
            }
            num = atoi(node->values->val);
            init_pal[TEXT3_PO+TEXT_FG] = init_pal[num*2];
            init_pal[TEXT3_PO+TEXT_FG+1] = init_pal[num*2+1];
            break;
         case TB_DIM:
            if (node->num_values < 2) {
               printf("parse_menu_config: too few values defined for tb_dim (2 required)\n");
               return -1;
            }
            val = node->values;
            tb_width = atoi(val->val);
            if ((tb_width < 1) || (tb_width > 40)) {
               printf("parse_menu_config: illegal value for tb_dim width (%d)\n",
                      tb_width);
            }
            val = val->next;
            tb_height = atoi(val->val);
            if ((tb_height < 1) || (tb_height > 4)) {
               printf("parse_menu_config: illegal value for tb_dim height (%d)\n",
                      tb_height);
            }
            tb_cfg->start_x = (40 - tb_width)/2;
            tb_cfg->start_y = 30 - tb_height;
            tb_button.start_x = tb_cfg->start_x;
            break;
         case TOOL:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for tool\n");
               return -1;
            }
            tb_button.action = tool2idx(node->values->val);
            if (tb_button.action == -1) {
               printf("parse_menu_config: unexpected tool label (%s)\n",
                      node->values->val);
               return -1;
            }
            tb_cfg->num_tools++;
            tb_button.end_x = 0;
            if (tb_button.action == PIN_TOOLBAR) {
               buttons_expected = 2;
            } else {
               buttons_expected = 1;
            }
            break;
         case TOOL_TILES:
            if (buttons_expected < 1) {
               printf("parse_menu_config: unexpected tool_tiles\n");
               return -1;
            }
            if ((node->num_values % tb_height) != 0) {
               printf("parse_menu_config: invalid tool_tiles\n");
               printf("  tile count must be multiple of toolbar height (%d)\n",
                      tb_height);
               return -1;
            }
            buttons_expected--;
            if (tb_button.end_x > 0) {
               if (node->num_values !=
                   (tb_button.end_x - tb_button.start_x + 1) * tb_height) {
                  printf("parse_menu_config: alternate tool_tiles different size than last\n");
                  return -1;
               }
            } else {
               tb_button.end_x = tb_button.start_x +
                                 node->num_values / tb_height - 1;
               if ((tb_button.end_x - tb_cfg->start_x + 1) > tb_width) {
                  printf("parse_menu_config: toolbar buttons exceed toolbar width\n");
                  return -1;
               }
               memcpy(&tb_bin[tb_size],&tb_button,sizeof(toolbar_button_t));
               tb_size += sizeof(toolbar_button_t);
            }
            num = cfg2tiles(node->values, 0, &tb_bin[tb_size]);
            if (num < 0) {
               printf("parse_menu_config: error building tiles from tool_tiles\n");
               return -1;
            }
            tb_size += num;
            if (buttons_expected == 0) {
               tb_button.start_x = tb_button.end_x + 1;
            }
            break;
         case INVENTORY:
            if (node->num_values < 1) {
               printf("parse_menu_config: no filename specified for inventory\n");
               return -1;
            }
            inv_size = parse_inv_config(node->values->val, inv_cfg);
            if (inv_size < 0) {
               printf("parse_menu_config: error parsing inventory file (%s)\n",
                      node->values->val);
               return -1;
            }
            break;
         case WALK_CURSOR:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for walk\n");
               return -1;
            }
            num = atoi(node->values->val);
            tb_cfg->walk_cursor[0] = num & 0x00FF;
            tb_cfg->walk_cursor[1] = (num & 0xFF00) >> 8;
            break;
         case RUN_CURSOR:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for run\n");
               return -1;
            }
            num = atoi(node->values->val);
            tb_cfg->run_cursor[0] = num & 0x00FF;
            tb_cfg->run_cursor[1] = (num & 0xFF00) >> 8;
            break;
         case LOOK_CURSOR:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for look\n");
               return -1;
            }
            num = atoi(node->values->val);
            tb_cfg->look_cursor[0] = num & 0x00FF;
            tb_cfg->look_cursor[1] = (num & 0xFF00) >> 8;
            break;
         case USE_CURSOR:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for use\n");
               return -1;
            }
            num = atoi(node->values->val);
            tb_cfg->use_cursor[0] = num & 0x00FF;
            tb_cfg->use_cursor[1] = (num & 0xFF00) >> 8;
            break;
         case TALK_CURSOR:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for talk\n");
               return -1;
            }
            num = atoi(node->values->val);
            tb_cfg->talk_cursor[0] = num & 0x00FF;
            tb_cfg->talk_cursor[1] = (num & 0xFF00) >> 8;
            break;
         case STRIKE_CURSOR:
            if (node->num_values < 1) {
               printf("parse_menu_config: no value specified for strike\n");
               return -1;
            }
            num = atoi(node->values->val);
            tb_cfg->strike_cursor[0] = num & 0x00FF;
            tb_cfg->strike_cursor[1] = (num & 0xFF00) >> 8;
            break;
         default:
            printf("parse_menu_config: WARNING: unexpected key (%s)\n",
                   idx2key(node->key));
      }
      node = node->next;
   }

   // TODO - check for required keys

   // fill out remaining menu bar with space tiles
   while (menu_header_idx < MENU_BAR_RC) {
      cfg_bin->bar[menu_header_idx++] = cfg_bin->space[0];
      cfg_bin->bar[menu_header_idx++] = cfg_bin->space[1];
   }

   delete_config(&cfg);

   if (controls_inc) {
      cfg_bin->controls[0] = size & 0x00FF;
      cfg_bin->controls[1] = (size & 0xFF00) >> 8;
      memcpy(&bin[size],&controls,sizeof(tilemap_t));
      size += sizeof(tilemap_t);
   }

   if (about_inc) {
      cfg_bin->about[0] = size & 0x00FF;
      cfg_bin->about[1] = (size & 0xFF00) >> 8;
      memcpy(&bin[size],&about,sizeof(tilemap_t));
      size += sizeof(tilemap_t);
   }

   *tb_offset = size;
   memcpy(&bin[size],tb_bin,tb_size);
   size += tb_size;
   *inv_offset = size;
   memcpy(&bin[size],inv_bin,inv_size);
   size += inv_size;

   return size;
}
