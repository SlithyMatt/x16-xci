# XCI Configuration File Syntax
This doucment describes, key by key, the overall syntax of XCI configuration files. There are six kinds of configuration files, as described in the [main documentation](README.md):

* [Main File](README.md#main-file)
* [Menu File](README.md#menu-file)
* [Title Screen File](README.md#title-screen-file)
* [Inventory File](README.md#inventory-file)
* [Zone Files](README.md#zone-files)
* [Level Files](README.md#level-files)

For each key, the value format will be described by a set of argument names. Arguments surrounded by brackets can vary in number of instances per key, for example the set of frame indices for a [**sprite_frames**](#sprite_frames) key. Then, each argument is described in terms of type, range and meaning. Finally, the set of file types in which this key may appear is listed.

This document is intended to be a concise guide to the language and not a comprehensive programmer's guide. For that, please see the [main documentation](README.md) and the example game [appendix](example/APPENDIX.md).

## Types

There are five basic types for arguments:

* Integer: Simple decimal number value, with no decimal point. May be negative, depending on range.
* String: Literal characters and escape codes. String values are whitespace-delimited. Keys that take a variable number of strings, like [**text**](#text), may be reconsituting a concatentated string, using single spaces between the string tokens. Certain characters require escape codes, mainly the pound/hash (as ```\#```) and the backslash (as ```\\```). Quotes are not required around string arguments, so they will be part of the value sent to the engine as literal quote characters. At this time, only standard ASCII printable characters are supported, namely exclamation point (x21, '!') through tilde (x7E, '~').
* Tile: Positive integer from 0 to 719. May be followed immediately (no spaces in between) by an ```H```, a ```V``` or both. The letters indicated how the tile is to be flipped. Examples: ```1``` is tile 1 with no flipping; ```2H``` is tile 2 flipped horizontally; ```3V``` is tile 3 flipped vertically; ```4HV``` is tile 4 flipped both horizontally and vertically.
* Sprite: Like a Tile, but is based on sprite frame indices, which range from 0 to 511. May also be suffixed with ```H``` and/or ```V``` for flipping.
* Identifier: String (with no whitespace) that identifies an entity in the game, such as a menu, tool, inventory item or state variable. May contain letters, numbers and special characters other than pound/hash (```#```).

## Comments
The pound/hash (```#```) character is used to mark comments. Any text after this character will be ignored, unless it appears as an escaped character in a string value (as ```\#```).

Examples:

| Line | Effect |
|--|--|
| ```#text 1 Never to be seen``` | Nothing -- effectively a blank line |
| ```text 1 Hello, World!# comment``` | Will print ```Hello, World!``` |
| ```text 1 So \#relatable # being trendy``` | Will print ```So #relatable``` |

## Keys

Skip to [Main File](README.md#main-file) keys:

| [**title**](#title) | [**author**](#author) | [**palette**](#palette) |
|--|--|--|
| [**tiles_hex**](#tiles_hex) | [**sprites_hex**](#sprites_hex) | [**menu_xci**](#menu_xci) |
| [**title_screen**](#title_screen) | [**init_cursor**](#init_cursor) | [**zone**](#zone) |

Skip to [Menu File](README.md#menu-file) keys:

| [**menu_bg**](#menu_bg) | [**menu_fg**](#menu_fg) | [**menu_lc**](#menu_lc) | [**menu_sp**](#menu_sp) |
|--|--|--|--|
| [**menu_rc**](#menu_rc) | [**menu_div**](#menu_div) | [**menu_check**](#menu_check) | [**menu_uncheck**](#menu_uncheck) |
| [**menu**](#menu) | [**menu_item**](#menu_item) | [**controls**](#controls) | [**about**](#about) |
| [**text1_bg**](#text1_bg) | [**text1_fg**](#text1_fg) |  [**text2_bg**](#text2_bg) | [**text2_fg**](#text2_fg) |
| [**text3_bg**](#text3_bg) |  [**text3_fg**](#text3_fg) | [**tb_dim**](#tb_dim) | [**tool**](#tool) |
| [**tool_tiles**](#tool_tiles) | [**inventory**](#inventory) | [**walk**](#walk) |  [**run**](#run) |
| [**look**](#look) | [**use**](#use) |  [**talk**](#talk) | [**strike**](#strike) |

Skip to [Title Screen File](README.md#title-screen-file) keys:

| [**duration**](#duration) | [**bitmap**](#bitmap) | [**music**](#music) |
|--|--|--|
| [**sprite_frames**](#sprite_frames) | [**sprite**](#sprite) | [**tiles**](#tiles) |
| [**wait**](#wait) | [**sprite_move**](#sprite_move) | [**sprite_hide**](#sprite_hide) |

Skip to [Inventory File](README.md#inventory-file) keys:

| [**inv_dim**](#inv_dim) | [**inv_item_dim**](#inv_item_dim) | [**inv_empty**](#inv_empty) | [**inv_left_margin**](#inv_left_margin) |
|--|--|--|--|
| [**inv_right_margin**](#inv_right_margin) | [**inv_quant**](#inv_quant) | [**inv_quant_margin**](#inv_quant_margin) | [**inv_scroll**](#inv_scroll) |
| [**inv_scroll_margin**](#inv_scroll_margin) | [**inv_item**](#inv_item) |

Skip to [Zone File](README.md#zone-files) key:

[**level**](#level)

Skip to [Level File](README.md#level-files) keys:

|[**bitmap**](#bitmap) | [**music**](#music) | [**sprite_frames**](#sprite_frames) | [**sprite**](#sprite) |
|--|--|--|--|
| [**tiles**](#tiles) | [**wait**](#wait) | [**sprite_move**](#sprite_move) | [**end_anim**](#end_anim) |
| [**sprite_hide**](#sprite_hide) | [**init**](#init) | [**first**](#first) | [**text**](#text) |
| [**scroll**](#scroll) | [**line**](#line) | [**clear**](#clear) | [**go_level**](#go_level) |
| [**tool_trigger**](#tool_trigger) | [**item_trigger**](#item_trigger) | [**if**](#if) | [**if_not**](#if_not) |
| [**end_if**](#end_if) | [**set_state**](#set_state) | [**clear_state**](#clear_state) | [**get_item**](#get_item) |

### title

Defines the title of the game. Should contain version number or something to uniquely identify revision of the configuration to ensure that only compatible saved games are loaded.

Usage:
```
title [text]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| text | String | 1-255 characters, including spaces after concatenation | Title of game |

Found in:
* [Main File](README.md#main-file)


### author

Defines the author of the game. Like [**title**](#title), is used to verify compatibility of saved game files.

Usage:
```
author [text]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| text | String | 1-255 characters, including spaces after concatenation | Author of game |

Found in:
* [Main File](README.md#main-file)

### palette

Defines the filename for the [Palette Hex File](README.md#palette-hex-file).

Usage:
```
palette filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-991 characters | Filename for palette hex file |

Found in:
* [Main File](README.md#main-file)

### tiles_hex

Defines the filename for the [Tiles Hex File](README.md#tiles-hex-file).

Usage:
```
tiles_hex filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-989 characters | Filename for tiles hex file |

Found in:
* [Main File](README.md#main-file)

### sprites_hex

Defines the filename for the [Sprites Hex File](README.md#sprites-hex-file).

Usage:
```
sprites_hex filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-988 characters | Filename for sprites hex file |

Found in:
* [Main File](README.md#main-file)

### menu_xci

Defines the filename for the [Menu File](README.md#menu-file).

Usage:
```
menu_xci filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-991 characters | Filename for menu file |

Found in:
* [Main File](README.md#main-file)

### title_screen

Defines the filename for the [Title Screen File](README.md#title-screen-file).

Usage:
```
title_screen filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-987 characters | Filename for title screen file |

Found in:
* [Main File](README.md#main-file)

### init_cursor

Defines the sprite frame index for the initial and default mouse cursor. Note: mouse cursor sprites cannot be flipped.

Usage:
```
init_cursor index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-511 | Sprite frame index for mouse cursor |


Found in:
* [Main File](README.md#main-file)

### zone

Defines the filename of a [Zone File](README.md#zone-files).  Each zone will be indexed (starting with zero) based on the order in which the zones are defined.

Usage:
```
zone filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-995 characters | Filename for a zone file |

Found in:
* [Main File](README.md#main-file)

### menu_bg

Defines the default palette index to use for the menu character background color.

Usage:
```
menu_bg index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-15 | Palette index |

Found in:
* [Menu File](README.md#menu-file)

### menu_fg

Defines the default palette index to use for the menu character foreground color.

Usage:
```
menu_fg index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-15 | Palette index |

Found in:
* [Menu File](README.md#menu-file)

### menu_lc

Defines the tile to use for the left corner of the menu bar. It will use the default palette.

Usage:
```
menu_lc tile
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tile | Tile | Any | Tile for left corner of the menu bar |

Found in:
* [Menu File](README.md#menu-file)

### menu_sp

Defines the tile to use for blank spaces in the menu. It will use the default palette.

Usage:
```
menu_sp tile
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tile | Tile | Any | Tile for blank spaces in the menu. |

Found in:
* [Menu File](README.md#menu-file)

### menu_rc

Defines the tile to use for the right corner of the menu bar. It will use the default palette.

Usage:
```
menu_rc tile
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tile | Tile | Any | Tile for right corner of the menu bar |

Found in:
* [Menu File](README.md#menu-file)

### menu_div

Defines the tile to use for dividers in the menu. It will use the default palette.

Usage:
```
menu_div tile
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tile | Tile | Any | Tile for dividers in the menu. |

Found in:
* [Menu File](README.md#menu-file)

### menu_check

Defines the tile to use for checked checkboxes in the menu. It will use the default palette.

Usage:
```
menu_check tile
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tile | Tile | Any | Tile for checked checkboxes in the menu. |

Found in:
* [Menu File](README.md#menu-file)

### menu_uncheck

Defines the tile to use for unchecked checkboxes in the menu. It will use the default palette.

Usage:
```
menu_uncheck tile
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tile | Tile | Any | Tile for unchecked checkboxes in the menu. |

Found in:
* [Menu File](README.md#menu-file)

### menu

Defines a menu header string.

Usage:
```
menu header
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| header | String | 1-16 characters | Menu header string |

Found in:
* [Menu File](README.md#menu-file)

### menu_item

Places a menu item in a menu.

Usage:
```
menu_item name
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| name | Identifier | ```new```, ```load```, ```save```, ```saveas```, ```exit```, ```music```, ```sfx```, ```controls```, ```about```, ```div``` | Name of item to be placed in menu. |

Found in:
* [Menu File](README.md#menu-file)

### controls

Defines the filename for the [Controls File](#controls-file).

Usage:
```
controls filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-987 characters | Filename for controls file |

Found in:
* [Menu File](README.md#menu-file)

### about

Defines the filename for the [About File](#about-file).

Usage:
```
about filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-987 characters | Filename for about file |

Found in:
* [Menu File](README.md#menu-file)

### text1_bg

Defines the background color of text style 1, based on the default palette.

Usage:
```
text1_bg index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-15 | Palette index |

Found in:
* [Menu File](README.md#menu-file)

### text1_fg

Defines the foreground color of text style 1, based on the default palette.

Usage:
```
text1_bg index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-15 | Palette index |

Found in:
* [Menu File](README.md#menu-file)

### text2_bg

Defines the background color of text style 2, based on the default palette.

Usage:
```
text2_bg index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-15 | Palette index |

Found in:
* [Menu File](README.md#menu-file)

### text2_fg

Defines the foreground color of text style 2, based on the default palette.

Usage:
```
text2_bg index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-15 | Palette index |

Found in:
* [Menu File](README.md#menu-file)

### text3_bg

Defines the background color of text style 3, based on the default palette.

Usage:
```
text3_bg index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-15 | Palette index |

Found in:
* [Menu File](README.md#menu-file)

### text3_fg

Defines the foreground color of text style 3, based on the default palette.

Usage:
```
text3_bg index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-15 | Palette index |

Found in:
* [Menu File](README.md#menu-file)

### tb_dim

Defines the dimensions of the toolbar, measured in tiles.

Usage:
```
tb_dim width height
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| width | Integer | 1-40 | Width of toolbar, in tiles |
| height | Integer | 1-4 | Height of toolbar, in tiles |

Found in:
* [Menu File](README.md#menu-file)

### tool

Places a tool in the toolbar.

Usage:
```
tool name
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| name | Identifier | ```inventory```, ```walk```, ```run```, ```look```, ```use```, ```talk```, ```strike```, ```pin``` | Name of tool to be placed in toolbar. |

Found in:
* [Menu File](README.md#menu-file)

### tool_tiles

Defines the tiles for a button in the toolbar. Number of tiles defined must be evenly divisible by toolbar height.

Usage:
```
tool_tiles [tiles]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tiles | Tile | 1-160 tiles | Tile map for toolbar button |

Found in:
* [Menu File](README.md#menu-file)

### inventory

Defines the filename for the [Inventory File](README.md#inventory-file).

Usage:
```
inventory filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-987 characters | Filename for inventory file |

Found in:
* [Menu File](README.md#menu-file)

### walk

Defines the sprite frame index for the "walk" mouse cursor. Note: mouse cursor sprites cannot be flipped.

Usage:
```
walk index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-511 | Sprite frame index for mouse cursor |

Found in:
* [Menu File](README.md#menu-file)

### run

Defines the sprite frame index for the "run" mouse cursor. Note: mouse cursor sprites cannot be flipped.

Usage:
```
run index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-511 | Sprite frame index for mouse cursor |

Found in:
* [Menu File](README.md#menu-file)

### look

Defines the sprite frame index for the "look" mouse cursor. Note: mouse cursor sprites cannot be flipped.

Usage:
```
look index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-511 | Sprite frame index for mouse cursor |

Found in:
* [Menu File](README.md#menu-file)

### use

Defines the sprite frame index for the "use" mouse cursor. Note: mouse cursor sprites cannot be flipped.

Usage:
```
use index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-511 | Sprite frame index for mouse cursor |

Found in:
* [Menu File](README.md#menu-file)

### talk

Defines the sprite frame index for the "talk" mouse cursor. Note: mouse cursor sprites cannot be flipped.

Usage:
```
talk index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-511 | Sprite frame index for mouse cursor |

Found in:
* [Menu File](README.md#menu-file)

### strike

Defines the sprite frame index for the "strike" mouse cursor. Note: mouse cursor sprites cannot be flipped.

Usage:
```
strike index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 0-511 | Sprite frame index for mouse cursor |

Found in:
* [Menu File](README.md#menu-file)

### duration

Defines the duration of the title screen animation.

Usage:
```
duration time
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| time | Integer | 0-65535 | Duration of title screen, in jiffys (60 jiffys = 1 second) |

Found in:
* [Title Screen File](README.md#title-screen-file)

### bitmap

Defines the filename of the [raw data bitmap file](README.md#raw-image-files) to convert for loading into the background layer.

Usage:
```
bitmap filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-993 characters | Filename for bitmap file |

Found in:
* [Title Screen File](README.md#title-screen-file)
* [Level Files](README.md#level-files)

### music

Defines the filename of the [VGM file](README.md#vgm-files) to convert for playing background music.

Usage:
```
bitmap filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-993 characters | Filename for bitmap file |

Found in:
* [Title Screen File](README.md#title-screen-file)
* [Level Files](README.md#level-files)

### sprite_frames

Defines the sequence of frames that a sprite lopos through while moving.

Usage:
```
sprite_frames index offset [frames]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 1-127 | Sprite index |
| offset | Integer | 0-15 | Color palette offset |
| frames | Sprite | 1-31 sprite frames | Sprite frame sequence |

Found in:
* [Title Screen File](README.md#title-screen-file)
* [Level Files](README.md#level-files)

### sprite

Displays a sprite at a specified position.

Usage:
```
sprite index x y
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 1-127 | Sprite index |
| x | Integer | 0-319 | Screen position x-coordinate, in pixels |
| y | Integer | Title Screen: 0-239; Level: 8-207 | Screen position y-coordinate, in pixels |

Found in:
* [Title Screen File](README.md#title-screen-file)
* [Level Files](README.md#level-files)

### tiles

Displays a row of tiles at a specified position.

Usage:
```
tiles offset x y [tiles]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| offset | Integer | 0-15 | Color palette offset |
| x | Integer | 0-39 | Screen position x-coordinate, in tiles |
| y | Integer | Title Screen: 0-29; Level: 1-25 | Screen position y-coordinate, in tiles |
| tiles | Tile | 1-40 tiles | Tiles to display, from left to right |

Found in:
* [Title Screen File](README.md#title-screen-file)
* [Level Files](README.md#level-files)

### wait

Delays execution of the next animation instruction until the specified time has elapsed.

Usage:
```
wait time
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| time | Integer | 0-255 | Duration of delay, in jiffys (60 jiffys = 1 second) |


Found in:
* [Title Screen File](README.md#title-screen-file)
* [Level Files](README.md#level-files)

### sprite_move

Moves sprite from current position.

Usage:
```
sprite_move index delay steps x y
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 1-127 | Sprite index |
| delay | Integer | 1-255 | Delay between steps, in jiffys (60 jiffys = 1 second) |
| steps | Integer | 1-255 | Number of steps to move |
| x | Integer | -128-127 | Number of pixels to move to the right (or left, if negative) for each step |
| y | Integer | -128-127 | Number of pixels to move down (or up, if negative) for each step |

Found in:
* [Title Screen File](README.md#title-screen-file)
* [Level Files](README.md#level-files)

### inv_dim

Defines the dimensions of the inventory control, measured in tiles.

Usage:
```
inv_dim width height
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| width | Integer | 1-40 | Width of inventory control, in tiles |
| height | Integer | 1-4 | Height of inventory control, in tiles |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_item_dim

Defines the dimensions of an inventory item button, measured in tiles.

Usage:
```
inv_item_dim width height
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| width | Integer | 1-39 | Width of inventory item button, in tiles |
| height | Integer | 1-4 | Height of inventory item button, in tiles |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_empty

Defines the tilemap for an empty inventory item button.

Usage:
```
inv_empty [tiles]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tiles | Tile | Number of tiles specified by [**inv_item_dim**](#inv_item_dim) | Tilemap for empty item button, rows going down |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_left_margin

Defines a row of tiles to display to the left of each inventory item button.

Usage:
```
inv_empty [tiles]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tiles | Tile | 1-38 | Tiles to display, from left to right |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_right_margin

Defines a row of tiles to display to the right of each inventory item button.

Usage:
```
inv_empty [tiles]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tiles | Tile | 1-38 tiles | Tiles to display, from left to right |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_quant

Defines the appearance of inventory item quantities.

Usage:
```
inv_quant style width
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| style | Integer | 0-3 | Text style for quantity display (0 = menu style) |
| width | Integer | 1-5 | Width of quantity display in digits/tiles |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_quant_margin

Defines the tiles to display above the inventory item quantity box if the item button is taller than 1 tile. May be a single tile or sequence that repeats for the width of the quantity display.

Usage:
```
inv_quant_margin [tiles]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tiles | Tile | 1-5 tiles | Tiles to display, from left to right |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_scroll

Defines the inventory scrollbar tiles.

Usage:
```
inv_scroll up middle down
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| up | Tile | Any | Tile for scroll-up button |
| middle | Tile | Any | Tile to fill in column between scroll buttons |
| down | Tile | Any | Tile for scroll-down button |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_scroll_margin

Defines the tiles to display to the left of the inventory scrollbar.

Usage:
```
inv_scroll_margin [tiles]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tiles | Tile | 1-38 tiles | Tiles to display, from left to right |

Found in:
* [Inventory File](README.md#inventory-file)

### inv_item

Defines an inventory item, its initial and potential quantity, its mouse cursor frame (cannot be flipped) and its button tile map.

Usage:
```
inv_item name init max cursor [tiles]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| name | Identifier | Unique item name | Name of item to be used in [**item_trigger**](#item_trigger) and [**get_item**](#get_item) arguments |
| init | Integer | 0-65535 | Initial quantity of item |
| max | Integer | 1-65535 | Maximum quantity of item |
| cursor | Integer | 0-511 | Item cursor frame |
| tiles | Tile | Number of tiles specified by [**inv_item_dim**](#inv_item_dim) | Tilemap for item button, rows going down |


Found in:
* [Inventory File](README.md#inventory-file)

### level

Defines the filename for a [Level File](README.md#level-files). Each level will be indexed (starting with zero) based on the order in which the levels are defined.

Usage:
```
level filename
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| filename | String | 1-995 characters | Filename for a level file |

Found in:
* [Zone Files](README.md#zone-files)

### end_anim

Marks the end of an animation sequence that began with [**init**](#init), [**first**](#first), [**tool_trigger**](#tool_trigger) or [**item_trigger**](#item_trigger).

Usage:
```
end_anim
```

No arguments.

Found in:
* [Level Files](README.md#level-files)

### sprite_hide

Stops displaying a sprite.

Usage:
```
sprite_hide index
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| index | Integer | 1-127 | Sprite index |

Found in:
* [Level Files](README.md#level-files)

### init

Marks the beginning of an animation sequence that will always be played first when a level is loaded.

Usage:
```
init
```

No arguments.

Found in:
* [Level Files](README.md#level-files)

### first

Marks the beginning of an animation sequence that will only be played when a level is loaded for the first time.  Will be played immediately after the [**init**](#init) sequence, if defined, otherwise is played first upon loading.

Usage:
```
first
```

No arguments.

Found in:
* [Level Files](README.md#level-files)

### text

Prints a line of text to the text area at the current line. Scrolls the text area up one line before printing if the current line is past the bottom.

Usage:
```
text style [line]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| style | Integer | 0-3 | Text style for this line (0 = menu style) |
| line | String | 1-38 characters, including spaces after concatenation | Line to print |

Found in:
* [Level Files](README.md#level-files)

### scroll

Scrolls the text area up by the specified number of lines.

Usage:
```
scroll lines
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| lines | Integer | 1-4 | Number of text area lines to scroll up |

Found in:
* [Level Files](README.md#level-files)

### line

Skips a line in the text area, moving the current line down to the next line. Scrolls the text area up one line if the current line is past the bottom.

Usage:
```
line
```

No arguments.

Found in:
* [Level Files](README.md#level-files)

### clear

Clears the text area and resets the current line to the top.

Usage:
```
clear
```

No arguments.

Found in:
* [Level Files](README.md#level-files)

### go_level

Loads a new level.

Usage:
```
go_level zone level
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| zone | Integer | 0-255 | Zone index |
| level | Integer | 0-9 | Level index |

Found in:
* [Level Files](README.md#level-files)

### tool_trigger

Begins an animation sequence triggered by applying a tool to a location within a rectangle of tile squares.

Usage:
```
tool_trigger tool x1 y1 x2 y2
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| tool | Identifier | ```walk```, ```run```, ```look```, ```use```, ```talk```, ```strike``` | Tool that triggers the sequence |
| x1 | Integer | 0-39 | Minimum tile square x-coordinate |
| y1 | Integer | 1-25 | Minimum tile square y-coordinate |
| x2 | Integer | 0-39 | Maximum tile square x-coordinate |
| y2 | Integer | 1-25 | Maximum tile square y-coordinate |

Found in:
* [Level Files](README.md#level-files)

### item_trigger

Begins an animation sequence triggered by applying an inventory item to a location within a rectangle of tile squares.

Usage:
```
item_trigger item requirement cost x1 y1 x2 y2
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| item | Identifier | Any name defined by an [**inv_item**](#inv_item) key in the [Inventory File](README.md#inventory-file) | Item that triggers the sequence |
| requirement | Integer | 1-65535 | Quantity of item required to trigger sequence |
| cost | Integer | 0-65535, must be no greater than requirement | Quantity of item to be debited from inventory after sequence |
| x1 | Integer | 0-39 | Minimum tile square x-coordinate |
| y1 | Integer | 1-25 | Minimum tile square y-coordinate |
| x2 | Integer | 0-39 | Maximum tile square x-coordinate |
| y2 | Integer | 1-25 | Maximum tile square y-coordinate |

Found in:
* [Level Files](README.md#level-files)

### if

Begins a sub-sequence that will only be executed if the specified state is true.

Usage:
```
if state
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| state | Identifier | Any | State to test for true. If not previously defined, will be initialized to false and sub-sequence will not be executed |

Found in:
* [Level Files](README.md#level-files)

### if_not

Begins a sub-sequence that will only be executed if the specified state is false.

Usage:
```
if state
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| state | Identifier | Any | State to test for false. If not previously defined, will be initialized to false and sub-sequence will be executed |

Found in:
* [Level Files](README.md#level-files)

### end_if

Ends a sub-sequence that began with [**if**](#if) or [**if_not**](#if_not).

Usage:
```
end_if
```

No arguments.

Found in:
* [Level Files](README.md#level-files)

### set_state

Sets a state to true.

Usage:
```
set_state state
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| state | Identifier | Any | State to set to true |

Found in:
* [Level Files](README.md#level-files)

### clear_state

Sets a state to false.

Usage:
```
clear_state state
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| state | Identifier | Any | State to set to false |

Found in:
* [Level Files](README.md#level-files)

### get_item

Adds a quantity of an item to the inventory.

Usage:
```
get_item item quantity
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| item | Identifier | Any name defined by an [**inv_item**](#inv_item) key in the [Inventory File](README.md#inventory-file) | Item to add to inventory |
| quantity | Integer | 1-65535 | Quantity of item to add |

Found in:
* [Level Files](README.md#level-files)
