;---------------------------------------------------------

GETJOY_DELAY    = $6 ;Delay for the joystick read
GETJOY_LASTCHAR = FAKE_SPACE

;---------------------------------------------------------
;halloffame init

InitHallOfFame 
         jsr resetSpr

;         ldx bonus
;         cpx #NO_BONUS  ;TBD: Why are we comparing bonus and level here?
;         bne *+5
         ldx level_next        ;In the hall of fame, we store levels cleared. 
         ;inx                  ;Levels are 00-99. Level 00 is to be shown as 01 ...etc.
         stx lvltmp
         txa
         cmp #LASTLEVEL
         bne _ihof11
         ldx #$3b             ;Left side of condensed 100
         ldy #$3c             ;Right side
         jmp _ihof10
         
_ihof11  jsr HexToBcd
_ihof10  stx scolvl+0         ;Store level to the scoreline
         sty scolvl+1

         ;clear name
         lda #FAKE_SPACE      ;put fake space that is 2 chars wide
         sta sconame+0
         sta sconame+1
         sta sconame+2
         sta sconame+3
         sta sconame+4
         ;clear score from line
         sta scotemp+0
         sta scotemp+1
         sta scotemp+2
         sta scotemp+3
         sta scotemp+4
         sta scotemp+5
         sta scotemp+6

         ;Set initial colors on screen
         jsr BlinkText
         
         ldx #$00
         stx hofline

         ldx plram
         cpx #%00000011
         beq ihof8
         
         ;Copy score->scoretmp when game is over
         ldy #$05             
         lda plram
         cmp #%01             ;Copy the right score from the active player 
         bne *+4
         ldy #$04
         ldx #$00
ihof6    lda score,y
         sta scoretmp,x
         dey
         dey
         inx
         cpx #$03
         bne ihof6

!ifdef DEBUG {
;         lda #$00
;         sta scoretmp+0
;         lda #$08
;         sta scoretmp+1
;         lda #$01
;         sta scoretmp+2
}
         
         ;----------------------------------------------------
         ;NOTE: ($fd) is used as the pointer to scoreline list
         ;----------------------------------------------------
         
         ;Set single player things right
         lda #<score_ptr
         sta $fd
         lda #>score_ptr
         sta $fe
         jsr ScoreConvert
         jsr SearchScoreLocation_Score
         
         lda #"0"               ;Add the missing zero
         sta scotemp+6
         jmp ih0f9

         ;Set team play things right
ihof8    lda #<score_ptr_team
         sta $fd
         lda #>score_ptr_team
         sta $fe
         jsr SearchScoreLocation_Level

ih0f9    ;put your rank
         lda hofline
         sta ihof3+1
         ;if score not high enough for hall of fame, go to main
         ;eg. Your hofline is 0
         bne ihof_add_to_hof
         
         ;exit
         lda #MAIN_INIT_JSR
         sta irqjump_idx
         rts
         
ihof_add_to_hof         
         ;You are to go to high score
         
         ;Add the level number to the line
         jsr HexToBcd
         stx scoline+0
         sty scoline+1

         ldx #$00
         stx $d021
         stx $d020
         ldx #D018_FONT
         stx $d018

         lda #$06
         jsr clrscreen

;         ldx #$00
;ihof1    lda #$5a
;         sta SCR04+$00,x
;         sta SCR04+$f0,x
;         sta SCR04+$01e0,x
;         sta SCR04+$02d0,x
;         sta SCR04+$02f8,x
;         txa
;         clc
;         adc #$27
;         tax
;         lda #$5b
;         sta SCR04+$00,x
;         sta SCR04+$f0,x
;         sta SCR04+$01e0,x
;         sta SCR04+$02d0,x
;         sta SCR04+$02f8,x
;         inx
;         cpx #$f0
;         bne ihof1

         ;print texts to screen
         lda #<hoftext
         sta $fb
         lda #>hoftext
         sta $fc
         ldx #$06
         ldy #$02
         jsr printtext

         ldx #$04
         ldy #$04
         jsr printtext

         ldx #$06
         ldy #$07
         jsr printtext

         ;print some other scores also.
         ;   better
         ;00 your score
         ;   worse score
         ;   worse score
         ;   ...
         ldx hofline
         cpx #$01
         beq ihof5
         dex
         dex
         txa
         asl
         tay
         lda ($fd),y
         sta $fb
         iny
         lda ($fd),y
         sta $fc
         ldx #08
         ldy #10
         jsr printtext

