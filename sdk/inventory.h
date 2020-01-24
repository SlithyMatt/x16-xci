#ifndef INVENTORY_H
#define INVENTORY_H

#include <stdint.h>

#define MAX_ITEM_LABEL 16

typedef struct inventory_config {
   uint8_t start_x;
   uint8_t start_y;
   uint8_t tilemap[40*4*2];
   uint8_t num_items;
   uint8_t item_rows;
   uint8_t item_columns;
   uint8_t item_width;
   uint8_t item_height;
   uint8_t item_start_x;
   uint8_t item_step_x;
   uint8_t item_quant_x; // relative to button, no quant field if zero
   uint8_t item_quant_width;
   uint8_t scroll_x;
   // followed by num_items * inventory_item_cfg_t
} inventory_config_t;

typedef struct inventory_item_cfg {
   uint8_t label[MAX_ITEM_LABEL];
   uint8_t init[2];
   uint8_t max[2];
   uint8_t cursor[2];
   // followed by item button tilemap, sized by inventory_config_t::item_width,item_height
} inventory_item_cfg_t;

// cfg_bin nneds to be allocated to be big enough for variable-length data and
// have all header fields set to zero.
int parse_inv_config(const char* cfg_fn, inventory_config_t *cfg_bin);

int inv_item_index(const char* label);

void delete_inv_list();

#endif // INVENTORY_H
