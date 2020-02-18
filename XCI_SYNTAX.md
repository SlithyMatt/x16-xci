# XCI Configuration File Syntax
This doucment describes, key by key, the overall syntax of XCI configuration files. There are six kinds of configuration files, as described in the [main documentation](README.md):

* [Main File](README.md#main-file)
* [Menu File](README.md#menu-file)
* [Title Screen File](README.md#title-screen-file)
* [Inventory File](README.md#inventory-file)
* [Zone Files](README.md#zone-files)
* [Level Files](README.md#level-files)

For each key, the value format will be described by a set of argument names. Arguments surrounded by brackets can vary in number of instances per key, for example the set of frame indices for a [**sprite_frames**](#sprite_frames) key. Then, each argument is described in terms of type, range and meaning. Finally, the set of file types in which this key may appear is listed.

## Types

There are five basic types for arguments:

* Integer: Simple decimal number value, with no decimal point. May be negative, depending on range.
* String: Literal characters and escape codes. String values are whitespace-delimited. Keys that take a variable number of strings, like [**text**](#text), may be reconsituting a concatentated string, using single spaces between the string tokens. Certain characters require escape codes, mainly the pound/hash (as ```\#```) and the backslash (as ```\\```). Quotes are not required around string arguments, so they will be part of the value sent to the engine as literal quote characters. At this time, only standard ASCII printable characters are supported, namely exclamation point (x21, '!') through tilde (x7E, '~').
* Tile: Positive integer from 0 to 719. May be followed immediately (no spaces in between) by an ```H```, a ```V``` or both. The letters indicated how the tile is to be flipped. Examples: ```1``` is tile 1 with no flipping; ```2H``` is tile 2 flipped horizontally; ```3V``` is tile 3 flipped vertically; ```4HV``` is tile 4 flipped both horizontally and vertically.
* Sprite: Like a Tile, but is based on sprite indices, which range from 1 to 127. May also be suffixed with ```H``` and/or ```V``` for flipping.
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

Skip to:
[**title**](#title)
[**author**](#author)
[**palette**](#palette)
[**tiles_hex**](#tiles_hex)

### title

Defines the title of the game. Should contain version number or something to uniquely identify revision of the configuration to ensure that only compatible saved games are loaded.

Usage:
```
title [text]
```

| Argument | Type | Range | Meaning |
|--|--|--|--|
| text | String | 1-255 characters, including spaces | Title of game |

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
| text | String | 1-255 characters, including spaces | Author of game |

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
