#include "config.h"
#include "key.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 1000

int parse_config (const char *cfg_fn, xci_config_t *cfg) {
   FILE *ifp;
   char line[MAX_LINE+1];
   char *tok;
   int pos;
   xci_key_t key;
   xci_val_list_t *val;
   xci_val_list_t *last_val;
   xci_config_node_t *node;
   xci_config_node_t *last_node;

   ifp = fopen(cfg_fn, "r");
   if (ifp == NULL) {
      printf("parse_config: Unable to open %s\n", cfg_fn);
      return -1;
   }

   cfg->source = malloc(strlen(cfg_fn)+1);
   strcpy(cfg->source,cfg_fn);
   cfg->nodes = NULL;

   while (!feof(ifp)) {
      if (fgets(line, MAX_LINE, ifp) != NULL) {
         if (line[0] != '#') {
            tok = strtok(line, " \t\n\r");
            pos = 0;
            while ((tok != NULL) && (tok[0] != '#')) {
               if (pos == 0) {
                  key = key2idx(tok);
                  if ((int)key < 0) {
                     printf("WARNING: unknown key \"%s\" found in %s\n",
                            tok, cfg_fn);
                     break;
                  }
                  node = malloc(sizeof(xci_config_node_t));
                  node->key = key;
                  node->num_values = 0;
                  node->values = NULL;
                  node->next = NULL;
                  if (cfg->nodes == NULL) {
                     cfg->nodes = node;
                  } else {
                     last_node->next = node;
                  }
                  last_node = node;
               } else {
                  node->num_values++;
                  val = malloc(sizeof(xci_val_list_t));
                  val->val = malloc(strlen(tok)+1);
                  strcpy(val->val,tok);
                  val->next = NULL;
                  if (node->values == NULL) {
                     node->values = val;
                  } else {
                     last_val->next = val;
                  }
                  last_val = val;
               }
               tok = strtok(NULL, " \t\r\n");
               pos++;
            }
         }
      }
   }

   fclose(ifp);
   return 0;
}

void delete_val_list(xci_val_list_t *values) {
   if (values != NULL) {
      free(values->val);
      delete_val_list(values->next);
      free(values);
   }
}

void delete_config_node(xci_config_node_t *node) {
   if (node != NULL) {
      delete_val_list(node->values);
      delete_config_node(node->next);
      free(node);
   }
}

void delete_config(xci_config_t *cfg) {
   free(cfg->source);
   delete_config_node(cfg->nodes);
}

int concat_string_val(const xci_val_list_t *vals, uint8_t *str, int max) {
   const xci_val_list_t *val = vals;
   int i = 0;
   int j = 0;
   char temp_str[MAX_LINE] = ""; // contain possible overflow

   while (val != NULL) {
      strcat(temp_str, val->val);
      i += strlen(val->val);
      if (val->next != NULL) {
         strcat(temp_str, " ");
         i++;
      }
      if (i > max) {
         printf("concat_string_val: string too long\n");
         return -1;
      }
      val = val->next;
   }

   j = 0;
   for (i = 0; i < max; i++) {
      if (temp_str[j] == '#') {
         i = max;
      } else {
         if (temp_str[j] == '\\') {
            j++;
         }
         str[i] = (uint8_t)temp_str[j++];
      }
   }

   return 0;
}


#ifdef TEST
void main(int argc, char **argv) {
   xci_config_t cfg;
   xci_config_node_t *node;
   xci_val_list_t *val;
   int i;

   if (argc < 2) {
      printf("Usage: %s [config filename]\n", argv[0]);
      return;
   }

   parse_config(argv[1], &cfg);

   printf("Configuration:\n");
   printf("Source: %s\n", cfg.source);
   node = cfg.nodes;
   while (node != NULL) {
      printf("%d[%s]: ", node->key, idx2key(node->key));
      val = node->values;
      i = 1;
      while (val != NULL) {
         printf("%s", val->val);
         if (i < node->num_values) {
            printf(", ");
         }
         val = val->next;
         i++;
      }
      printf("\n");
      node = node->next;
   }

   delete_config(&cfg);
}
#endif
