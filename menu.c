#include "menu.h"
#include "config.h"
#include "title_screen.h"
#include "inventory.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TOOLBAR_SIZE = 512;
#define MAX_INV_SIZE = 1024;

int parse_menu_config(const char* cfg_fn, menu_cfg *cfg_bin,
                      int *tb_offset, int *inv_offset) {
   uint8_t *bin = (uint8_t *) cfg_bin;
   xci_config_t cfg;
   xci_config_node_t *node;
   uint8_t tb_bin[MAX_TOOLBAR_SIZE];
   toolbar_config_t *tb_config = (toolbar_config_t *)tb_bin;
   uint8_t inv_bin[MAX_INV_SIZE];
   inventory_config_t *inv_config = (inventory_config_t *)inv_bin;
   int size = 0;

   if (parse_config(cfg_fn, &cfg) == 0) {
      node = cfg.nodes;
      while (node != NULL) {
         switch (node->key) {


         }
         node = node->next;
      }
   }

   // TODO: layout data

   return size;
}
