#ifndef GAME_CONFIG_H
#define GAME_CONFIG_H

#include <stdint.h>

#define STRING_LEN_MAX 32

typedef struct game_config {
   uint8_t title[STRING_LEN_MAX];
   uint8_t author[STRING_LEN_MAX];
   uint8_t cursor[2];
   uint8_t zones;
   uint8_t title_screen[2]; // will always contain sizeof(game_config_t)
   uint8_t menu[2];
   uint8_t toolbar[2];
   uint8_t inventory[2];
   // followed by title_screen_config_t
} game_config_t;

int parse_game_config(const char* cfg_fn);


#endif // GAME_CONFIG
