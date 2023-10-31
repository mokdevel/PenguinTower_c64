;----------------------------------------------
; MEMORY LOCATIONS

GAMEBMPDATA   = $0800     ;Game graphics
BLOCKANIMDATA = $1800     ;blocanim.bin
PLASMAFONT    = $2000
SPRITEGFX     = $20c0     ;sprites.spriteproject
ANIMPLASMADATA = $3200    ;plasdata.bin
DATASECTION_2 = $1d00     ;data_game.asm
FONTBMPDATA   = $3800     ;fontbmp.bin
PERCENTCHAR   = FONTBMPDATA+$2e0
PENGUINLOGO   = $3c00     ;the penguin logo 
DATASECTION_1 = $3280     ;data.asm
DATASECTION_3 = $4000     ;data_misc.asm

BONUSLEVELS   = $9000;$7f00     ;$1800     ;lvl_bons.bin
LEVELS        = $9c00;$8900     ;lvl_norm.bin
;----------------------------------------------
; Screen pointers

SCR04               = $0400            ;The default screen
SCRD8               = $d800            ;The default color screen
scr                 = $0400+(5*40)
textd8              = SCRD8+(5*40)
SCOREROW            = SCR04+$03c0      ;Scores are written here
SCOREROWD8          = SCRD8+$03c0      ;Score colors are written here 

DD00_VALUE  = $ff
D018_FONT   = $1e
D018_NEXT   = $18
D018_GAME   = $12

;PenguinTower logo charmap
PTLOGO_CHARMAP_PENGUIN = $3ec0
PTLOGO_CHARMAP_TOWER   = PTLOGO_CHARMAP_PENGUIN+(4*40)

;----------------------------------------------
; CONSTANTS

LASTLEVEL       = 100     ;The amount of levels. DO NOT CHANGE!
NO_BONUS        = $ff     ;if bonus is set to NO_BONUS, we're playing normal levels.
LEVEL_FILE_ADDR = $ad00   ;Bled uses this address as the base for levels. The level pointers start from this. 
NULL_COORD      = $00     ;the block coordinate where to put sprites with H_NULL
FAKE_SPACE      = 27      ;This is 2 chars wide space as normal space is just 1. Same as char ":"
LEVEL_X         = 20
LEVEL_Y         = 12
LEVELSIZE       = LEVEL_X*LEVEL_Y   ;Level size including borders

;Colors for the mainmenu logo
PTLOGO_D020 = $0b
PTLOGO_D800 = $06+$08
PTLOGO_D022 = $01
PTLOGO_D023 = $03

;-------------------------------------------------
; Defaults for players

PLR_AM     = %11      ;%11 = both players
NUTS_AM    = 4
NUTS_AM_MAX = 9
CREDITS_AM = 3
STARTLEVEL = 0
EXTRALIFEK = 20       ;Every EXTRALIFEK (K=1000) points, you get an extra life

PLR_SPEED_DEF  = 2          ;default player speed
PLR_SPEED_SLOW = 1
PLR_SPEED_FAST = 4          ;must be divisible by 2!
PLR_INIT_START = 0          ;see initplr
PLR_INIT_LEVEL = 1
PLR_INIT_DEATH = 2
PLR_SPR1_COLOR = $a;2
PLR_SPR2_COLOR = $e;6
PLR_SPR1_COLOR_EFF  = 2
PLR_SPR2_COLOR_EFF  = 6

PLR_BOMB_AMOUNT_DEF      = 1
PLR_BOMB_SIZE_DEF        = 1

;-------------------------------------------------
; Game defines

BOMBTIME          = $90 ;the time the bomb brews before exploding
BOMBNULL          = $ff ;special timer value where the bomb does not exist anymore
BOMBEXPLODING     = $00 ;Seems not to be used
BOMBACTIVE        = $01 ;bomb is about to explode

