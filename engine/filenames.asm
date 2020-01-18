.ifndef FILENAMES_INC
FILENAMES_INC = 1

.include "globals.asm"

filenames:
main_fn:       .asciiz "main.bin"
main_fn_end:
sprites_fn:    .asciiz "sprites.bin"
tiles_fn:      .asciiz "tiles.bin"
palette_fn:    .asciiz "pal.bin"
ttl_bm_fn:     .asciiz "ttl.bm.bin"
ttl_mus_fn:    .asciiz "ttl.mus.bin"
end_filenames:
FILES_TO_LOAD = 1
bankparams:
.byte TTL_MUS_BANK               ; bank
.byte end_filenames-ttl_mus_fn-1 ; filename length
.word ttl_mus_fn                 ; filename address

.endif
