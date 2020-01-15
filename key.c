#include "key.h"
#include <string.h>
#include <stdio.h>

const char xci_key_strings[NUM_XCI_KEYS][MAX_KEY_LENGTH] = {
   "title",
   "author",
   "palette",
   "tiles_hex",
   "sprites_hex",
   "menu_xci",
   "title_screen",
   "init_cursor",
   "zone",
   "menu_bg",
   "menu_fg",
   "menu_lc",
   "menu_sp",
   "menu_rc",
   "menu_div",
   "menu_check",
   "menu_uncheck",
   "menu",
   "menu_item",
   "controls",
   "about",
   "text1_bg",
   "text1_fg",
   "text2_bg",
   "text2_fg",
   "text3_bg",
   "text3_fg",
   "tb_dim",
   "tool",
   "tool_tiles",
   "inventory",
   "walk",
   "run",
   "look",
   "use",
   "talk",
   "strike",
   "duration",
   "bitmap",
   "music",
   "sprite_frames",
   "sprite",
   "tiles",
   "wait",
   "sprite_move",
   "inv_dim",
   "inv_item_dim",
   "inv_empty",
   "inv_left_margin",
   "inv_right_margin",
   "inv_quant",
   "inv_quant_margin",
   "inv_scroll",
   "inv_scroll_margin",
   "inv_item"
};

void strn_tolower(char *dest, int max, const char *source) {
   int i = 0;
   while ((source[i] != '\0') && (i < (max - 1))) {
      if ((source[i] >= 'A') && (source[i] <= 'Z')) {
         dest[i] = source[i] + ('a' - 'A');
      } else {
         dest[i] = source[i];
      }
      i++;
   }
   dest[i] = '\0';
}

xci_key_t key2idx(const char* key) {
   char key_lc[MAX_KEY_LENGTH];
   int i = 0;
   int cmp = -1;

   strn_tolower(key_lc, MAX_KEY_LENGTH, key);

   i = 0;
   while ((i < NUM_XCI_KEYS) && cmp) {
      cmp = strcmp(key_lc,xci_key_strings[i]);
      if (cmp) {
         i++;
      }
   }

   if (cmp) {
      i = -1;
   }

   return i;
}

const char* idx2key(xci_key_t index) {
   static const char unknown[MAX_KEY_LENGTH] = "unknown";
   const char* key;
   if ((index < 0) || (index > NUM_XCI_KEYS)) {
      key = unknown;
   } else {
      key = xci_key_strings[index];
   }
   return key;
}

#ifdef TEST
void main(int argc, char** argv) {

   xci_key_t index;

   if (argc < 2) {
      printf("Usage: %s [key string]\n", argv[0]);
      return;
   }

   index = key2idx(argv[1]);

   if ((int)index < 0) {
      printf("Unable to find matching key for %s\n", argv[1]);
   } else {
      printf("%d: %s\n", index, idx2key(index));
   }
}
#endif
