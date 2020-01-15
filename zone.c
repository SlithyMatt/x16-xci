#include "zone.h"
#include "config.h"
#include "level.h"
#include <stdio.h>

int parse_zone_config(int zone, const char *cfg_fn) {
   xci_config_t cfg;
   xci_config_node_t *node;
   int num_levels = 0;

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
         default:
            printf("parse_zone_config: WARNING: unexpected key (%s)\n",
                idx2key(node->key));
      }
      node = node->next;
   }

   return num_levels;
}
