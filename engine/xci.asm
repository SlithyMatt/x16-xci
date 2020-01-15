.include "x16.inc"
.include "globals.asm"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
   jmp start


start:

   ; TODO: setup VERA layers

   ; TODO: load VRAM

   ; TODO: load config

   ; TODO: start title screen

mainloop:
   wai
   ; TODO: check for VSYNC
   bra mainloop


; ----- Configuration

.org RAM_CONFIG

cfg_title:  .dword 0,0,0,0,0,0,0,0
cfg_author: .dword 0,0,0,0,0,0,0,0
cfg_cursor: .word 0
cfg_zones:  .byte 0
