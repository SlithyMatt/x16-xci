# XCI Appendix: Configuration Walkthrough of the Example Game

The example game that comes with the XCI toolchain, "My Game", is not really a game so much as an exercise in game design for the sake of testing and instruction. A "real" game should be bigger and more complex, with an actual story, characters, action, problem solving, etc. More than minimal effort on creating graphics and sound would also be a good idea!

This guide is a level-by-level walkthrough of the game configuration, showing how XCI is used to build game mechanics and create sound and graphics.

## Contents

* [Top-Level Configuration](#top-level-configuration)
* [Zone 0](#zone-0)
   * [Level 0](#zone-0-level-0)
   * [Level 1](#zone-0-level-1)
* [Zone 1](#zone-1)
   * [Level 0](#zone-1-level-0)
   * [Level 1](#zone-1-level-1)
   * [Level 2](#zone-1-level-2)
* [Zone 2](#zone-2)
   * [Level 0](#zone-2-level-0)
   * [Level 1](#zone-2-level-1)
   * [Level 2](#zone-2-level-2)
   * [Level 3](#zone-2-level-3)
   * [Level 4](#zone-2-level-4)
   * [Level 5](#zone-2-level-5)
   * [Level 6](#zone-2-level-6)
   * [Level 7](#zone-2-level-7)
   * [Level 8](#zone-2-level-8)
   * [Level 9](#zone-2-level-9)


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

This level is covered in the main [**Level Files**](../README.md#level-files) documentation.

### Zone 0, Level 1

This level is covered in the [**More Level Examples**](../README.md#more-level-examples) sub-section of the main [**Level Files**](../README.md#level-files) documentation.

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

The first trigger is for "using" the front door. If the avatar is near the door, we go to one of the levels that take place in front of the house ([1:1](#zone-1-level-1) or [2:6](##zone-2-level-6)). As we'll see later in the game, we can come back to this level after having driven away and then back to the house. This can only happen if the ```got_screwdriver``` state is true, so that decides which level we go to when going through the front door, as each of those levels has a different placement of the car sprites and different destination levels when driving away. There is also a subsequence in case the avatar is still standing by the kitchen doorway, and the player is informed that they can't reach the door from there.

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

This trigger is for "using" the door to the living room. Like with the front door, the avatar must be near it to open the door and go to the living room level ([1:2](#zone-1-level-2)). Otherwise, the player will again be reminded that they can't reach the door from the kitchen doorway.

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

This trigger is for "walking" through the kitchen doorway. In this case, since there is no door to "use", the player will always end up back in the [kitchen](#zone-0-level-0). It's just a matter of the animation required to do that. If the avatar is near the door, it will need to walk across the screen, a reverse of the previous "walk" trigger. If the avatar is already by the doorway, it will simply face the doorway, then go there a half-second later.

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

This trigger is for "running" through the kitchen doorway, which works the same as the previous trigger, except that it will move twice as quickly, so the wait time is cut in half before moving on to the [kitchen](#zone-0-level-1). This will make the avatar reach the kitchen twice as quickly, but will require the player to explicity select the "run" tool as it comes after the "walk" trigger. If the avatar is already by the doorway, it does the same animation as the "walk" trigger in this state.

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

We can see that the house background is being reused for this level after having appeared in [the very first level](#zone-0-level-0). Because of this, we can reuse much of the animation for this level.

```
init
sprite_frames 2  0  30 31 32 33 34 35 36 37 # Flag waving
sprite 2  282 50                            # Top-right of pole
sprite_move 2  6  255  0 0                  # Fixed position, 10 fps, 25.5 s
sprite_frames 3  0  38 39  # Front of car
sprite 3  86 170           # Parked, not moving
sprite_frames 4  0  40     # Rear of car
sprite 4  102 170          # Parked, not moving
sprite_frames 1  0  6
sprite 1  148 170
end_anim
```

Like before, the **init** sequence sets up the waving flag and the car, this time with frames already defined for the front end of the car to drive away. Since the rear of the car is empty in the beginning, only a single frame is defined. that will change once the avatar "enters" the car to drive away and the sprite frames will change to reflect that. What's new in this level is that the avatar is also placed in front of the house, facing front. Again, only a single frame is defined as the only move coming up will require him to turn to the left and never face front again.

Note that there is no **first** sequence as this level has no need for one. We've seen this scenery before and don't need any further exposition.

```
tool_trigger look  18 21  19 22
clear
text 1 There we are.
end_anim
```

The first trigger is for "looking" at the avatar. We know that this level is only interactive when the avatar is located precisely within this rectangle, so we can use it as an unconditional trigger area.

```
tool_trigger talk  18 21  19 22
clear
text 2 "Lookin' good!"
end_anim
```

This trigger is for the same area containing the avatar, but requires the "talk" tool to be explicitly selected because it comes after the "look" trigger.  Again, we use text style 2 for the playable character to talk, in this case to himself.

```
item_trigger banana 1 1  18 21  19 22
clear
if first_banana
text 1 We're not hungry anymore.
wait 60
text 2 Not even for bananas.
get_item banana 1 # replenish lost banana
end_if
if_not first_banana
text 1 We could use a snack for the road.
wait 60
text 2 Mmm... banana!
set_state first_banana
end_if
end_anim
```

This trigger is also for the avatar area, but this time with a banana from the inventory. This is the first **item_trigger** we see with a non-zero cost argument. This means that the banana quantity will be debited by 1 as a result of this trigger. However, as we see in the first sub-sequence, if ```first_banana``` is already set, we tell the player that the character isn't hungry anymore and re-credit the banana that was debited with a **get_item**. This way, the player never notices that they were ever short a banana. However, if this is the first time it was triggered, ```first_banana``` will not have been defined and therefore initialized to false and the second sub-sequence is executed. Now we indicate in the text that the banana is being eaten and the inventory debit goes through along with ```first_banana``` being set to true. After this first trigger, the player will be able to see that the quantity of bananas has gone down to 2, but it will never go any lower because of the first sub-sequence.

```
item_trigger coffee 1 0  18 21  19 22
clear
text 1 We're still pretty awake.
wait 60
text 1 Let's save the coffee for later.
end_anim
```

This trigger attempts to do the same with the coffee, but has a zero cost and lets the player know that they don't need coffee now.

```
item_trigger phone 1 0  18 21  19 22
clear
text 1 Don't need to call for a ride.
wait 60
text 1 Our car is right here.
end_anim
```

This final trigger for the avatar is with the phone item, which the player has had since the start of the game. The phone is not consumable, so it has a zero cost. This makes it effectively a use trigger on an inventory item. But in this case, we say that there's no need to use the phone at this time. Perhaps in a different version of the game the player could use the phone to call for a ride or do some other task.

```
tool_trigger look  10 21  15 24
clear
text 1 That's our car.
wait 60
text 1 We should have our keys.
end_anim
```

The default trigger for the car is with the "look" tool. This provides a hint that to use the car, the player needs to use the keys from the inventory.

```
tool_trigger use  10 21  15 24
clear
text 1 Not much you can do with a car
text 1 without keys.
end_anim
```

This trigger is for the case where the player explicitly tries to apply the "use" tool on the car, which is not how we want the game to proceed. Here's another, stronger hint that the player should use the keys.

```
tool_trigger talk  10 21  15 24
clear
text 2 "Hello, car."
wait 60
text 3 "Hello, Michael."
wait 60
text 2 "Um... My name is John."
wait 60
text 3 "Sorry. Wrong game."
end_anim
```

The last **tool_trigger** for the car is for "talking" to the car. This is just a little Easter Egg, as it is not what a player would be expected to do unless they were really exploring the level. So, we reward that curiosity with our first dialog between the playable character and a non-playable character (NPC). As before, we show the playable character using text style 2 for their own dialog. The NPC (in this case, the car) uses text style 3 (blue on black) for its dialog, as will all future NPCs.

```
item_trigger keys 1 0  10 21  15 24
sprite_frames 1  0  1H 2H 3H 2H 1H 4H 5H 4H
sprite_move 1  4  26  -2 0
wait 104
sprite_hide 1
sprite_frames 4  0  41 42
sprite_move 3  2  42  -2 0
sprite_move 4  2  42  -2 0
wait 84
go_level 2 0
end_anim
```

Finally, we have the trigger that lets us move forward in the game, by applying the keys to the car. We start the animation by turning the avatar to the left and walking him toward the car using a new frame loop. We don't use the "walk" or "run" tools here as this is a more specialized animation and the avatar is already sufficiently close to the car that it makes visual sense just to apply the keys at this point. Once the avatar is finished walking toward the car, the avatar is immediately hidden and the sprite for the rear of the car gets a new frame sequence showing the avatar's head inside the window. Then we start a pair of sprite movements that will keep both halves of the car moving together until they get to the far left of the screen. At that point, we go to [level 0 of zone 2](#zone-2-level-0).

```
tool_trigger use  19 16  22 21
sprite_frames 1  0  11
wait 30
set_state front_to_foyer
go_level 1 0
end_anim
```

The last trigger is for the front door so that we can go back to the [foyer](#zone-1-level-0). First the avatar sprite is given a new frame to turn towards the house.  Then a half-second later we set the ```front_to_foyer``` state to true so that the avatar will be by the door when that level is loaded.

### Zone 1, Level 2

This level uses [**mygame_z1_level2.xci**](mygame_z1_level2.xci):

```
# Zone 1, level 2

bitmap mygame_livingroom.data
music zone0.vgm
```

This level takes place in the living room, which introduces a new background bitmap.

![Living Room](#mygame_livingroom.png)

This is another scene, like the [kitchen](#zone-0-level-1), where the perspective switches to first-person. We don't need to keep things on the scale of the avatar, which makes it easier to accurately render items that can be added to the inventory. One could make a game that is all first-person and have more sprite frames freed up for in-scene animation.

```
init
sprite_frames 2  0  47 48
if_not laptop_taken
tiles  0  22 17  176 177 176H
tiles  0  22 18  178 179 178H
if_not usb_taken
tiles  0  26 19  183
end_if
if usb_inserted
tiles  0  22 19  180 181 182
sprite 2  180 139
sprite_move 2  15  255  0 0
end_if
if_not usb_inserted
tiles  0  22 19  180 181 180H
end_if
end_if
end_anim
```

The **init** sequence sets up tiles for any items that have not yet been taken from the scene and added to the inventory. We use state variables for that. Unconditionally, we set the sprite frame sequence for the laptop screen, which is simply a blinking cursor. The rest of the sequence is a sub-sequence that is executed if the laptop has not been taken, so it needs to be rendered on the coffee table, starting with a two-row tilemap for the upper two-thirds. Then within that sub-sequence are three sub-sequences based what has been done with the USB drive.  If it wasn't taken, it is rendered on the table as a single tile. The next sub-sequence checks if it has been inserted into the laptop. If it has, the bottom third of the laptop is rendered with the USB drive sticking out and then the screen sprite is placed to show the prompt blinking.  If the USB drive hasn't been inserted, the last sub-sequence is executed, rendering the bottom without anything inserted.

```
first
text 1 Welcome to our living room.
end_anim
```



```
tool_trigger use  38 3  39 25
set_state lr_to_foyer
go_level 1 0
end_anim
```



```
tool_trigger look  38 3  39 25
clear
text 1 That's the door back to the foyer.
end_anim
```



```
tool_trigger look  7 4  11 17
clear
text 1 That's our bedroom.
wait 60
text 1 Nobody goes in there.
end_anim
```



```
tool_trigger use  7 4  11 17
clear
text 1 We can't go in the bedroom now.
wait 60
text 1 Any kind of business in there
text 1 would be a holy grail moment.
end_anim
```



```
tool_trigger look  20 4  29 10
clear
text 2 Yeah, we really like bananas.
end_anim
```



```
tool_trigger use 22 17  24 19
if_not laptop_taken
if usb_inserted
clear
text 1 Ok, we'll take the laptop with us.
wait 30
sprite_hide 2
tiles  0  22 17  0 0 0
tiles  0  22 18  0 0 0
tiles  0  22 19  0 0 0
get_item laptop 1
get_item thumbdrive 1
set_state laptop_taken
end_if
if_not usb_inserted
clear
text 1 It's not working. It needs to
text 1 boot from a thumbdrive.
end_if
end_if
end_anim
```



```
tool_trigger look 22 17  24 19
if_not laptop_taken
if usb_inserted
text 1 Oh yeah, that's the stuff.
end_if
if_not usb_inserted
text 1 That's our trusty laptop.
wait 60
text 1 Works great except that
text 1 it won't boot on its own.
end_if
end_if
end_anim
```



```
item_trigger thumbdrive  1 1  22 17  24 19
tiles 0  24 19  182
clear
text 1 Ok, now we can boot the laptop
wait 60
sprite 2  180 139
sprite_move 2  15  255  0 0
set_state usb_inserted
end_anim
```



```
tool_trigger use  26 19  26 19
if_not usb_taken
clear
text 1 This thumbdrive should come in handy.
get_item thumbdrive 1
tiles  0  26 19  0
set_state usb_taken
end_if
end_anim
```



```
tool_trigger look  26 19  26 19
if_not usb_taken
clear
text 1 It's a USB thumbdrive.
wait 60
text 1 Might be a bootable image.
end_if
end_anim
```
