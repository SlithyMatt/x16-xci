#ifndef CONFIG_H
#define CONFIG_H

#include "key.h"

typedef struct xci_val_list {
   char *val;
   struct xci_val_list *next;
} xci_val_list_t;

typedef struct xci_config_node {
   xci_key_t key;
   int num_values;
   xci_val_list_t *values;
   struct xci_config_node *next;
} xci_config_node_t;

typedef struct xci_config {
   char *source;
   xci_config_node_t *nodes;
} xci_config_t;

int parse_config (const char* cfg_fn, xci_config_t* cfg);

// Will only delete data referenced by configuration, not the
// xci_config_t structure itself, as that may not be on the heap.
// If cfg is allocated on the heap, it is safe to free it after
// calling this function.
void delete_config(xci_config_t* cfg);

#endif // CONFIG_H
