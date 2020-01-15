#include "bitmap.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define MAX_FN_LENGTH 256
#define PAL24_SIZE 48
#define PAL12_SIZE 32

int conv_bitmap(const char *raw_fn, const char *xci_fn, uint8_t *pal) {
   return conv_bitmap_addr(raw_fn, xci_fn, pal, 0x0000);
}

int conv_bitmap_addr(const char *raw_fn, const char *xci_fn,
                     uint8_t *pal, int address) {
   FILE *ifp;
   FILE *ofp;

   uint8_t idata[2];
   uint8_t odata[2];
   char pal_fn[MAX_FN_LENGTH];
   uint8_t pal24[PAL24_SIZE];
   int i;

   ifp = fopen(raw_fn, "rb");
   if (ifp == NULL) {
      printf("Error opening %s for reading\n", raw_fn);
      return -1;
   }
   ofp = fopen(xci_fn, "wb");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", xci_fn);
      return -1;
   }

   odata[0] = (uint8_t) (address & 0x00FF);
   odata[1] = (uint8_t) ((address & 0xFF00) >> 8);
   fwrite(odata,1,2,ofp);

   while (!feof(ifp)) {
      if (fread(idata,1,2,ifp) > 0) {
         odata[0] = (idata[0] & 0xf) << 4;
         odata[0] |= idata[1] & 0xf;
         fwrite(odata,1,1,ofp);
      }
   }

   fclose(ifp);
   fclose(ofp);

   sprintf(pal_fn, "%s.pal", raw_fn);
   ifp = fopen(pal_fn, "rb");

   if (ifp == NULL) {
      printf("conv_bitmap_addr: WARNING: %s not found\n", pal_fn);
   } else if (fread(pal24,1,PAL24_SIZE,ifp) < PAL24_SIZE) {
      printf("conv_bitmap_addr: WARNING: %s too small\n", pal_fn);
   } else {
      for (i = 0; i < 16; i++) {
         pal[i*2] = (pal24[i*3+1] & 0xf0) |         // green
                    ((pal24[i*3+2] & 0xf0) >> 4);   // blue
         pal[i*2+1] = (pal24[i*3] & 0xf0) >> 4;     // red
      }
   }

   return 0;
}

#ifdef TEST
void main(int argc, char **argv) {

   if (argc < 3) {
      printf("Usage: %s [1ppb input] [4ppb output] [default load address]\n", argv[0]);
      return;
   }

   if (argc >= 4) {
      sscanf(argv[3],"%x",&address);
   } else {
      // set default load address to 0x0000
      address = 0x0000;
   }

   conv_bitmap_addr(argv[1], argv[2], address);
}
#endif