ihof5    ldy #14
         sty ihof4+1
ihof3    ldx #$00             ;<-copied from hofline - smc!
         cpx #SCORE_COUNT
         beq ihof2
         txa
         asl
         tay
         lda ($fd),y
         sta $fb
         iny
         lda ($fd),y
         sta $fc
         ldx #$08
ihof4    ldy #00
         jsr printtext
         inc ihof4+1
         inc ihof4+1
         inc ihof3+1
         ldy ihof4+1
         cpy #24
         bne ihof3

ihof2    ldx #$04
         stx $d021
         ldx #$04
         stx $d020
         ldx #$08
         stx $d016
         ldx #$ff
         stx $dc00
         stx $dc01
         ldx #$00       ;reset name pointer
         stx ptr+1

         ldy #MUZ_HOF
         jsr Music_Init
         rts ;inithalloffame done

;---------------------------------------------------------
;halloffame irq

halloffameirq 
         ldx #$1b
         stx $d011

         jsr Music_Play
         jsr GetKeys
         jsr GetJoy

xax      = $68
yax      = $50

         ldx #$ff
         stx $d015
         stx $d01b
po3      ldx #$00
         stx po1+1
po4      ldx #$20
         stx po2+1
         ldx #$00
po1      ldy #$00
         lda sin1,y
         clc
         adc #xax
         sta $d000,x
po2      ldy #$00
         lda sin1,y
         clc
         adc #yax
         sta $d001,x
         lda po1+1
         clc
         adc #$10
         bpl *+5
         clc
         adc #$80
         sta po1+1
         lda po2+1
         clc
         adc #$10
         bpl *+5
         clc
         adc #$80
         sta po2+1
         inx
         inx
         cpx #$10       ;8 sprites
         bne po1
         
         ;modify snow flake sin pointers
         lda po3+1
         clc
         adc #$01
         and #%01111111
         sta po3+1
         lda po4+1
         clc
         adc #$01
         and #%01111111
         sta po4+1
         
         ldx #$00
po6      lda #SPRITE_HALLOFFAME
         sta SPRITEPTR+0,x
         lda #$01
         sta $d027,x
         inx
         cpx #$08
         bne po6

         +decd020
         jsr BlinkText
         +incd020

         ldx #$60
         cpx $d012
         bne *-3
         jsr Music_Play
         
         ;put cursor on the scoreline and flick it
         lda fw+1
         clc
         adc #$01
         and #%111
         sta fw+1
         
fw       ldy #$00           ;SMC!!!
         bne po9

         ;print the cursor
         ldx ptr+1
         cpx #$04
         bpl po9
         txa
         asl
         clc
         adc #28
         tax
         lda #<scocursor
         sta $fb
         lda #>scocursor
         sta $fc
         ldy #12
         jsr printtext
         jmp po8

po9      ;print the scoreline
         lda #<scoline
         sta $fb
         lda #>scoline
         sta $fc
         ldx #02
         ldy #12
         jsr printtext

;         ldx #$7f
;         stx $dc00
;         ldx $dc01
;         cpx #$df
;         bne po8
;         ;DONE, return to main
;         lda #MAIN_INIT_JSR
;         sta irqjump_idx

po8      rts ;halloffame irq done

scocursor !scr "-@"
          !byte 0

;-------------------------------------------------
;Get name that is tapped on the keyboard

GetKeys  lda hof_keypress
         bne *+3
         rts

         ;is it a special character
         cmp #$0d  ;return
         bne gk2

gk_ret   ;return pressed, copy to hall of fame
         ldx #$00
gk3      lda scotemp,x
hofptr   sta $ff00,x
         inx
         cpx #15
         bne gk3
         lda #MAIN_INIT_JSR
         sta irqjump_idx
         rts

gk2      cmp #$14  ;back space
         bne _gk7
gk2_bs   ldx ptr+1
         dex
         cpx #$ff
         bne *+4
         ldx #$00
         stx ptr+1
         lda #FAKE_SPACE
         jsr ScoName_AddChar
         inx
         jsr ScoName_AddChar
         rts

         ;test char to be A-Z or SPACE
