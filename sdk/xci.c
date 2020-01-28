#include "game_config.h"
#include "inventory.h"
#include "level.h"
#include <stdio.h>

void main(int argc, char **argv) {
   if (argc < 2) {
      printf("Usage: %s [main XCI config file]\n", argv[0]);
      return;
   }

   parse_game_config(argv[1]);

   delete_inv_list();
   delete_state_list();
}
