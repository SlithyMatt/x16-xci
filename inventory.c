#include "inventory.h"

#define TEXT_STYLE_OFFSET 11
#define MAX_TEXT_STYLE 3

typedef struct inv_list_node {
   char label[MAX_ITEM_LABEL+1];
   struct inv_list *next;
} inv_list_node_t;

inv_list_node_t *inv_list = NULL;

int parse_inv_config(const char* cfg_fn, inventory_config_t *cfg_bin) {
   uint8_t *bin = (uint8_t *)cfg_bin;
   xci_config_t cfg;
   xci_config_node_t *node;
   xci_val_list_t *val;
   int num;
   int size = sizeof(inventory_config_t);
   int width = 0;
   int height = 0;
   xci_config_node_t *inv_empty_node = NULL;
   xci_config_node_t *inv_left_margin_node = NULL;
   xci_config_node_t *inv_right_margin_node = NULL;
   int quant_po = TEXT_STYLE_OFFSET + 1;
   xci_config_node_t *inv_quant_margin_node = NULL;
   uint8_t scroll_up[2];
   uint8_t scroll_middle[2];
   uint8_t scroll_down[2];
   xci_config_node_t *inv_scroll_margin_node = NULL;
   inventory_item_cfg_t *item_cfg;
   inv_list_node_t *last_item = NULL;
   inv_list_node_t *new_item = NULL;

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
            val = val->next;
            height = atoi(val->val);
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
            button_tiles =
            break;
         case INV_EMPTY:
            inv_empty_node = node;
            break;
         case INV_LEFT_MARGIN:
            inv_left_margin_node = node;
            break;
         case INV_RIGHT_MARGIN:
            inv_right_margin_node = node;
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
            inv_quant_margin_node = node;
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
            break;
         case INV_SCROLL_MARGIN:
            inv_scroll_margin_node = node;
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
            strcpy(item_cfg->label,val->val);
            new_item = malloc(sizeof(inv_list_node_t));
            stccpy(new_item->labl, val->val);
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
               printf("parse_inv_config: error parsing tiles for inv_item\n", val->val);
               return -1;
            }
            size += num;
            break;
         default:
            printf("parse_inv_config: WARNING: unexpected key (%s)\n",
                   idx2key(node->key));
      }
      node = node->next;
   }

   // TODO: Build tilemap

   delete_config(&cfg);

   return size;
}

int inv_item_index(const char* label){

}

#endif // INVENTORY_H