BOMBSIZE_MAX      = 8
BOMB_AM_MAX       = 8
BOMB_OWNER_NONE   = $02
CLOCK_FREEZETIME  = $f0

;-------------------------------------------------
; DEBUG defines

;Override values in DEBUG
!ifdef DEBUG {
  PLR_AM          = %11
  NUTS_AM         = 9
  CREDITS_AM      = 9
  STARTLEVEL      = 95;86;48;98;
  DEF_MON_AMOUNT  = 6;6
;  LASTLEVEL       = 10
  EXTRALIFEK      = 20       ;Every EXTRALIFEK (K=1000) points, you get an extra life
  
  PLR_BOMB_AMOUNT_DEF = BOMB_AM_MAX
  PLR_BOMB_SIZE_DEF   = BOMBSIZE_MAX
}

!ifdef ONLYLASTLEVEL {
  LASTLEVEL       = 1
}

;-------------------------------------------------
; Defaults for penguins

DEF_MON_COLOR = 0
DEF_MON_SPEED = 1
DEF_MON_BIRTHDELAY = $70    ;Penguin is confused for N frames, before starting to move.
DEF_MON_AMOUNT = 6          ;Penguin amount. 6 is the default and maximum.

;-------------------------------------------------
;Game states
;When in game, different states within the game screen may exist.

GAMESTATE_PLAYON    = 0  ;Normal gaming
GAMESTATE_WELLDONE  = 1  ;Show game screen with WELL DONE sprites
GAMESTATE_GAMEOVER  = 2  ;Show game screen with GAME OVER sprites
GAMESTATE_PAUSE     = 3  ;Game paused screen. TBD

;-------------------------------------------------
; Music

MUZ_HOF         = 1
MUZ_MAIN        = 0
MUZ_GAME        = 7
MUZ_BONUS       = 4
MUZ_GAMEOVER    = 5
MUZ_LVLEND      = 2
MUZ_LVLBONUS    = 3
MUZ_PLASMA      = 6

;----------------------------------------------
;Block numbers

BLOCK_EGG_W    = $19        ;White egg
BLOCK_EGG_Y    = BLOCK_EGG_W-1    ;Yellow egg
BLOCK_EGG_B    = BLOCK_EGG_W-2    ;Blue egg

EGG_W_SPD = 1         ;White egg speed
EGG_Y_SPD = 2         ;Yellow egg speed
EGG_B_SPD = 4         ;Blue egg speed

;Block numbers
BLOCK_EMPTY = $00
BLOCK_BOMBACTIVE = $ff  ;This is a block that is not ever drawn to screen. Used for crossfire activation.
BLOCK_BOMB = $14
BLOCK_WBOMB = $1a
BLOCK_LIGHTNING = $15
BLOCK_WHEART = $0b
BLOCK_YHEART = $0c
BLOCK_CLOCK = $13
BLOCK_GLUE = $b5
BLOCK_WPILL = $7e
BLOCK_BPILL = $7f
BLOCK_WQUERY = $02
BLOCK_YQUERY = $a3
BLOCK_LVLJUMP1 = $04
BLOCK_LVLJUMP3 = $05
BLOCK_BONUSLVL = $0d
BLOCK_BALLOON = $81
BLOCK_ICECUBE = $b4
BLOCK_FIRE    = $16
BLOCK_FIRE_ICE = $d9    ;NOTE: The KILL bit shall not be on. This kills players but not penguins.

BLOCK_STATUS_REVERSE_MOVE  = $c4
BLOCK_STATUS_DROP_BOMBS    = $b8
BLOCK_STATUS_DROP_NO_BOMBS = $c5
BLOCK_STATUS_DYING         = $de
BLOCK_STATUS_DOPPEL        = $df
BLOCK_STATUS_SLOWMOVE      = $e0

;----------------------------------------------
; Lastlevel specific

BLOCK_WAND_LEFT            = $ce    ;Special blocks for lastlevel
BLOCK_WAND_RIGHT           = $cf

