#ifndef LEVEL_H
#define LEVEL_H

#include <stdint.h>

#define MAX_TEXT_LINE 38

typedef struct text_line {
   uint8_t key; // must be xci_key_t::TEXT_LINE
   uint8_t style;
   uint8_t text[MAX_TEXT_LINE];
} text_line_t;

typedef struct go_level {
   uint8_t key; // must be xci_key_t::GO_LEVEL
   uint8_t zone;
   uint8_t level;
} go_level_t;

typedef struct tool_trigger {
   uint8_t key; // must be xci_key_t::TOOL_TRIGGER
   uint8_t tool;
   uint8_t x_min;
   uint8_t y_min;
   uint8_t x_max;
   uint8_t y_max;
} tool_trigger_t;

typedef struct item_trigger {
   uint8_t key; // must be xci_key_t::ITEM_TRIGGER
   uint8_t item;
   uint8_t required[2];
   uint8_t cost[2];
   uint8_t x_min;
   uint8_t y_min;
   uint8_t x_max;
   uint8_t y_max;
} item_trigger_t;

typedef struct get_item {
   uint8_t key; // must be xci_key_t::GET_ITEM
   uint8_t item;
   uint8_t quantity[2];
} get_item_t;

int parse_level_config(int zone, int level, const char *cfg_fn);

int state_index(const char* label);

void delete_state_list();

#endif // LEVEL_H
