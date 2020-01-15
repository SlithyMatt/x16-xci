#include "tile_layout.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_LINE 1000
#define MENU_PAL 0xB0
#define MIN_ASCII 0x20
#define MAX_ASCII 0x7E
#define H_FLIP 0x04
#define V_FLIP 0x08
#define MAX_TILE 719
#define BLACK1 0x00
#define BLACK2 0xF0

int asc2tile(const char *descriptor, int pal_offset, uint8_t *tile) {
   int i = 0;
   int tile_idx = atoi(descriptor);
   
   if (tile_idx > MAX_TILE) {
      printf("asc2tile: invalid tile index (%d)\n", tile_idx);
      return -1;
   }
   tile[0] = (uint8_t)(tile_idx & 0xff);
   i++;
   if (tile_idx >= 10) {
      i++;
      if (tile_idx >= 100) {
         i++;
      }
   }
   tile[1] = ((tile_idx & 0x300) >> 8) | (pal_offset << 4);
   if (descriptor[i] == 'H') {
      tile[1] = tile[1] | H_FLIP;
      i++;
      if (descriptor[i] == 'V') {
         tile[1] = tile[1] | V_FLIP;
         i++;
      }
   } else if (descriptor[i] == 'V') {
      tile[1] = tile[1] | V_FLIP;
      i++;
      if (descriptor[i] == 'H') {
         tile[1] = tile[1] | H_FLIP;
         i++;
      }
   }

   return 2;
}

int str2tiles(const char *str, int pal_offset, uint8_t *tiles) {
   int i = 0;

   while (str[i] != '\0') {
      tiles[i*2] = (uint8_t)str[i];
      tiles[i*2+1] = pal_offset << 4;
      i++;
   }

   return i*2; // number of tile bytes
}

