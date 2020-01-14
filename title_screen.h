#ifndef TITLE_SCREEN_H
#define TITLE_SCREEN_H

typedef struct title_screen_config {
   uint8_t duration[2];
   // followed by instruction sequence, then menu_config_t
} title_screen_config_t;

int parse_title_screen_config(const char *cfg_fn, title_screen_config_t *cfg_bin);

#endif // TITLE_SCREEN_H
