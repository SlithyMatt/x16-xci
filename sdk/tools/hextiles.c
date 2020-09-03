#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define MAX_FN_LENGTH 256
#define PAL24_SIZE 48
#define PAL12_SIZE 32

void main(int argc, char **argv) {
   FILE *ifp;
   FILE *ofp;

   uint8_t idata[8];
   char fn[MAX_FN_LENGTH];
   uint8_t pal24[PAL24_SIZE];
   int i,j,k;
   int width;
   int tiles;
   long jump;
   long rewind;
   int row;

   if (argc < 3) {
      printf("Usage: %s [8bpp input] [width]\n", argv[0]);
      return;
   }

   width = atoi(argv[2]);

   if ((width % 8) != 0) {
      printf("Width of input bitmap must be multiple of 8 pixels\n");
      return;
   }

   tiles = width / 8;
   jump = (long)(width - 8);
   rewind = -7L * (long)width;

   ifp = fopen(argv[1], "rb");
   sprintf(fn,"%s.hex", argv[1]);
   ofp = fopen(fn, "w");

   row = 0;
   fprintf(ofp, "# Tiles from %s\n", argv[1]);
   while (!feof(ifp)) {
      for (i = 0; i < tiles; i++) {
         fprintf(ofp, "\n# tile %d\n", row * tiles + i);
         for (j = 0; j < 8; j++) {
            fread(idata,1,8,ifp);
            for (k = 0; k < 8; k++) {
               fprintf(ofp, "%x", idata[k]);
            }
            fprintf(ofp,"\n");
            if (j < 7) {
               fseek(ifp,jump,SEEK_CUR);
            }
         }
         if (i < tiles - 1) {
            fseek(ifp,rewind,SEEK_CUR);
         }
      }
      row++;
   }

   fclose(ofp);
   fclose(ifp);

   sprintf(fn,"%s.pal", argv[1]);
   ifp = fopen(fn, "rb");
   sprintf(fn,"%s.pal.hex", argv[1]);
   ofp = fopen(fn, "w");

   fread(pal24, 1, PAL24_SIZE, ifp);
   fprintf(ofp, "# 12-bit palette for %s\n", argv[1]);

   for (i = 0; i < 16; i++) {
      fprintf(ofp, "%x%x", (pal24[i*3+1] & 0xf0) >> 4, (pal24[i*3+2] & 0xf0) >> 4);
      fprintf(ofp, "0%x ", (pal24[i*3] & 0xf0) >> 4);
   }

   fprintf(ofp, "\n");

   fclose(ofp);
   fclose(ifp);
}
