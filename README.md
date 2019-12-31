# XCI: eXtremely Compact Interpreter
An adventure game engine for the Commander X16

## Overview
XCI is an adventure game engine designed to be as compact as
possible while still creating a rich experience, featuring a
point-and-click interface, animated sprites, and detailed backgrounds.
This is being designed specifically for the Commander X16
retrocomputer, which has just over 37kB of base RAM, 512kB of
extended RAM split into 8kB banks, and 128kB of VRAM.  It uses a
65C02 CPU, standard PS/2 mouse and keyboard, and an FPGA-based
video adapter that can output 256 colors at a 640x480 resolution.
Because of the memory restrictions, XCI will be using 16 colors
per element at a 320x240 resolution.  The X16 allows elements
to have a palette offset to choose which "row" of 16 colors from
the 256-color palette will be used.

The elements of the game consist of three independent layers:
* 320x200 Bitmap backgound, placed 8 pixels from the top of the screen, then end 32 pixels from the bottom.  The entire bitmap
will comprise of only 16 colors, taken from a palette offset.
* 40x30 map of 8x8 tiles. Each tile can have 16 colors, but also
its own palette offset.  The tiles provide a menu at the top of the
screen, text display and controls at the bottom. Tiles may also
act as static overlays on top of the background.  Up to 720 unique
tiles can be defined.
* 128 individual 16x16 sprites, including a dynamic mouse cursor.
Each sprite can have 16 colors, from its own palette offset. Up to 512 unique sprite frames can be defined. All sprites except for the mouse cursor are confined to the bitmap area, and support collision
with other sprites and tiles. The mouse cursor is context-sensitive,
changing its frame based on its position and game state to indicate
the type of action that will happen when the mouse button is clicked.

## Memory Map
Main RAM ($0801-$9EFF): XCI engine code, top-level game data

Banked RAM ($A000-$BFFF): 6 banks per level, up to 10 levels per currently loaded zone.
* Bank 0: Kernal Use
* Bank 1: Zone level 1 meta data
* Banks 2-5: Zone level 1 background bitmap
* Bank 6: Zone level 1 music and sound effects
* Bank 7: Zone level 2 meta data

...
* Bank 60: Zone level 10 music and sound effects

When transit from a level leads to a different zone, the new
zone is loaded to banked RAM from the file system. Up to 256
different zones can be defined.

VRAM:
* Bank 0: Bitmap ($0000-$95FF), Tile Map ($9600-$A5FF), Tiles ($A600-$FFFF)
* Bank 1: Sprites ($0000-$FFFF)

## Data Format
(TBD)
