.ifndef FILENAMES_INC
FILENAMES_INC = 1

.include "charmap.inc"

.ifndef TTL_MUS_BANK
TTL_MUS_BANK = 1
.endif

filenames:
main_fn:       .asciiz "MAIN.BIN"
main_fn_end:
sprites_fn:    .asciiz "SPRITES.BIN"
tiles_fn:      .asciiz "TILES.BIN"
palette_fn:    .asciiz "PAL.BIN"
ttl_bm_fn:     .asciiz "TTLBM.BIN"
ttl_mus_fn:    .asciiz "TTLMUS.BIN"
end_filenames:
FILES_TO_LOAD = 1
bankparams:
.byte TTL_MUS_BANK               ; bank
.byte end_filenames-ttl_mus_fn-1 ; filename length
.word ttl_mus_fn                 ; filename address

.endif
