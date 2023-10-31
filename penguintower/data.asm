;-------------------------------------------------
;Include files

         ;snowsin
sin1     !byte $3C,$39,$36,$33,$30,$2D,$2A,$27,$24,$21,$1F,$1C,$19,$17,$15,$12
         !byte $10,$0E,$0C,$0A,$09,$07,$06,$04,$03,$02,$01,$01,$00,$00,$00,$00
         !byte $00,$00,$00,$01,$01,$02,$03,$04,$06,$07,$09,$0A,$0C,$0E,$10,$12
         !byte $15,$17,$19,$1C,$1F,$21,$24,$27,$2A,$2D,$30,$33,$36,$39,$3C,$40
         !byte $43,$46,$49,$4C,$4F,$52,$55,$58,$5B,$5E,$60,$63,$66,$68,$6A,$6D
         !byte $6F,$71,$73,$75,$76,$78,$79,$7B,$7C,$7D,$7E,$7E,$7F,$7F,$7F,$7F
         !byte $7F,$7F,$7F,$7E,$7E,$7D,$7C,$7B,$79,$78,$76,$75,$73,$71,$6F,$6D
         !byte $6A,$68,$66,$63,$60,$5E,$5B,$58,$55,$52,$4F,$4C,$49,$46,$43,$40

         ;explosion effect data - must be aligned to page
expl     !byte 0,1,$80,0,0,0,0,0,0,0,0,0,0,0,0,0
         !byte 0,1,2,$80,0,0,0,0,0,0,0,0,0,0,0,0
         !byte 0,1,2,3,$80,0,0,0,0,0,0,0,0,0,0,0
         !byte 0,1,2,3,4,$80,0,0,0,0,0,0,0,0,0,0
         !byte 0,1,2,3,4,5,$80,0,0,0,0,0,0,0,0,0
         !byte 0,1,2,3,4,5,6,$80,0,0,0,0,0,0,0,0
         !byte 0,1,2,3,4,5,6,7,$80,0,0,0,0,0,0,0
         !byte 0,1,2,3,4,5,6,7,8,$80,0,0,0,0,0,0
         !byte 0,1,2,3,4,5,6,7,8,$80,0,0,0,0,0,0


         ;flicking colors for NUTS/SCORE row
flico    !byte $09,$02,$08,$0A,$0F,$03,$0D,$01,$01,$0D,$03,$0F,$0A,$08,$02,$09
         !byte $0B,$0C,$0F,$0D,$01,$0D,$0F,$0C,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
         !byte $0B,$0E,$0F,$03,$07,$0D,$01,$01,$0D,$07,$03,$0F,$0E,$0B,$0B,$0B
         !byte $09,$02,$08,$0A,$0F,$03,$0D,$01,$00,$00,$00,$00,$00,$00,$00,$00

         ;blinking colors in hall of fame

vari1    !byte $01,$0d,$03,$05,$0b,$05,$03,$0d
vari2    !byte $00,$0b,$0c,$0f,$0d,$0f,$0c,$0b
vari3    !byte $09,$02,$04,$08,$0a,$03,$0f,$0d
         !byte $01,$01,$01,$0d,$0f,$03,$0a,$08
         !byte $04,$02
vari4    !byte $0a,$0c,$01,$0f,$0c,$0a,$04,$04

;----------------------------------

level       !byte 1     ;active level number
level_next  !byte 0     ;next level number 
bonus    !byte NO_BONUS ;bonus level to play (0=play normal level)
sat      !byte 0        ;a pseudo random number
fade     !byte 0
;sprcol   !byte $0e,$0a
;strxy    !byte $15,$da  ;Sprite start coordinates

lend     !byte 0,0,0,0,0,0,0,0 ,0,0
rend     !byte 0,0,0,0,0,0,0,0 ,0,0
uend     !byte 0,0,0,0,0,0,0,0 ,0,0
dend     !byte 0,0,0,0,0,0,0,0 ,0,0

!ifdef DEBUG {
  !realign 8,0
}

spr_joy         !byte 0,0,0,0,0,0,0,0   ;the direction
spr_fire        !byte 0,0,0,0,0,0,0,0   ; 1= fire pressed
spr_move        !byte 0,0,0,0,0,0,0,0   ; 1  0=nothing, 1=up...     JOY_UP
                                        ;304                  JOY_LEFT + JOY_RIGHT
                                        ; 2                        JOY_DOWN
