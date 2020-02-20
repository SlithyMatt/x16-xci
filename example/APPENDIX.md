# XCI Appendix: Configuration Walkthrough of the Example Game

The example game that comes with the XCI toolchain, "My Game", is not really a game so much as an exercise in game design for the sake of testing and instruction. A "real" game should be bigger and more complex, with an actual story, characters, action, problem solving, etc. More than minimal effort on creating graphics and sound would also be a good idea!

This guide is a level-by-level walkthrough of the game configuration, showing how XCI is used to build game mechanics and create sound and graphics.

## Contents

* [Top-Level Configuration](#top-level-configuration)
* [Zone 0](#zone-0)
   * [Level 0](#zone-0,-level-0)
   * [Level 1](#zone-0,-level-1)
* [Zone 1](#zone-1)
   * [Level 0](#zone-1,-level-0)
   * [Level 1](#zone-1,-level-1)
   * [Level 2](#zone-1,-level-2)
* [Zone 2](#zone-2)
   * [Level 0](#zone-2,-level-0)
   * [Level 1](#zone-2,-level-1)
   * [Level 2](#zone-2,-level-2)
   * [Level 3](#zone-2,-level-3)
   * [Level 4](#zone-2,-level-4)
   * [Level 5](#zone-2,-level-5)
   * [Level 6](#zone-2,-level-6)
   * [Level 7](#zone-2,-level-7)
   * [Level 8](#zone-2,-level-8)
   * [Level 9](#zone-2,-level-9)


## Top-Level Configuration
The [main documentation](../README.md) goes through all of the top-level configuration files for this game.

* [Main File](../README.md#main-file)
* [Menu File](../README.md#menu-file)
* [Controls File](../README.md#controls-file)
* [About File](../README.md#about-file)
* [Title Screen File](../README.md#title-screen-file)
* [Inventory File](../README.md#inventory-file)

## Zone 0

Zone 0 was covered comprehensively in the [main documentation](../README.md). The [Zone File](../README.md#zone-files) itself is described in detail. In fact, this guide will skip over the remaining zone files as they pretty self-explanatory once you've seen one.

### Zone 0, Level 0

This level is covered in the main [**Level Files**](#level-files) documentation.

### Zone 0, Level 1

This level is covered in the [**More Level Examples**](#more-level-examples) sub-section of the main [**Level Files**](#level-files) documentation.

## Zone 1

Zone 1 is the first zone that is loaded after the start of the game. It has three levels that take place in other parts of the house and right outside the front door. You will see in each of these levels that "zone0.vgm" is used for music because writing music for another zone was not really necessary, but it does illustrate a way to define a zone by having consistent music through it, but each level can have unique music, if you desire.

### Zone 1, Level 0

This level is defined by [**mygame_z1_level0.xci**](mygame_z1_level0.xci). As with the other levels in ths guide, we will be splitting up the configuration into sections that are described immediately afterward.

Let's start from the beginning.

```
# Zone 1, level 0

bitmap mygame_foyer.data
music zone0.vgm
```

This level takes place in the foyer of the house, which is rendered as an absurdly long hallway.

![Foyer](mygame_foyer.png)

This was done to better scale the level to the avatar sprite, which makes its first appearance since the title screen. For simplicity, a single sprite is used for the avatar, but with a 200-pixel scene height, a 16x16 character can look pretty small. Having a scene matted out like this can help depict a more closed-in space in which an avatar can navigate. Otherwise, you can try using multiple synchronized sprites for the avatar, as shown with the car sprites in later levels.

```
init
if kitchen_to_foyer
sprite_frames 1  0  1H 2H 3H 2H 1H 4H 5H 4H
sprite 1  288 128
clear_state near_door
clear_state kitchen_to_foyer
end_if
if lr_to_foyer
sprite_frames 1  0  1 2 3 2 1 4 5 4
sprite 1  18 128
clear_state lr_to_foyer
set_state near_door
end_if
if front_to_foyer
sprite_frames 1  0  1 2 3 2 1 4 5 4
sprite 1  18 128
clear_state front_to_foyer
set_state near_door
end_if
end_anim
```

The **init** sequence consists entirely of conditional sub-sequences, so there is no animation that is guaranteed to run during this level. Each sub-sequence is based on a state that indicates which level we came from.  The first time we reach this level it is from the kitchen, so ```kitchen_to_foyer``` will be true.  So, the avatar sprite (index 1) is placed by the doorway to the kitchen and facing left. Sprite frames 1-5 are the avatar facing left, so the defined sequence has all of those frames flipped horizontally. The other two sub-sequences start the avatar from the opposite end of the foyer, within reach of both doors. Here you can see that in each case the sprite is set to use the left-facing frames and the ```near_door``` state is set to true so that the player can immediately open either door, but would have to walk across the foyer to get back to the kitchen.

```
first
text 1  There you are.
wait 60
text 1  You are me.
wait 60
text 1  We are we.
wait 60
text 1  Let's go do something.
end_anim
```

The **first** sequence displays some text to explain that, in fact, the player is John Doe and the voice of the narration switches to first person, plural. This is all that is placed in this sequence, as even if the we go back to the kitchen, we don't need to see this text again, but we do need the level to be set up in the same way, so all the sprite and state initialization is kept within the **init** sequnece.

```
tool_trigger use  0 8  1 18
if near_door
sprite_frames 1  0  3H
wait 30
if_not got_screwdriver
go_level 1 1
end_if
if got_screwdriver
set_state from_house
go_level 2 6
end_if
if_not near_door
clear
text 1  We can't reach the door from here.
end_if
end_anim
```

The first trigger is for "using" the front door. If the avatar is near the door, we go to one of the levels that take place in front of the house ([1:1](#zone-1,-level-1) or [2:6](##zone-2,-level-6)). As we'll see later in the game, we can come back to this level after having driven away and then back to the house. This can only happen if the ```got_screwdriver``` state is true, so that decides which level we go to when going through the front door, as each of those levels has a different placement of the car sprites and different destination levels when driving away. There is also a subsequence in case the avatar is still standing by the kitchen doorway, and the player is informed that they can't reach the door from there.

```
tool_trigger look  0 8  1 18
clear
text 1 That's the front door to the house.
end_anim
```

This trigger is also for the front door, but this time for "looking" at it. Like other "look" triggers, this gives the player some information to help them navigate the game, in this case telling them where the door leads. As it comes after the "use" trigger for the same area, the player will need to explicity select the "look" tool to trigger this sequence.

```
tool_trigger use  3 13  5 16
if near_door
sprite_frames 1  0  11
wait 30
go_level  1 2
end_if
if_not near_door
clear
text 1  We can't reach the door from here.
end_if
end_anim
```

This trigger is for "using" the door to the living room. Like with the front door, the avatar must be near it to open the door and go to the living room level ([1:2](#zone-1,-level-2)). Otherwise, the player will again be reminded that they can't reach the door from the kitchen doorway.

```
tool_trigger look  3 13  5 16
clear
text 1 That's the door to the living room.
end_anim
```

This trigger is also for the living room door, but this time for "looking" at it. As it comes after the "use" trigger for the same area, the player will need to explicity select the "look" tool to trigger this sequence.

```
tool_trigger walk  0 8  5 18
if_not near_door
sprite_move  1  4  135  -2 0
wait 255
wait 255
wait 30
set_state near_door
end_if
end_anim
```

This trigger is for "walking" to the left end of the foyer. The trigger area included both the doors, but also has some previously unclaimed space between them, so the "walk" cursor will automatically appear when the mouse is moved there. The whole area can be used for the trigger if the "walk" tool is explicitly selected. First, it checks to make sure the avatar is not already near the door, then kicks off the animation to walk there 2 pixels at a time every 4 jiffys. This takes a while to accomplish all 135 steps, so three **wait** instructions are needed to wait a grand total of 525 jiffys, or 8.75 seconds. Then the ```near_door``` state is set to true so that the player can open one of the doors. If the avatar is already near the door when this trigger occurs, nothing happens, as the whole sequence is taken up with the ```if_not near_door``` sub-sequence.

```
tool_trigger run  0 8  5 18
if_not near_door
sprite_move  1  2  135  -2 0
wait 255
wait 15
set_state near_door
end_if
end_anim
```

This trigger is for "running" to the left end of the foyer, using the same area as the previous trigger. This will make the avatar reach the doors twice as quickly, but will require the player to explicity select the "run" tool as it comes after the "walk" trigger. Again, this trigger will do nothing if the avatar is already near the doors.

```
tool_trigger walk  38 13  39 18
if near_door
sprite_frames 1  0  1 2 3 2 1 4 5 4
sprite_move  1  4  135  2 0
clear_state near_door
wait 255
wait 255
wait 30
go_level 0 1
end_if
if_not near_door
sprite_frames 1  0  3
wait 30
go_level  0 1
end_if
end_anim
```

This trigger is for "walking" through the kitchen doorway. In this case, since there is no door to "use", the player will always end up back in the [kitchen](#zone-0,-level-0). It's just a matter of the animation required to do that. If the avatar is near the door, it will need to walk across the screen, a reverse of the previous "walk" trigger. If the avatar is already by the doorway, it will simply face the doorway, then go there a half-second later.

```
tool_trigger run  38 13  39 18
if near_door
sprite_frames 1  0  1 2 3 2 1 4 5 4
sprite_move  1  2  135  2 0
clear_state near_door
wait 255
wait 15
go_level 0 1
end_if
if_not near_door
sprite_frames 1  0  3
wait 30
go_level  0 1
end_if
end_anim
```

This trigger is for "running" through the kitchen doorway, which works the same as the previous trigger, except that it will move twice as quickly, so the wait time is cut in half before moving on to the [kitchen](#zone-0,-level-0). This will make the avatar reach the kitchen twice as quickly, but will require the player to explicity select the "run" tool as it comes after the "walk" trigger. If the avatar is already by the doorway, it does the same animation as the "walk" trigger in this state.

```
tool_trigger look  38 13  39 18
clear
text 1  That's the doorway to the kitchen.
end_anim
```

This trigger is for "looking" at the kitchen doorway.  As it comes after the "walk" and "run" triggers for the same area, the player will need to explicity select the "look" tool to trigger this sequence.

```
tool_trigger look  19 12  22 15
clear
text 1  We really love bananas.
end_anim
```

This trigger is for "looking" at the painting of the banana bunch that was seen in the kitchen. Its area doesn't overlap with any previous trigger, making it the first "look" trigger to be a default action. It introduces a theme of the character really loving bananas.

```
tool_trigger talk  19 12  22 15
clear
text 2  "I love you, bananas!"
end_anim
```

This final trigger is for the same area as the previous one, but for the case where the "talk" tool was explicitly selected. Now we see the first time that the character can speak in his own voice, which uses text style 2 (yellow on black) and quotes. We keep this arrangement for the rest of the game, with text style 1 being used for narration only.

### Zone 1, Level 1

This level uses [**mygame_z1_level1.xci**](mygame_z1_level1.xci):

```
# Zone 1, level 1

bitmap mygame_house.data
music zone0.vgm
```
