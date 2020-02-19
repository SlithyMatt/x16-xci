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

| [**inv_dim**](#inv_dim) | [**inv_item_dim**](#inv_item_dim) | [**inv_item_dim**](#inv_item_dim) |
|--|--|--|
| [**inv_empty**](#inv_empty) | [**inv_left_margin**](#inv_left_margin) | [**inv_right_margin**](#inv_right_margin) |
| [**inv_quant**](#inv_quant) | [**inv_quant_margin**](#inv_quant_margin) | [**inv_scroll**](#inv_scroll) |
| [**inv_scroll_margin**](#inv_scroll_margin) [**inv_item**](#inv_item) |

Skip to [Zone File](README.md#zone-files) key:

[**level**](#level)

Skip to [Level File](README.md#level-files) keys:

| [**bitmap**](#bitmap) | [**music**](#music) | [**sprite_frames**](#sprite_frames)
|--|--|--|
| [**sprite**](#sprite) | [**tiles**](#tiles) | [**wait**](#wait) |
| [**sprite_move**](#sprite_move) | [**end_anim**](#end_anim) | [**sprite_hide**](#sprite_hide) |
| [**init**](#init) | [**first**](#first) | [**text**](#text) |
| [**scroll**](#scroll) | [**line**](#line) | [**clear**](#clear) |
| [**go_level**](#go_level) | [**tool_trigger**](#tool_trigger) | [**item_trigger**](#item_trigger) |
| [**if**](#if) | [**if_not**](#if_not) | [**end_if**](#end_if) |
| [**set_state**](#set_state) | [**clear_state**](#clear_state) | [**get_item**](#get_item) |

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

### tb_dim

Defines the dimensions of the toolbar, measured in tiles.

Usage:
```
tb_dim width height
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| width | Integer | 1-40 | Width of toolbar |
| height | Integer | 1-4 | Height of toolbar |

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