spr_movecou     !byte 0,0,0,0,0,0,0,0   ;How long a sprite is moved in spr_move direction. Not used for players!
spr_speed       !byte 0,0,0,0,0,0,0,0   ;speed for sprites
spr_happen      !byte 0,0,0,0,0,0,0,0   ;something happening to sprite
spr_happcou     !byte 0,0,0,0,0,0,0,0   ;happening for a certain time
spr_munapos     !byte 0,0,0,0,0,0,0,0   ;the egg from which the penguin was born. Not used for players!

;Sprite coordinates. This is from the upper left corner of the play area.
spr_xl          !byte 0,0,0,0,0,0,0,0   ;sprite has a coordinate
spr_xh          !byte 0,0,0,0,0,0,0,0   ;[ xl,xh (word),yl (byte) ]
spr_yl          !byte 0,0,0,0,0,0,0,0   ;sprite Y coordinate
spr_scrbls      !byte 0,0,0,0,0,0,0,0   ;source block on map
spr_scrbld      !byte 0,0,0,0,0,0,0,0   ;destination block on map
                                        ;When the sprite is moving, we are
                                        ;touching two blocks; the source and
                                        ;destination blocks.
spr_color       !byte 0,0,0,0,0,0,0,0   ;sprite color
spr_pic         !byte 0,0,0,0,0,0,0,0   ;sprite picture

spr_speed_def   !byte PLR_SPEED_DEF,PLR_SPEED_DEF ;default speed for sprites
                !byte DEF_MON_SPEED, DEF_MON_SPEED, DEF_MON_SPEED, DEF_MON_SPEED, DEF_MON_SPEED, DEF_MON_SPEED

spr_colordef    !byte PLR_SPR1_COLOR, PLR_SPR2_COLOR ;default colors
                !byte DEF_MON_COLOR, DEF_MON_COLOR, DEF_MON_COLOR, DEF_MON_COLOR, DEF_MON_COLOR, DEF_MON_COLOR
                
spr_coloreff    !byte PLR_SPR1_COLOR_EFF, PLR_SPR2_COLOR_EFF ;default colors for when effect if on
                !byte DEF_MON_COLOR, DEF_MON_COLOR, DEF_MON_COLOR, DEF_MON_COLOR, DEF_MON_COLOR, DEF_MON_COLOR                
                
;These are only needed for player sprites.
spr_startxl     !byte $10,$20           ;start coordinates
spr_startxh     !byte $00,$01
spr_startyl     !byte $10,$a0
spr_startbl     !byte 21,219            ;start block number
nuts            !byte 0,0
spr_standctr    !byte 0,0               ;counter for stepping animation
                ;players bomb size, amount and max amount
bombsize        !byte 2,2
bombamou        !byte 2,2,0             ;the third is used for the BOMB_OWNER_NONE
bombmax         !byte 2,2
                ;player scores 
                ;1st player score in 0,2,4 positions, 2nd in 1,3,5 positions
                ;Values are in 'hexcoded' decimals. Example: $12,$34,$56 = 123456
score           !byte 0,0,0,0,0,0       

; 0
;2 3
; 1
;

;3210
;0000 -    0100 LEFT 1000 RIGHT 1100 LEFT
;0001 UP   0101 UP   1001 UP    1101 UP
;0010 DOWN 0110 DOWN 1010 DOWN  1110 DOWN
;0011 UP   0111 DOWN 1011 UP    1111 UP

joy_dir  !byte        00,JOY_UP,JOY_DOWN,JOY_UP
         !byte JOY_LEFT ,JOY_UP,JOY_DOWN,JOY_DOWN
         !byte JOY_RIGHT,JOY_UP,JOY_DOWN,JOY_UP
         !byte JOY_LEFT ,JOY_UP,JOY_DOWN,JOY_UP

joy_dir_opposite  
         !byte        00,JOY_DOWN,JOY_UP,JOY_DOWN
         !byte JOY_RIGHT,JOY_DOWN,JOY_UP,JOY_UP
         !byte JOY_LEFT ,JOY_DOWN,JOY_UP,JOY_DOWN
         !byte JOY_RIGHT,JOY_DOWN,JOY_UP,JOY_DOWN

col_vilk !byte $01,$01,$0d,$0d,$03,$03
         !byte $04,$02,$06,$02,$04,$04
         !byte $03,$03,$0d,$0d

