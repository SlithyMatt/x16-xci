#include "inventory.h"
#include "config.h"
#include "tile_layout.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define TEXT_STYLE_OFFSET 11
#define MAX_TEXT_STYLE 3

typedef struct inv_list_node {
   char label[MAX_ITEM_LABEL+1];
   struct inv_list_node *next;
} inv_list_node_t;

inv_list_node_t *inv_list = NULL;

int parse_inv_config(const char *cfg_fn, inventory_config_t *cfg_bin) {
   uint8_t *bin = (uint8_t *)cfg_bin;
   xci_config_t cfg;
   xci_config_node_t *node;
   xci_val_list_t *val;
   int num;
   int size = sizeof(inventory_config_t);
   int width = 0;
   int height = 0;
   int num_button_tiles = 0;
   xci_config_node_t *empty_node = NULL;
   uint8_t *empty_tiles = NULL;
   xci_config_node_t *left_margin_node = NULL;
   int num_left_margin_tiles = 0;
   uint8_t *left_margin_tiles = NULL;
   xci_config_node_t *right_margin_node = NULL;
   int num_right_margin_tiles = 0;
   uint8_t *right_margin_tiles = NULL;
   int quant_po = TEXT_STYLE_OFFSET + 1;
   xci_config_node_t *quant_margin_node = NULL;
   int num_quant_margin_tiles = 0;
   uint8_t *quant_margin_tiles = NULL;
   int scroll_width = 0;
   uint8_t scroll_up[2];
   uint8_t scroll_middle[2];
   uint8_t scroll_down[2];
   xci_config_node_t *scroll_margin_node = NULL;
   int num_scroll_margin_tiles = 0;
   uint8_t *scroll_margin_tiles = NULL;
   inventory_item_cfg_t *item_cfg;
   inv_list_node_t *last_item = NULL;
   inv_list_node_t *new_item = NULL;
   int start_x = 0;
   int right_gap = 0;
   int items_per_row;
   int num_rows;
   int row, sub_row;
   int column;
   int tilemap_idx = 0;
   int i;

   if (parse_config(cfg_fn, &cfg) < 0) {
      printf("parse_inv_config: error parsing config source (%s)\n", cfg_fn);
      return -1;
   }
   node = cfg.nodes;
   while (node != NULL) {
      switch (node->key) {
         case INV_DIM:
            if (node->num_values < 2) {
               printf("parse_inv_config: inv_dim requires 2 values\n");
               return -1;
            }
            val = node->values;
            width = atoi(val->val);
            if (width > 40) {
               printf("parse_inv_config: inv_dim width value too high (%d)\n",
                      width);
               return -1;
            }
            val = val->next;
            height = atoi(val->val);
            if (height > 4) {
               printf("parse_inv_config: inv_dim height value too high (%d)\n",
                      height);
               return -1;
            }
            break;
         case INV_ITEM_DIM:
            if (node->num_values < 2) {
               printf("parse_inv_config: inv_item_dim requires 2 values\n");
               return -1;
            }
            val = node->values;
            cfg_bin->item_width = atoi(val->val);
            val = val->next;
            cfg_bin->item_height = atoi(val->val);
            num_button_tiles = cfg_bin->item_width * cfg_bin->item_height;
            break;
         case INV_EMPTY:
            empty_node = node;
            break;
         case INV_LEFT_MARGIN:
            left_margin_node = node;
            num_left_margin_tiles = node->num_values;
            break;
         case INV_RIGHT_MARGIN:
            right_margin_node = node;
            num_right_margin_tiles = node->num_values;
            break;
         case INV_QUANT:
            if (node->num_values < 2) {
               printf("parse_inv_config: inv_quant requires 2 values\n");
               return -1;
            }
            val = node->values;
            quant_po = TEXT_STYLE_OFFSET + atoi(val->val);
            if (quant_po > TEXT_STYLE_OFFSET + MAX_TEXT_STYLE) {
               printf("parse_inv_config: inv_quant has invalid text style number\n");
               return -1;
            }
            val = val->next;
            cfg_bin->item_quant_width = atoi(val->val);
            break;
         case INV_QUANT_MARGIN:
            quant_margin_node = node;
            num_quant_margin_tiles = node->num_values;
            break;
         case INV_SCROLL:
            if (node->num_values < 3) {
               printf("parse_inv_config: inv_scroll requires 3 values\n");
               return -1;
            }
            val = node->values;
            if (asc2tile(val->val, 0, scroll_up) < 0) {
               printf("parse_inv_config: inv_scroll has invalid scroll up tile (%s)\n",
                      val->val);
               return -1;
            }
            val = val->next;
            if (asc2tile(val->val, 0, scroll_middle) < 0) {
               printf("parse_inv_config: inv_scroll has invalid scroll middle tile (%s)\n",
                      val->val);
               return -1;
            }
            val = val->next;
            if (asc2tile(val->val, 0, scroll_down) < 0) {
               printf("parse_inv_config: inv_scroll has invalid scroll down tile (%s)\n",
                      val->val);
               return -1;
            }
            scroll_width++;
            break;
         case INV_SCROLL_MARGIN:
            scroll_margin_node = node;
            num_scroll_margin_tiles = node->num_values;
            scroll_width += num_scroll_margin_tiles;
            break;
         case INV_ITEM:
            if (node->num_values < 5) {
               printf("parse_inv_config: inv_item requires at least 5 values\n");
               return -1;
            }
            val = node->values;
            if (strlen(val->val) > MAX_ITEM_LABEL) {
               printf("parse_inv_config: inv_item label too long (%s)\n", val->val);
               return -1;
            }
            item_cfg = (inventory_item_cfg_t *)&bin[size];
            strcpy(item_cfg->label, val->val);
            new_item = malloc(sizeof(inv_list_node_t));
            strcpy(new_item->label, val->val);
            new_item->next = NULL;
            if (last_item == NULL) {
               inv_list = new_item;
            } else {
               last_item->next = new_item;
            }
            last_item = new_item;
            val = val->next;
            num = atoi(val->val);
            item_cfg->init[0] = num & 0x00FF;
            item_cfg->init[1] = (num & 0xFF00) >> 8;
            val = val->next;
            num = atoi(val->val);
            item_cfg->max[0] = num & 0x00FF;
            item_cfg->max[1] = (num & 0xFF00) >> 8;
            val = val->next;
            num = atoi(val->val);
            item_cfg->cursor[0] = num & 0x00FF;
            item_cfg->cursor[1] = (num & 0xFF00) >> 8;
            size += sizeof(inventory_item_cfg_t);
            val = val->next;
            num = cfg2tiles(val,0,&bin[size]);
            if (num < 0) {
               printf("parse_inv_config: error parsing tiles for inv_item %s\n",
                      item_cfg->label);
               return -1;
            } else if (num != num_button_tiles * 2) {
               printf("parse_inv_config: inv_item %s has the wrong number of tiles\n",
                      item_cfg->label);
               return -1;
            }
            cfg_bin->num_items++;
            size += num;
            break;
         default:
            printf("parse_inv_config: WARNING: unexpected key (%s)\n",
                   idx2key(node->key));
      }
      node = node->next;
   }

   // TODO - check for required keys

   if (cfg_bin->item_height > height) {
      printf("parse_inv_config: inv_item_dim height (%d) exceeds inv_dim height (%d)\n",
             cfg_bin->item_height, height);
      return -1;
   }

   if (empty_node->num_values != num_button_tiles) {
      printf("parse_inv_config: inv_empty has the wrong number of tiles\n");
      return -1;
   }

   if (num_scroll_margin_tiles != scroll_width - 1) {
      printf("parse_inv_config: inv_scroll_margin defined without inv_scroll\n");
      return -1;
   }

   cfg_bin->item_step_x = num_left_margin_tiles + cfg_bin->item_width +
                          num_right_margin_tiles + cfg_bin->item_quant_width;

   if ((cfg_bin->item_step_x + scroll_width) > width) {
      printf("parse_inv_config: total width of inventory (%d) can't fit single item (%d)\n",
             width, cfg_bin->item_step_x + scroll_width);
      return -1;
   }

   if (num_quant_margin_tiles > cfg_bin->item_quant_width) {
      printf("parse_inv_config: inv_quant_margin tile count exceeds inv_quant width\n");
      return -1;
   }

   if ((cfg_bin->item_quant_width > 0) && (cfg_bin->item_height > 1) &&
       (num_quant_margin_tiles < 1)) {
      printf("parse_inv_config: inv_quant defined without inv_quant_margin to meet item_dim height\n");
   }

   empty_tiles = malloc(num_button_tiles*2);
   if (cfg2tiles(empty_node->values, 0, empty_tiles) < 0) {
      printf("parse_inv_config: error parsing inv_empty tiles\n");
      return -1;
   }

   if (num_left_margin_tiles > 0) {
      left_margin_tiles = malloc(num_left_margin_tiles*2);
      if (cfg2tiles(left_margin_node->values, 0, left_margin_tiles) < 0) {
         printf("parse_inv_config: error parsing inv_left_margin tiles\n");
         return -1;
      }
   }

   if (num_right_margin_tiles > 0) {
      right_margin_tiles = malloc(num_right_margin_tiles*2);
      if (cfg2tiles(right_margin_node->values, 0, right_margin_tiles) < 0) {
         printf("parse_inv_config: error parsing inv_right_margin tiles\n");
         return -1;
      }
   }

   if (num_quant_margin_tiles > 0) {
      quant_margin_tiles = malloc(num_quant_margin_tiles*2);
      if (cfg2tiles(quant_margin_node->values, 0, quant_margin_tiles) < 0) {
         printf("parse_inv_config: error parsing inv_quant_margin tiles\n");
         return -1;
      }
   }

   if (num_scroll_margin_tiles > 0) {
      scroll_margin_tiles = malloc(num_scroll_margin_tiles*2);
      if (cfg2tiles(scroll_margin_node->values, 0, scroll_margin_tiles) < 0) {
         printf("parse_inv_config: error parsing inv_scroll_margin tiles\n");
         return -1;
      }
   }

   items_per_row = (width - scroll_width) / cfg_bin->item_step_x;
   width = items_per_row * cfg_bin->item_step_x + scroll_width;
   start_x = (40 - width) / 2;
   right_gap = 40 - (width + start_x);

   cfg_bin->item_start_x = start_x + num_left_margin_tiles;
   cfg_bin->item_quant_x = cfg_bin->item_width + num_right_margin_tiles;

   height -= height % cfg_bin->item_height;
   cfg_bin->start_y = 30 - height;
   num_rows = height / cfg_bin->item_height;

   for (row = 0; row < num_rows; row++) {
      for (sub_row = 0; sub_row < (cfg_bin->item_height - 1); sub_row++) {
         for (i = 0; i < start_x*2; i++) {
            // Transparent tiles
            cfg_bin->tilemap[tilemap_idx++] = 0;
         }
         for (column = 0; column < items_per_row; column++) {
            for (i = 0; i < num_left_margin_tiles*2; i++) {
               cfg_bin->tilemap[tilemap_idx++] = left_margin_tiles[i];
            }
            for (i = 0; i < cfg_bin->item_width*2; i++) {
               cfg_bin->tilemap[tilemap_idx++] = empty_tiles[sub_row*2*cfg_bin->item_width + i];
            }
            for (i = 0; i < num_right_margin_tiles*2; i++) {
               cfg_bin->tilemap[tilemap_idx++] = right_margin_tiles[i];
            }
            for (i = 0; i < cfg_bin->item_quant_width; i++) {
               cfg_bin->tilemap[tilemap_idx++] = quant_margin_tiles[(i % num_quant_margin_tiles)*2];
               cfg_bin->tilemap[tilemap_idx++] = quant_margin_tiles[(i % num_quant_margin_tiles)*2 + 1];
            }
         }
         for (i = 0; i < num_scroll_margin_tiles*2; i++) {
            cfg_bin->tilemap[tilemap_idx++] = scroll_margin_tiles[i];
         }
         if ((row == 0) && (sub_row == 0)) {
            cfg_bin->tilemap[tilemap_idx++] = scroll_up[0];
            cfg_bin->tilemap[tilemap_idx++] = scroll_up[1];
         } else {
            cfg_bin->tilemap[tilemap_idx++] = scroll_middle[0];
            cfg_bin->tilemap[tilemap_idx++] = scroll_middle[1];
         }
         for (i = 0; i < right_gap*2; i++) {
            // Transparent tiles
            cfg_bin->tilemap[tilemap_idx++] = 0;
         }
      }
      for (i = 0; i < start_x*2; i++) {
         // Transparent tiles
         cfg_bin->tilemap[tilemap_idx++] = 0;
      }
      for (column = 0; column < items_per_row; column++) {
         for (i = 0; i < num_left_margin_tiles*2; i++) {
            cfg_bin->tilemap[tilemap_idx++] = left_margin_tiles[i];
         }
         for (i = 0; i < cfg_bin->item_width*2; i++) {
            cfg_bin->tilemap[tilemap_idx++] =
               empty_tiles[(cfg_bin->item_height-1)*2*cfg_bin->item_width + i];
         }
         for (i = 0; i < num_right_margin_tiles*2; i++) {
            cfg_bin->tilemap[tilemap_idx++] = right_margin_tiles[i];
         }
         for (i = 0; i < cfg_bin->item_quant_width; i++) {
            cfg_bin->tilemap[tilemap_idx++] = 0x20;
            cfg_bin->tilemap[tilemap_idx++] = quant_po << 4;
         }
      }
      for (i = 0; i < num_scroll_margin_tiles*2; i++) {
         cfg_bin->tilemap[tilemap_idx++] = scroll_margin_tiles[i];
      }
      if (row == (num_rows - 1)) {
         cfg_bin->tilemap[tilemap_idx++] = scroll_down[0];
         cfg_bin->tilemap[tilemap_idx++] = scroll_down[1];
      } else {
         cfg_bin->tilemap[tilemap_idx++] = scroll_middle[0];
         cfg_bin->tilemap[tilemap_idx++] = scroll_middle[1];
      }
      for (i = 0; i < right_gap*2; i++) {
         // Transparent tiles
         cfg_bin->tilemap[tilemap_idx++] = 0;
      }
   }

   free(empty_tiles);
   free(left_margin_tiles);
   free(right_margin_tiles);
   free(quant_margin_tiles);
   free(scroll_margin_tiles);
   delete_config(&cfg);

   return size;
}

int inv_item_index(const char* label){
   char label_lc[MAX_ITEM_LABEL+1];
   inv_list_node_t *node = inv_list;
   int i = 0;

   strn_tolower(label_lc,MAX_ITEM_LABEL+1,label);
   while (node != NULL) {
      if (strcmp(label_lc,node->label) == 0) {
         return i;
      }
      node = node->next;
      i++;
   }

   return -1;
}

void delete_inv_list_node(inv_list_node_t *node) {
   if (node != NULL) {
      delete_inv_list_node(node->next);
      free(node);
   }
}

void delete_inv_list() {
   delete_inv_list_node(inv_list);
}