_gk7     cmp #$20  ;SPACE
         bne _gk7a
         lda #FAKE_SPACE  
         jmp ptr
_gk7a    cmp #$40  ;A->
         bcs *+3
         rts
         cmp #$5a  ;->Z
         bcc *+3
         rts

         ;convert ASCII to PETASCII
         sec
         sbc #$40
ptr      ldx #$00         ;SMC!!! - character pointer
         cpx #$04
         beq gk1
         jsr ScoName_AddChar
         inc ptr+1
gk1      rts

;-------------------------------------------------
;Add a char to halloffame name
;
; IN: A=char to add
;     X=name location (0-3)

ScoName_AddChar
         sta sconame,x
         rts

;-------------------------------------------------
;Enter name with joystick

GetJoy   
         
_gj_delay ldx #GETJOY_DELAY
         beq _gj_check
         dec _gj_delay+1
         rts

_gj_check ;Check joystick 
         ldx #GETJOY_DELAY
         stx _gj_delay+1

         ;Either stick can be used
         lda $dc00
         eor $dc01
         sta hof_joy

         lda hof_joy
         and #JOY_BIT_LEFT      ;joy left - works as backspace
         bne gk2_bs
         
         lda hof_joy
         and #JOY_BIT_UP        ;joy up
         bne _gj_up

         lda hof_joy
         and #JOY_BIT_DOWN      ;joy down
         bne _gj_down

         lda hof_joy         
         and #JOY_BIT_FIRE      ;fire pressed
         bne _gj_fire           

         rts
         
         ;joy up
_gj_up   ldx ptr+1
         lda sconame,x
         clc
         adc #$01
         cmp #GETJOY_LASTCHAR+1
         bne _gj_up0
         lda #$01
_gj_up0  jmp ScoName_AddChar

         ;joy down
_gj_down ldx ptr+1
         lda sconame,x
         sec
         sbc #$01
         bne _gj_do0
         lda #GETJOY_LASTCHAR
_gj_do0  jmp ScoName_AddChar
         
         ;joy fire
_gj_fire ldx ptr+1
         inx
         cpx #$04
         bmi _gj_a0
         jmp gk_ret             ;Final char, do a RETURN key
_gj_a0   stx ptr+1
         rts

hof_joy  !byte 0

;-----------------------------------------------------
;Convert score to text and save to 'scotemp'
;
; eg. 01,23,45 -> '012345'

ScoreConvert
         ldx #$00
         ldy #$00
wi1      lda scoretmp,x
         lsr
         lsr
         lsr
         lsr
         clc
         adc #$30
         sta scotemp+0,y
         lda scoretmp,x
         and #%00001111
         clc
         adc #$30
         sta scotemp+1,y
         inx
         iny
         iny
         cpx #3
         bne wi1
         rts

;-----------------------------------------------------
;Go through hall of fame and find the score position in the leader board

SearchScoreLocation_Score
         ;search through the hall of fame
         ldx #$00
wi4      txa
         asl
         tay
         lda ($fd),y  ;lda score_ptr+0,y
         sta $fb
         iny
         lda ($fd),y  ;lda score_ptr+1,y
         sta $fc
         ldy #$00
wi2      lda scotemp,y
         cmp ($fb),y
         beq wi3
         bcc wi5
         jmp MoveScoresDown
wi3      iny
         cpy #$06
         bne wi2
         jmp MoveScoresDown
wi5      inx
         cpx #SCORE_COUNT
         bne wi4
         rts ; nope not a score big enough

         ;For team play, only level is of interest
SearchScoreLocation_Level
         ;search through the hall of fame
         ldx #$00
xi4      txa
         asl
         tay
         lda ($fd),y  ;lda score_ptr_team+0,y      
         iny
         clc
         adc #$08                 ;+8 because scoreline looks like: "0008000 00 darc@"
         sta $fb
         lda ($fd),y              ;score_ptr_team+1,y
         adc #$00                 ;in the case the +8 above changes page
         sta $fc
         ldy #$00
xi2      lda scolvl,y
         cmp ($fb),y
         beq xi3
         bcc xi5
         jmp MoveScoresDown
