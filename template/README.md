# XCI Game Template

The files in this directory a minimal "game" that can be built and run with XCI. It is a good starting point when creating a game "from scratch", rather than modifying the [example game](../example).

This template does define some things that are optional, such as an inventory, a full menu bar, and help files. As discussed in the [main documentation](../README.md), the menu bar only needs to have a single menu defined, and the only required menu item is "New Game".  A toolbar must also be defined with at least one tool. In this case, that tool is the inventory, but it can be a different tool and no inventory is defined. In the inventory template, a single item is defined (money), and an inventory control is defined that can display up to 2 inventory items at a time, and a scrollbar. This inventory definition was only done to have template versions of each inventory file key, just like the menu.

The sprites file contains only a single sprite frame defined for a mouse cursor, which could be modified, and an extra sprite frame that is completely transparent as a template. Similarly, the tiles file has the required transparent tile at the beginning, followed by a plain white square that is used for blank space in the menu and inventory controls. Then there are 29 template tiles that are all transparent followed by the default ASCII character tileset, then one more transparent template tile. The white square and all the ASCII tiles may be redefined. Just be aware that the white square is used extensively by the menu and inventory templates, and the ASCII tiles are used by the engine itself for rendering text in the menu, help screens, inventory quantities, and of course the text area. Changes to these tiles should only be a matter of style, not purpose so that the text features of the engine aren't broken. Also be aware that the engine is hardocded to treat color index 6 (blue in the default palette) as the text background and color index 0 (white in the default palette) as the text foreground color so that the configuration of the menu and text area text color configurations work as expected.

The level template has no animation or triggers, but it does define empty **first** and **init** sequences, but neither are strictly required for levels and can just be deleted.

The following GIF shows the complete extent of the template game functionality:

![gameplay](gameplay.gif)

For more information on how to fill out these templates, see the [main documentation](../README.md) and the [XCI configuration syntax guide](../XCI_SYNTAX.md). Feel free to copy in larger parts of the [example game](../example) into the templates to help kickstart your own game development. To better understand how that game was developed, see the [example game appendix](../example/APPENDIX.md) to the docs.
