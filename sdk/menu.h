#ifndef MENU_H
#define MENU_H

#include <stdint.h>

typedef struct menu_config {
   uint8_t bar[80];
   uint8_t div[2];
   uint8_t space[2];
   uint8_t check[2];
   uint8_t uncheck[2];
   uint8_t controls[2];
   uint8_t about[2];
   uint8_t num_menus;
   // followed by num_menus menu_header_t/menu_item_t sequences,
   // then controls and about tilemap_t's,
   // then toolbar_config_t
} menu_config_t;

typedef struct menu_header {
   uint8_t start_x;
   uint8_t end_x;
   uint8_t num_items;
   // Followed by num_items menu_item_t's cast to uint8_t's
} menu_header_t;

typedef enum menu_item {
   MENU_DIV_ITEM = 0,
   NEW_GAME,
   LOAD_GAME,
   SAVE_GAME,
   SAVE_GAME_AS,
   EXIT_GAME,
   TOGGLE_MUSIC,
   TOGGLE_SFX,
   HELP_CONTROLS,
   HELP_ABOUT,

   NUM_MENU_ITEMS
} menu_item_t;

typedef enum toolbar_action {
   INVENTORY_TOOL = 0,
   WALK_TOOL,
   RUN_TOOL,
   LOOK_TOOL,
   USE_TOOL,
   TALK_TOOL,
   STRIKE_TOOL,
   PIN_TOOLBAR,

   NUM_TOOLS
} toolbar_action_t;

typedef struct toolbar_button {
   uint8_t action;
   uint8_t start_x;
   uint8_t end_x;
   // followed by 2*(end_x-startx+1)*(30-toolbar_config::start_y) bytes of
   // tilemap for the button.  If action == PIN_TOOLBAR,
   // the number of tiles will be doubled to have both states
   // of the pin button
} toolbar_button_t;

typedef struct toolbar_config {
   uint8_t start_x;
   uint8_t start_y;
   uint8_t walk_cursor[2];
   uint8_t run_cursor[2];
   uint8_t look_cursor[2];
   uint8_t use_cursor[2];
   uint8_t talk_cursor[2];
   uint8_t strike_cursor[2];
   uint8_t num_tools;
   // followed by num_tools toolbar buttons, then inventory_config_t
} toolbar_config_t;

extern int init_cursor;

int parse_menu_config(const char* cfg_fn, menu_config_t *cfg_bin,
                      int *tb_offset, int *inv_offset);

toolbar_action_t tool2idx(const char *tool_label);

#endif // MENU_H
