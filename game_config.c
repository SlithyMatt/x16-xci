#include "game_config.h"
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define MAX_GAME_CONFIG_BIN 0x2000

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
}

int parse_game_config(const char* cfg_fn) {
   xci_config_t cfg;
   xci_config_node_t *node;
   xci_val_list_t *val;
   uint8_t *bin = malloc(MAX_GAME_CONFIG_BIN);
   int offset = 0;
   game_config_t *cfg_bin = (game_config_t *)bin;

   if (parse_config(cfg_fn, &cfg) == 0) {
      node = cfg.nodes;
      while (node != NULL) {
         switch (node->key) {
            case TITLE:
               if (concat_string_val(node->values, cfg_bin->title) < 0) {
                  printf("parse_game_config: Error parsing game title");
               }
               break;
            case AUTHOR:
               if (concat_string_val(node->values, cfg_bin->author) < 0) {
                  printf("parse_game_config: Error parsing game author");
               }
               break;
         }
         node = node->next;
      }
   }
}