xi3      iny
         cpy #$02
         bne xi2
         jmp MoveScoresDown
xi5      inx
         cpx #SCORE_COUNT
         bne xi4
         rts ; nope not a level big enough

;-------------------------------------------------
;MoveScoresDown
;
; Moves scores down from a certain line and makes an empty spot for current score
;
; IN: X=score line;

MoveScoresDown
         ;found it, now copy the rest of the lines downwards.
         ;x = the line!
         stx hofline
         inc hofline
         
         lda hofline        ;If it's the lowest score on table, no movement needed
         cmp #SCORE_COUNT
         beq t12

         ;the correct scoreline is copied here
         txa
         asl
         tay
         lda ($fd),y
         sta hofptr+1
         iny
         lda ($fd),y
         sta hofptr+2
         
         ;Copy lines downwards. This has to be done line per line
         dex
         stx tl1+1

         ldx #SCORE_COUNT-2
         ;line 11 is copied to 12 (last)
         ;     10 to 11.... First line is 0.
tl3      txa
         asl
         tay
         lda ($fd),y
         sta hw1+1
         iny
         lda ($fd),y
         sta hw1+2
         iny
         lda ($fd),y
         sta hw2+1
         iny
         lda ($fd),y
         sta hw2+2

         ldy #$00
hw1      lda $ff00,y
hw2      sta $ff00,y
         iny
         cpy #$10
         bne hw1
         dex
tl1      cpx #$00
         bne tl3
t12      rts

;---------------------------------
;Blink the texts

BlinkText ldx #$00   ;SMC!!
         ldy #$00

vt1      lda vari4,x
         sta SCRD8+(40*4)+2,y
         sta SCRD8+(40*5)+2,y
         lda vari2,x
         sta SCRD8+(40*07)+2,y
         sta SCRD8+(40*08)+2,y
         lda vari1,x
         sta SCRD8+(40*12)+2,y
         sta SCRD8+(40*13)+2,y
         iny
         cpy #$22
         bne vt1

vt11     ldy #$01     ;SMC!!
         dey
         bne vt12
         ldy #$04
         inx
         cpx #$08
         bne *+4
         ldx #$00
         stx BlinkText+1
vt12     sty vt11+1

         ;color scroller
         ldx #$00
         ldy #$02
vt2      lda colbuf+1,x
         sta colbuf+0,x
         sta SCRD8+(40*02),y
         sta SCRD8+(40*02)+1,y
         sta SCRD8+(40*03),y
         sta SCRD8+(40*03)+1,y
         iny
         iny
         inx
         cpx #18
         bne vt2

vt21     ldx #$00
         lda vari3,x
         sta colbuf+18
         inx
         cpx #18
         bne *+4
         ldx #$00
         stx vt21+1
         rts

colbuf   = buf+$c0

;---------------------------------------------------
;Load highscores

highscore_load
         lda $01
         pha
         lda #$37
         sta $01
         
         lda #SAVENAME_END-SAVENAME     ;filename length
         ldx #<SAVENAME
         ldy #>SAVENAME
         jsr LOAD_init_byte

         lda #<scoretxt                 ;Where to load
         sta $02
         lda #>scoretxt         
         sta $03

         lda #<(scoretxt_end-scoretxt)  ;How many bytes to read
         sta $04
         lda #>(scoretxt_end-scoretxt)
         sta $05
         jsr LOAD_file_byte

         pla
         sta $01
         rts

;---------------------------------------------------
;Save highscores

highscore_save
         jsr noirq_f

         ldx #10      ;Read values from stack as we came to this routine 'ugly'
_ss00    pla
         dex
         bne _ss00

         sei
         lda $01
         pha
         lda #$37
         sta $01
         
         lda #SAVENAME_END-SAVENAME   ;filename length
         ldx #<SAVENAME
         ldy #>SAVENAME
         jsr SAVE_init_byte

         lda #<scoretxt               ;From where to save
         sta $02
         lda #>scoretxt         
         sta $03

         lda #<scoretxt_end           ;To where to save
         sta $04
         lda #>scoretxt_end
         sta $05
         jsr SAVE_file_byte

         pla
         sta $01
         cli
         
         jmp RealStart                ;restart main screen

SAVENAME !pet "@0:highscores,p,w"
SAVENAME_END
