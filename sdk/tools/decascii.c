#include <stdio.h>
#include <string.h>

int main (int argc, char **argv) {
   int i = 1;
   int j = 0;

   if (argc < 2) {
      printf("Usage: %s [text to translate to decimal ASCII]\n", argv[0]);
      return 0;
   }

   while (i < argc) {
      j = 0;
      while (j < strlen(argv[i])) {
         printf("%d ", argv[i][j]);
         j++;
      }
      i++;
      if (i < argc) {
         printf("32 ");
      }
   }

   printf("\n");
}
