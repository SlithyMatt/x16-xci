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

typedef struct title_screen_config {
   uint8_t duration[2];
   // followed by instruction sequence, then menu_config_t
} title_screen_config_t;

typedef struct menu_config {
   uint8_t bar[80];
   uint8_t controls[2];
   uint8_t about[2];
   // followed by item sequence, then controls and about tilemaps,
   // then toolbar_config_t
} menu_config_t;

typedef struct tilemap {
   uint8_t start_x;
   uint8_t start_y;
   uint8_t width;
   uint8_t height;
   // followed by tilemap data
};

typedef struct toolbar_config {
   
} toolbar_config_t;

#endif // GAME_CONFIG
