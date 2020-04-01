#include "vgm2x16opm.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DELAY_REG 2
#define DONE_REG  4
#define VGM_DO    0x34

int vgm2x16opm(const char *vgm_fn, uint8_t *x16_data) {
   FILE *ifp;
   int delay;
   uint8_t idata[4];
   int data_offset;
   int done = 0;
   int size = 0;

   ifp = fopen(vgm_fn, "rb");
   if (ifp == NULL) {
      printf("Error opening %s for reading\n", vgm_fn);
      return -1;
   }

   // roll up to beginning of data
   if (fread(idata,1,4,ifp) < 4) {
      printf("%s is not a valid VGM file.\n", vgm_fn);
      return -1;
   }

   if (strncmp(idata,"Vgm ",4) != 0) {
      printf("%s is not a valid VGM file.\n", vgm_fn);
      return -1;
   }

   fseek(ifp,VGM_DO,SEEK_SET);
   fread(idata,1,4,ifp);
   data_offset = VGM_DO + (int)idata[0] + (((int)idata[1]) << 8) +
                  (((int)idata[2]) << 16) + (((int)idata[3]) << 24);
   fseek(ifp,data_offset,SEEK_SET);

   while (!feof(ifp) && !done) {
      fread(idata,1,1,ifp);
      switch (idata[0]) {
         case 0x54: // YM2151 - just dump right to output
            size += fread(&x16_data[size],1,2,ifp);
            break;
         case 0x61: // Wait # samples
            fread(idata,1,2,ifp);
            x16_data[size++] = DELAY_REG;
            delay = ((int)idata[0] + (((int)idata[1]) << 8))/735;
            // write as delay of VSCAN ticks
            x16_data[size++] = (uint8_t)delay;
            break;
         case 0x62: // Wait 735 samples (1 NTSC VSYNC tick)
            x16_data[size++] = DELAY_REG;
            x16_data[size++] = 1;
            break;
         case 0x66: // end of sound data
            x16_data[size++] = DONE_REG;
            x16_data[size++] = 0;
            done = 1;
            break;
         case 0xc0: // Sega PCM (expected from Deflemask)
            fread(idata,1,3,ifp); // ignore data
            break;
         default:
            // TODO: support other sounds chips to include or ignore
            // assume any other data code to be single-byte
            printf("Unexpected code: 0x%02X\n", idata[0]);
            break;
      }
   }

   fclose(ifp);

   return size;
}

int vgm2x16opm_f(const char *vgm_fn, const char *x16_fn) {
   return vgm2x16opm_f_addr(vgm_fn,x16_fn,0x0000);
}

int vgm2x16opm_f_addr(const char *vgm_fn, const char *x16_fn, int address) {
   FILE *ofp;
   uint8_t *x16_data;
   uint8_t odata[3];
   int size;

   x16_data = malloc(8192);

   size = vgm2x16opm(vgm_fn, x16_data);

   if (size < 0) {
      // error message should already be printed
      return -1;
   }

   ofp = fopen(x16_fn, "wb");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", x16_fn);
      return -1;
   }

   // write X16 address header
   odata[0] = (uint8_t) (address & 0x00FF);
   odata[1] = (uint8_t) ((address & 0xFF00) >> 8);
   fwrite(odata,1,2,ofp);

   // write loadable header
   odata[0] = 1; // music present
   odata[1] = 3; // music offset (low byte)
   odata[2] = 0; // music offset (high byte)
   fwrite(odata,1,3,ofp);

   // write music data
   fwrite(x16_data,1,size,ofp);

   free(x16_data);
   fclose(ofp);

   return 0;
}

#ifdef TEST
int main(int argc, char **argv) {
   int address;

   if (argc < 3) {
      printf("Usage: %s [source VGM file] [converted binary file] [default load address]\n", argv[0]);
      return 0;
   }

   if (argc >= 4) {
      sscanf(argv[3],"%x",&address);
   } else {
      // set default load address to 0xA000
      address = 0xA000;
   }

   return vgm2x16opm_f_addr(argv[1],argv[2],address);
}
#endif
