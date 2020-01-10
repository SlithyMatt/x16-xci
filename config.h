#ifndef CONFIG_H
#define CONFIG_H

#include "key.h"

typedef struct xci_val_list {
   const char *val;
   struct xci_val_list *next;
} xci_val_list_t;

typedef struct xci_key_values {
   xci_key_t key;
   int num_values;
   xci_val_list_t values;
} xci_key_values_t;

typedef struct xci_config_node {
   xci_key_values_t *kv;
   struct xci_config_node *next;
} xci_config_node_t;

typedef struct xci_config {
   const char *source;
   xci_config_node_t *head;
   xci_config_node_t *tail;
} xci_config_t;

int parse_config (const char* cfg_fn, xci_config_t* cfg);

void delete_config(xci_config_t* cfg);

#endif // CONFIG_H
