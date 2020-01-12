#ifndef MENU_H
#define MENU_H

typedef struct menu_config {
   uint8_t bar[80];
   uint8_t div[2];
   uint8_t controls[2];
   uint8_t about[2];
   uint8_t num_menus;
   // followed by num_menus menu_header_t/menu_item_t sequences,
   // then controls and about tilemap_t's,
   // then toolbar_config_t
} menu_config_t;

typedef struct menu_header {
   uint8_t title[16];
   uint8_t num_items;
   // Followed by num_items menu_item_t's cast to uint8_t's
} menu_header_t;

typedef enum menu_item {
   MENU_DIV,
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
   INVENTORY_TOOL,
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
   toolbar_action_t action;
   uint8_t start_x;
   uint8_t start_y;
   uint8_t end_x;
   uint8_t end_y;
   uint8_t
   // followed by 2*(end_x-startx+1)*(end_x-startx+1) bytes of
   // tilemap for the button.  If action == PIN_TOOLBAR,
   // the number of tiles will be doubled to have both states
   // of the pin button
} toolbar_button_t;

typedef struct toolbar_config {
   uint8_t start_x;
   uint8_t start_y;
   uint8_t end_x;
   uint8_t walk_cursor;
   uint8_t run_cursor;
   uint8_t look_cursor;
   uint8_t use_cursor;
   uint8_t talk_cursor;
   uint8_t strike_cursor;
   uint8_t num_tools;
   // followed by num_tools toolbar buttons, then inventory_config_t
} toolbar_config_t;

int parse_menu_config(const char* cfg_fn, uint8_t *bin);

#endif // MENU_H
