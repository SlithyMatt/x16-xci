#ifndef GAME_CONFIG_H
#define GAME_CONFIG_H

#include "title_screen.h"
#include <stdint.h>

#define STRING_LEN_MAX 32

extern uint8_t init_pal[]; // 256 colors x 2 bytes per color

typedef struct game_config {
   uint8_t title[STRING_LEN_MAX];
   uint8_t author[STRING_LEN_MAX];
   uint8_t cursor[2];
   uint8_t zones;
   uint8_t title_screen[2];
   uint8_t menu[2];
   uint8_t toolbar[2];
   uint8_t inventory[2];
   title_screen_config_t title_screen_cfg;
   // followed by instruction sequence, then menu_config_t, etc.
} game_config_t;

int parse_game_config(const char* cfg_fn);


#endif // GAME_CONFIG
