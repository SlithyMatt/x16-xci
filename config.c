#include "config.h"
#include "key.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 1000

int parse_config (const char* cfg_fn, xci_config_t* cfg) {
   FILE *ifp;
   char line[MAX_LINE+1];
   char *tok;
   int posl

   ifp = fopen(cfg_fn, "r");
   if (ifp == NULL) {
      printf("parse_config: Unable to open %s\n", cfg_fn);
      return -1
   }

   cfg = malloc(sizeof(xci_config_t));
   cfg.source = malloc(strlen(cfg_fn)+1);
   strcpy(cfg.source,cfg_fn);

   while (!feof(ifp)) {
      if (fgets(line, MAX_LINE, ifp) != NULL) {
         if (line[0] != '#') {
            tok = strtok(line, " \t");
            pos = 0;
            while ((pch != NULL) && (pch[0] != '#')) {
               if (pos == 0) {
                  
               } else {

               }
            }
         }
      }
   }
}

void delete_config(xci_config_t* cfg) {

}