BLOCK_WAND_LEFT_POS        = 8*20+09
BLOCK_WAND_RIGHT_POS       = 8*20+10 

;----------------------------------------------
; Joystick defines

JOY_NONE = 0
JOY_UP   = 1
JOY_DOWN = 2
JOY_LEFT = 3
JOY_RIGHT= 4
JOY_FIRE = 5

JOY_BIT_UP   = %00001
JOY_BIT_DOWN = %00010
JOY_BIT_LEFT = %00100
JOY_BIT_RIGHT= %01000
JOY_BIT_FIRE = %10000

;----------------------------------------------
; Happening constants

HAPPEN_TIME = $f0 ;How long the effect is active

H_NULL     = $ff ;sprite is non-existent
H_NORMAL   = 00  ;nothing, normal state
H_SPEED    = 01  ;fast
H_SHIELD   = 02  ;shield
H_KAANT    = 03  ;kaanteinen liike
H_DROPBOMB = 04  ;drops bombs all the time
H_ONKO     = 05  ;Unused ... unknown why this is here
H_NOBOMB   = 06  ;no bombs can be dropped
H_HITAUS   = 07  ;slow
H_KILLNORM = 08  ;kill by touch, normal
H_KILLFAST = 09  ;kill by touch, fast
H_FREEZE   = 10  ;penguin sprite does not move. This is a global effect handled with ctr_h_freeze!
H_DOPPEL   = 11  ;player looks like a penguin
H_NOMOVE   = 12  ;sprite does not move
H_DYING    = 13  ;sprite is already dying
H_BIRTH    = 14  ;penguin is being born, animate egg

;-------------------------------------------------
; Block data pointers
;
; A block is a 2x2 char sized element. 
; It's organized in this order.
;   [01] 
;   [23]

bdat0    = $1000        ;Block data
bdat1    = bdat0+$100   ; 01
bdat2    = bdat0+$200   ; 23
bdat3    = bdat0+$300
bcol0    = bdat0+$400   ;Block color data
bcol1    = bdat0+$500   ; 01
bcol2    = bdat0+$600   ; 23
bcol3    = bdat0+$700

;-------------------------------------------------
; Block defines

BIT_THROUGH         = %00010000
BIT_EXPLODE         = %00100000
BIT_THROUGH_EXPLODE = %00110000
BIT_SPECIAL         = %01000000
BIT_KILL            = %10000000

;-------------------------------------------------
; Sprite pointers

;Spritepointers
SPRITEDATA        = (SPRITEGFX/64)
SPRITE_NEXTLEVEL  = $0340
;PlayerPenguinSpr = SPRITEDATA
SPRITE_MAINMENU   = SPRITEDATA+39
SPRITE_ARROW      = SPRITE_MAINMENU-01
SPRITE_EMPTY      = SPRITEDATA+15
SPRITE_HALLOFFAME = SPRITEDATA+68
SPRITE_ENDTRO     = SPRITEDATA+51
SPRITEPTR         = SCR04+$3f8

SPRITE_ENDTRO0    = $0340
SPRITE_ENDTRO1    = $0380
SPRITE_ENDTRO2    = $03c0

SPRITE_CHAR = SPRITEDATA+54
SPR_W = SPRITE_CHAR+0
SPR_E = SPRITE_CHAR+1
SPR_L = SPRITE_CHAR+2
SPR_D = SPRITE_CHAR+3
SPR_O = SPRITE_CHAR+4
SPR_N = SPRITE_CHAR+5
SPR_G = SPRITE_CHAR+6
SPR_A = SPRITE_CHAR+7
SPR_M = SPRITE_CHAR+8
SPR_V = SPRITE_CHAR+9
SPR_R = SPRITE_CHAR+10
SPR_T = SPRITE_CHAR+11
SPR_Y = SPRITE_CHAR+12