speedand !byte %11111111,%11111111,%11111110,%11111100,%11111100
ander    !byte %00000001,%00000010
         !byte %00000100,%00001000
         !byte %00010000,%00100000
         !byte %01000000,%10000000
andff    !byte %11111110,%11111101
         !byte %11111011,%11110111
         !byte %11101111,%11011111
         !byte %10111111,%01111111

         ;there can be a max of 16 bombs total
bombfix  !byte 0,0,0,0,0,0,0,0          ;0=explod
         !byte 0,0,0,0,0,0,0,0          ;1=fix
bombused !byte 0,0,0,0,0,0,0,0          ;kenen pommi
         !byte 0,0,0,0,0,0,0,0
bombti   !byte 0,0,0,0,0,0,0,0          ;BOMBNULL ($ff) - no bomb in this slot=no
         !byte 0,0,0,0,0,0,0,0          ;BOMBEXPLODING=Exploding (=0)
                                        ;BOMBACTIVE=activ
                                        ;BOMBTIME=time it takes to explode
bombsi   !byte 0,0,0,0,0,0,0,0          ;explosion size
         !byte 0,0,0,0,0,0,0,0
bombco   !byte 0,0,0,0,0,0,0,0          ; -"-   counter
         !byte 0,0,0,0,0,0,0,0
bombxy   !byte 0,0,0,0,0,0,0,0          ;bomb coordinates
         !byte 0,0,0,0,0,0,0,0

;Block explosion animation data
z        = $1b      ;block explosion animation start
;z        = $26     ;different type of animation
block_expl_anim_len = (block_expl_anim_end-block_expl_anim)   ;length of animation
block_expl_anim     !byte z+0,z+0,z+1,z+1,z+2,z+2,z+3,z+3
                    !byte z+4,z+4,z+5,z+5,z+6,z+6,z+7,z+7
                    !byte z+8,z+8,z+9,z+9,z+9,z+9,z+9,z+9
block_expl_anim_end

mnim     = 22
BIRTH_LENGTH = (5*4+2)-1
mnime    !byte $00,$00
         !byte $71,$71,$71,$71
         !byte $70,$70,$70,$70
         !byte $6f,$6f,$6f,$6f
         !byte $6e,$6e,$6e,$6e
         !byte $6d,$6d,$6d,$6d

ker20lo  !byte $00,$14,$28,$3c  ;multipliers *20
         !byte $50,$64,$78,$8c
         !byte $a0,$b4,$c8,$dc
         !byte $f0,$04,$18,$2c
         !byte $40,$54,$68,$7c

credits  !byte 0
eol_ctr  !byte 0                ;End of level counter. Once this hits 0, well done is shown
sprno    !byte 0                ;The sprite routines are checking/moving/etc
floor    !byte 0                ;The floor tile from (1,1) level coordinate
munal    !byte 0                ;counter for eggs
ctr_h_freeze  !byte 0           ;counter for H_FREEZE effect
hof_keypress  !byte 0

temp1    !byte 0
temp2    !byte 0
temp3    !byte 0

tmp1     !byte 0                ;use only inside jsr
tmp2     !byte 0                ;use only inside jsr

gamemusic !byte MUZ_MAIN, MUZ_BONUS, MUZ_GAME, MUZ_GAME

;!align 8,0
;The animations for sprites
w        = SPRITEDATA
STEPIDX  = $10                  ;location where to find the step animation
STEPWAIT = $40                  ;time to wait before starting to step
ationsp  !byte w+11,w+12,w+11,w+13    ;up          ;player
         !byte w+08,w+09,w+08,w+10    ;down
         !byte w+07,w+06,w+05,w+04    ;left
         !byte w+03,w+02,w+01,w+00    ;right
         !byte w+08,w+14
PENG_ANIM_IDX_ADD = $10             ;penguin anim is like player's, but starts N indexes later
DEATHANIMLEN = 13
death    !byte w+37,w+37,w+36,w+35,w+34,w+11    ,w+08    ,w+07    ,w+03    ,w+11    ,w+08    ,w+07    ,w+03
;for penguins it's at (death+DEATHANIMLEN)
         !byte w+37,w+37,w+33,w+32,w+31,w+11+$10,w+08+$10,w+07+$10,w+03+$10,w+11+$10,w+08+$10,w+07+$10,w+03+$10

kilsco   !byte $5f,$60,$60,$61      ;The points a penguin drops when dying
         !byte $61,$61,$62,$62
         !byte $62,$63,$63,$b4
         !byte $b4,$b4,$b4,$b4      ;BLOCK_ICECUBE


