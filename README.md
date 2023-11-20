# PenguinTower_c64
Penguin Tower game for Commodore 64.

You can find me at darc(at)netikka.fi

The release includes the Penguin Tower game, intro with the story and BLED. BLED (BLock EDitor) is the graphics and level editor for the game. It includes everything needed for level design and storing/packing for game use. You need to re-compile the game as there is no level loading functionality in the game. Feel free to implement - the loader is already there. 

See CSDB: https://csdb.dk/release/?id=237024

## Credits
### Penguin Tower game
- Code: Jani Hirvo aka d'Arc
- Graphics: Jani Hirvo
- Music: Side-B
- Level depacker: Skape
### Penguin Tower intro
- Code: Jani Hirvo
- Graphics: Jani Hirvo
- Music: N/A .. unfortunately
### BLED 2x2 - Block Editor 
- Code: Jani Hirvo
- Level packer: Skape
## Version history
- 7.3: Initial release (2023-11-21)
## Background
The game has been 'in development' since 199x and was never finished. While it would've been great to have the game ready, the interest kind of disappeared. Getting something ready up to 90% is easy and the last 10% takes a lot of time. Eventually the C64 was replaced with a PC, adulthood with family and responsibilities took, other hobbies entered my life. The game project was abandoned .. until now. 

Just by coincidence I got interested in looking at C64 development environments. C64 Studio looked interesting and did some quick tests. Oh man, it has everything one could dream of. Amazing piece of software and really lit my interest in C64 coding. Go get it from https://www.georg-rottensteiner.de/en/c64.html#C64_Studio . And the developer is frienldy and quickly reacting to any findings. See: https://github.com/GeorgRottensteiner/C64Studio

Luckily I had my code floppies tranferred to PC years back. It took some time to get everything to proper format but eventually first compilation was successful! Then it was just development work to get the final pieces done. Since the first successful compilation, a lot of bugs has been fixed, new features added, intro and endtro created, new gfx drawn. I decided to keep most of the graphics on purpose as close to the original levels from 199x. A small fix ended up in quite a lot of work. But it was fun. And now the game is released. 

### Thanks 
- Big thanks to testers (Ulla, Alma, Antero, Akseli, Alina, Anni, Skape).
- Skape for support and de/packer code
- Georg Rottensteiner for the amazing C64 Studio. This project would not have been finalized without it.

### Fun facts
- A few previews were shared with 10 playable levels. Then the game crashed - this was on purpose.
- There exists a unfinished PC version written in assembler. Nope, that will never be finished. Same goes with the level and graphics editor.
- The release date is the day my age reached the big five-o. 
# Developer stuff
TBD
## How to compile
TBD
## Known issues and this and that
- Notation is a mess like inThisWay, InThisWay, inthisway, itw, ... anything you can imagine. Old code - no plans to clean any of those.
- There is a lot you could optimize in the code. Feel free. ;-)
- Bomb explosions take quite many cycles .. as well as many other things. In case too many cycles have been used, animations are stopped. This is by design.
- You can explode multiple blocks by dropping bombs in right order side by side. This is by (accidental) design.
- Please provide bug fixes as pull requests or via mail. I might take a look.

# Licensing and (re-)use
- The code is released as-is. I hope you may learn something from it.
- Feel free to use any or all code in any way you like.
- If someone decides to completely redo all the levels and release a new version, that is fine. Remember to send me a copy.
- - Make sure to name it with a distinct name like 'Penguin Tower - summer levels'
- - Do not call it Penguin Tower 2
## Do not
- It is not allowed to publish Penguin Tower game on any other platforms without permission