int tile_layout(const char *filename, tilemap_t *tilemap) {
   FILE *ifp;
   char line[MAX_LINE+1];
   int width = 0;
   int max_width = 0;
   int line_num = 0;
   int i;
   int map_i, t_map_i;
   int tile_idx;
   int byte2;
   int hmargin, vmargin;
   tilemap_t temp_tm;

   memset(&temp_tm.map, 0, TILEMAP_SIZE);

   ifp = fopen(filename, "r");
   if (ifp == NULL) {
      printf("tile_layout: Unable to open %s\n", filename);
      return -1;
   }

   while (!feof(ifp)) {
      if (fgets(line, MAX_LINE, ifp) != NULL) {
         width = 0;
         if (line[0] != '#') {
            i = 0;
            map_i = line_num * TILEMAP_MAX_WIDTH * 2;
            while ((line[i] >= ' ') && (line[i] != '#')) {
               if (line[i] == '\\') {
                  // process escape code
                  i++;
                  if ((line[i] < '0') || (line[i] > '9')) {
                     temp_tm.map[map_i++] = (uint8_t)line[i];
                     temp_tm.map[map_i++] = MENU_PAL;
                     i++;
                  } else {
                     tile_idx = atoi(&line[i]);
                     if (tile_idx > MAX_TILE) {
                        printf("tile_layout: %s, invalid tile index (%d) on line %d\n",
                               filename, tile_idx, line_num);
                        return -1;
                     }
                     temp_tm.map[map_i++] = (uint8_t)(tile_idx & 0xff);
                     i++;
                     if (tile_idx >= 10) {
                        i++;
                        if (tile_idx >= 100) {
                           i++;
                        }
                     }
                     byte2 = (tile_idx & 0x300) >> 8;
                     if (line[i] == 'H') {
                        byte2 = byte2 | H_FLIP;
                        i++;
                        if (line[i] == 'V') {
                           byte2 = byte2 | V_FLIP;
                           i++;
                        }
                     } else if (line[i] == 'V') {
                        byte2 = byte2 | V_FLIP;
                        i++;
                        if (line[i] == 'H') {
                           byte2 = byte2 | H_FLIP;
                           i++;
                        }
                     }
                     if ((tile_idx >= MIN_ASCII) && (tile_idx <= MAX_ASCII)) {
                        byte2 = byte2 | MENU_PAL;
                     }
                     temp_tm.map[map_i++] = (uint8_t)byte2;
                  }
               } else if (line[i] == '\t') {
                  temp_tm.map[map_i++] = (uint8_t)' ';
                  temp_tm.map[map_i++] = MENU_PAL;
                  i++;
               } else {
                  temp_tm.map[map_i++] = (uint8_t)line[i];
                  temp_tm.map[map_i++] = MENU_PAL;
                  i++;
               }
               width++;
            }
            if (width > TILEMAP_MAX_WIDTH) {
               printf("tile_layout: %s, line %d exceeds maximum width of %d\n",
                      filename, line_num, TILEMAP_MAX_WIDTH);
               return -1;
            }
            if (width > max_width) {
               max_width = width;
            }
            line_num++;
            if (line_num > TILEMAP_MAX_HEIGHT) {
               printf("tile_layout: %s, line number exceeds maximum height of %d\n",
                      filename, TILEMAP_MAX_HEIGHT);
               return -1;
            }
         }
      }
   }

   fclose(ifp);

   hmargin = (TILEMAP_MAX_WIDTH - max_width) / 2;
   vmargin = (TILEMAP_MAX_HEIGHT - line_num) / 2;

   for (i = 0; i < vmargin; i++) {
      for (map_i = i*TILEMAP_MAX_WIDTH*2; map_i < (i+1)*TILEMAP_MAX_WIDTH*2; map_i +=2) {
         tilemap->map[map_i] = BLACK1;
         tilemap->map[map_i+1] = BLACK2;
      }
   }

   t_map_i = 0;

   for (i = vmargin; i < vmargin+line_num; i++) {
      map_i = i*TILEMAP_MAX_WIDTH*2;
      while (map_i < i*TILEMAP_MAX_WIDTH*2 + hmargin*2) {
         tilemap->map[map_i++] = BLACK1;
         tilemap->map[map_i++] = BLACK2;
      }
      while (map_i < i*TILEMAP_MAX_WIDTH*2 + hmargin*2 + max_width*2) {
         if ((temp_tm.map[t_map_i] == 0) && (temp_tm.map[t_map_i+1] == 0)) {
            tilemap->map[map_i++] = (uint8_t)' ';
            tilemap->map[map_i++] = MENU_PAL;
            t_map_i += 2;
         } else {
            tilemap->map[map_i++] = temp_tm.map[t_map_i++];
            tilemap->map[map_i++] = temp_tm.map[t_map_i++];
         }
      }
      while (map_i < (i+1)*TILEMAP_MAX_WIDTH*2) {
         tilemap->map[map_i++] = BLACK1;
         tilemap->map[map_i++] = BLACK2;
         t_map_i += 2;
      }
      if (hmargin > 0) {
         t_map_i += hmargin*2;
      }
   }

   for (i = vmargin+line_num; i < TILEMAP_MAX_HEIGHT; i++) {
      for (map_i = i*TILEMAP_MAX_WIDTH*2; map_i < (i+1)*TILEMAP_MAX_WIDTH*2; map_i +=2) {
         tilemap->map[map_i] = BLACK1;
         tilemap->map[map_i+1] = BLACK2;
      }
   }

   return 0;
}

int cfg2tiles(xci_val_list_t *values, int pal_offset, uint8_t *tiles) {
   int size = 0;
   int increment;
   while (values != NULL) {
      increment = asc2tile(values->val, pal_offset, &tiles[size]);
      if (increment < 0) {
         printf("cfg2tiles: Unable to parse tile config %s\n", values->val);
         return -1;
      }
      size += increment;
      values = values->next;
   }

   return size;
}

#ifdef TEST
int main(int argc, char **argv) {
   FILE *ofp;
   tilemap_t tm;

   if (argc >= 3) {
      ofp = fopen(argv[2], "wb");
      if (ofp == NULL) {
         printf("Error opening %s\n", argv[2]);
      } else {
         tile_layout(argv[1], &tm);
         fwrite(&tm.map, TILEMAP_SIZE, 1, ofp);
         fclose(ofp);
      }
   } else {
      printf("Usage: %s [source ASCII file] [converted binary file]\n", argv[0]);
   }

   return 0;
}
#endif