plram    !byte PLR_AM
lvltmp   !byte 0
musicvolume !byte 0
scoretmp !byte $00,$00,$00, $00,$00,$00
exlf     !byte 0,0      ;Extralife check
esf      !byte 0        ;Every second frame counter
eff      !byte 0        ;Every fourth frame counter

;---------------------------
;Main screen data

;Arrow Y position
arrplc   !byte $5a,$6a,$7a,$8a,$9a,$aa,$ba,$ca

;sprite numbers
sprnos   !byte SPRITEDATA+8,SPRITEDATA+8              ;penguins
         !byte SPRITE_MAINMENU+02,SPRITE_MAINMENU+03  ;rando       
         !byte SPRITE_MAINMENU+04,SPRITE_MAINMENU+05  ;info
         !byte SPRITE_MAINMENU+06,SPRITE_MAINMENU+07  ;help
         !byte SPRITE_MAINMENU+08,SPRITE_MAINMENU+09  ;score
         !byte SPRITE_MAINMENU+00,SPRITE_MAINMENU+01  ;save
         !byte SPRITE_MAINMENU+10,SPRITE_MAINMENU+11  ;play

scol     !byte PLR_SPR1_COLOR, PLR_SPR2_COLOR
         !byte $0d,$0d
         !byte $0f,$0f
         !byte $07,$07
         !byte $08,$08
         !byte $04,$04
         !byte $01,$01

;---------------------------------------------
;Misc data

sinus2   !byte $00,$00,$01,$03,$05,$08,$0B,$0F,$13,$18,$1D,$23,$28,$2E,$35,$3B
         !byte $41,$47,$4E,$54,$59,$5F,$64,$69,$6E,$72,$76,$79,$7B,$7D,$7F,$7F

         ;textsin
sin      !byte $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
         !byte $E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7,$E7
         !byte $E7,$E7,$E7,$E6,$E5,$E3,$E2,$E0,$DE,$DB,$D8,$D6,$D2,$CF,$CB,$C8
         !byte $C3,$BF,$BB,$B6,$B2,$AD,$A8,$A3,$9D,$98,$92,$8D,$87,$82,$7C,$76
         !byte $71,$6B,$65,$60,$5A,$55,$4F,$4A,$44,$3F,$3A,$35,$31,$2C,$28,$24
         !byte $1F,$1C,$18,$15,$11,$0F,$0C,$09,$07,$05,$04,$02,$01,$00,$00,$00
         !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
         !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;---------------------------------------------
;Section where you can add a secret byte if you provided a special version to someone
SPECIAL_VERSION_NORMAL    = $00
SPECIAL_VERSION_BARBEQUE  = $b7
special_version = SPECIAL_VERSION_BARBEQUE
         
;---------------------------------------------
;The score line under the actual map
;
; The font is embedded in the gfx
;  $EC     : empty
;  $ED     : - (minus)
;  $EE-$F0 : PLR
;  $F1-$F4 : NUTS
;  $F5     : : (doubledot)
;  $F6-$FF : 0-9

EMPTYCHAR = $ec;

alaosa   !byte $EE,$F7,$F5,$F6,$F6,$F6,$F6,$F6,$F6,$F6    ;P1:000000
         !byte $ec
         !byte $F1,$F2,$F3,$F4,$F5,$F6                    ;NUTS:0
         !byte $ec,$ec,$F6,$F6,$ec,$ec
         !byte $EE,$F8,$F5,$F6,$F6,$F6,$F6,$F6,$F6,$F6    ;P1:000000
         !byte $ec
         !byte $F1,$F2,$F3,$F4,$F5,$F6                    ;NUTS:0

;-------------------------------------------
;level orders (total of 100)

         ;level pointers
lvll     = lord
lvlh     = lvll+100
LEVELFIX = (LEVEL_FILE_ADDR-LEVELS)/$100   ;levels are mapped to LEVEL_FILE_ADDR in lvlh. We need to fix the address to LEVELS
;LEVELFIX = ($a900-LEVELS)/$100   ;levels are mapped to LEVEL_FILE_ADDR in lvlh. We need to fix the address to LEVELS

         ;bonus level pointers
bonh     = bonl+16
BONUSFIX = (LEVEL_FILE_ADDR-BONUSLEVELS)/$100   ;levels are mapped to LEVEL_FILE_ADDR in bonh. We need to fix the address to BONUSLEVELS
