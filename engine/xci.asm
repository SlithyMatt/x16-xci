.include "x16.inc"

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
