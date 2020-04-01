#ifndef VGM2X16OPM_H
#define VGM2X16OPM_H

#include <stdint.h>


// x16_data must have at least 8 kB allocated
// returns the number of bytes written to x16_data
int vgm2x16opm(const char *vgm_fn, uint8_t *x16_data);

int vgm2x16opm_f(const char *vgm_fn, const char *x16_fn);

int vgm2x16opm_f_addr(const char *vgm_fn, const char *x16_fn, int address);

#endif //VGM2X16OPM_H
