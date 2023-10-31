;----------------------------------------------
;handlecounters
; Handles various counters each frame for the gameloop.
;

handlecounters
         lda ctr_h_freeze
         beq _hc00
         dec ctr_h_freeze

_hc00    ldx #$00
_hc01    lda spr_happcou,x
         beq _hc03
         dec spr_happcou,x
_hc02    inx
         cpx #$08
         bne _hc01
         rts

_hc03    jsr resethappenings
         jmp _hc02

;----------------------------------------------
;reset happenings
;IN:  X = sprite number

resethappenings         
         lda spr_happen,x
         cmp #H_DYING         ;handled in plr_death
         beq _rh_end
         cmp #H_NULL
         beq _rh_end

         lda #H_NORMAL
         sta spr_happen,x
         lda spr_colordef,x
         sta spr_color,x
         
         cpx #$02           ;branch for penguins
         bcs _rh_end
         
         lda spr_speed_def,x
         sta spr_speed,x
;         lda spr_xl,x
;         and #%11111110
;         sta spr_xl,x
;         lda spr_yl,x
;         and #%11111110
;         sta spr_yl,x
_rh_end  rts

;----------------------------------------------
;Set proper colors and settings on screen

setgamescreen
         ;set level colors
         ldx levelcol+0
         stx $d021
         ldx levelcol+1
         stx $d022
         ldx levelcol+2
         stx $d023
         ldx #$d8
         stx $d016
         ldx #D018_GAME
         stx $d018
         rts

;----------------------------------------------
;The fixscreen routine for the game.
;This should be called after lower border has been
;passed.

fixscreen 
;         lda irqjump_idx       ;update numbers and text only during gameplay
;         cmp #GAME_IRQ_JSR
;         beq _fs0         

         lda gamestate+1            ;don't update numbers during level done. Fading screen glitches otherwise.
         cmp #GAMESTATE_PLAYON
         bne _fs0

         ldy #3
;         sty temp1
         ldx #$04             ;plr0 - score 024
         jsr putscore
         
         ldy #26
;         sty temp1
         ldx #$05             ;plr0 - score 135
         jsr putscore

         ;put nuts values on screen
         ldx nuts+0
         inx
         lda numero-1,x
         sta SCOREROW+16
         ldx nuts+1
         inx
         lda numero-1,x
         sta SCOREROW+39

         ;put nuts values on screen
         lda plram
         cmp #%11
         bne _fs0
         
         ldx credits
         inx
         lda numero-1,x
         sta SCOREROW+19

_fs0     jsr flikala
         rts

;----------------------------------------------
;Print the status icon for various effects for player
;
;IN:  Y = sprite number, 0 or 1 for player

PrintPlrStatus
         lda ctr_h_freeze
         beq _pps_player

         ;Handle global effect and clean up
         cmp #$01
         beq _pps_clear
         sta _pps_ctr+1
         lda #BLOCK_CLOCK
         jmp _pps_global

_pps_player ;player effect to be shown
         lda spr_happen,y
         cmp #H_NORMAL
         beq _pps_end
;         cpy #H_DYING
;         bcs _pps_end2

         lda spr_happcou,y
         beq _pps_clear

         ;print block
         sta _pps_ctr+1

         ldx spr_happen,y
         lda status_icon,x
_pps_global ;global effect to be shown
         ldx status_loc,y
         tay
         jsr oneblock_nocolor
         
         ;print the colors
         lda blo01,x
         sta $08
         lda bhi01,x
         clc
         adc #$d4
         sta $09
         
_pps_ctr lda #$00     ;SMC!!
         lsr
         lsr
         lsr
         tax
         lda status_col,x
         ldy #$28
         sta ($08),y
         
         ldy #$00
         sta ($08),y
         iny
         sta ($08),y
         
         ldy #$28
         sta ($08),y
         iny
         sta ($08),y
_pps_end rts
;_pps_end2 rts

_pps_clear  ;Paint the original block when effect runs out
         ldx status_loc,y
         lda gamemap,x
         tay
         jmp oneblock

status_loc  !byte 220,239   ;Block location for the status 
status_col  !byte 0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,1
            !byte 3,1,3,1,7,1,1,7,1,1,1,1,1,1,1,1

status_icon  
  !byte 0 ;H_NORMAL   = 00  ;nothing, normal state
  !byte BLOCK_BALLOON             ;H_SPEED    = 01  ;fast
  !byte BLOCK_WHEART              ;H_SHIELD   = 02  ;shield
  !byte BLOCK_STATUS_REVERSE_MOVE ;H_KAANT    = 03  ;kaanteinen liike
  !byte BLOCK_STATUS_DROP_BOMBS   ;H_DROPBOMB = 04  ;drops bombs all the time
  !byte 0                         ;H_ONKO     = 05  ;Unused ... unknown why this is here
  !byte BLOCK_STATUS_DROP_NO_BOMBS;H_NOBOMB   = 06  ;no bombs can be dropped
  !byte BLOCK_STATUS_SLOWMOVE     ;H_HITAUS   = 07  ;slow
  !byte BLOCK_WPILL               ;H_KILLNORM = 08  ;kill by touch, normal
  !byte BLOCK_WPILL               ;H_KILLFAST = 09  ;kill by touch, fast
  !byte BLOCK_CLOCK               ;H_FREEZE   = 10  ;penguin sprite does not move. This is a global effect handled with ctr_h_freeze!
  !byte BLOCK_STATUS_DOPPEL       ;H_DOPPEL   = 11  ;you look like a penguin
  !byte BLOCK_GLUE                ;H_NOMOVE   = 12  ;sprite does not move
  !byte BLOCK_STATUS_DYING        ;H_DYING    = 20  ;sprite is already dying

;----------------------------------------------
;Fix the score line. Should be called at $d012 line $f1

fixlowerline
         ldx #$00
         lda #$08
         stx $d021
         sta $d016      ;set hires for lower part of the screen
         rts

;----------------------------------------------
;Wait N raster lines

waitrasterlines
        +setd020 7
        lda $d012
        clc
        adc #$09      ;N
        cmp $d012
        bne *-3
        +setd020 0
        rts

;----------------------------------------------
;Scoreadder
;IN: X = sprite number
;    Y = the block we found

scorecou ;ldx sprno
         ;ldy temp1
         lda pointam,y
         and #%00001111
         sta sc0+1
         lda pointam,y
         lsr
         lsr
         lsr
         lsr
         sta sc1+1
         ldy #$00
sc0      cpy #$00
         beq sc1-2
         iny
         lda score+0,x
         clc
         adc #$01
         sta score+0,x
         and #%00001111
         cmp #$0a
         bne sc0
         lda score+0,x
         clc
         adc #$06
         sta score+0,x
         and #%11110000
         cmp #$a0
         bne sc0
         lda score+0,x
         clc
         adc #$60
         sta score+0,x
         inc score+2,x
         jmp sc0
         ldy #$00
sc1      cpy #$00
         beq sc2
         iny
         lda score+0,x
         clc
         adc #$10
         sta score+0,x
         and #%11110000
         cmp #$a0
         bne sc1
         lda score+0,x
         clc
         adc #$60
         sta score+0,x
         inc score+2,x
         jmp sc1

sc2      lda score+2,x
         and #%00001111
         cmp #$0a
         bcs *+3
         rts
         lda score+2,x
         clc
         adc #$06
         sta score+2,x
         and #%11110000
         cmp #$a0
         bcs *+3
         rts
         lda score+2,x
         clc
         adc #$60
         sta score+2,x
         inc score+4,x
         lda score+4,x
         and #%00001111
         cmp #$0a
         bcs *+3
         rts
         lda score+4,x
         clc
         adc #$06
         sta score+4,x
         and #%11110000
         cmp #$a0
         bcs *+3
         rts
         lda score+4,x
         clc
         adc #$60
         sta score+4,x
         rts

;----------------------------------------------
;Test if player should receive an extra life
;IN : Y sprite
;
;NOTE: Does not modify Y

extralifecheck
         lda score+2,y
         cmp exlf,y
         bcs elf0
         rts

         ;Give an extra life every 50k points
elf0     lda exlf,y
         clc
         adc #EXTRALIFEK
         sta exlf,y
         lda nuts,y
         cmp #$09
         beq elf_end
         tya
         tax
         inc nuts,x
elf_end  rts

;----------------------------------------------
;End of level check and init

lvlendchk 
         ;no penguin sprites on screen
         lda $d015
         and #%11111100  
         bne _lec

         ;there are penguins on screen but wand is still there
         jsr LastLevel_EndCheck
         bne _lec

         ;Level done routine
         dec eol_ctr
         lda eol_ctr
         lsr
         lsr
         lsr
         lsr
         and #$0f
         sta musicvolume
         lda eol_ctr
         beq _lec2
         rts

_lec2    ldx #GAMESTATE_WELLDONE
         stx gamestate+1

         ;is it to the next level or bonus
         ldy #MUZ_LVLBONUS      ;bonus music
         lda bonus
         cmp #NO_BONUS
         bne _lec1
         ;next level
         ldx level_next
         inx 
         stx level_next
         stx level              ;set the next level as the active one
         ;inc level
         ldy #MUZ_LVLEND        ;normal music
_lec1    jsr Music_Init
_lec     rts

;----------------------------------------------
;End of level init

lvlend_init
         ldy munal
         lda #$ff
         sta muna,y
         sta eol_ctr
         
         ;make the penguins disappear
         ldy #$02
_lei00   lda #H_NULL
         sta spr_happen,y
         lda #NULL_COORD
         sta spr_scrbls,y
         sta spr_scrbld,y
         iny
         cpy #$02+DEF_MON_AMOUNT
         bne _lei00
;         lda #%00000011
;         sta $d015
         rts

;-------------------------------------------------
;fade the level away.
;show WELL DONE and GAME OVER sprites
;etc and prepare to jump to plasma screen

fadeaway ldx gamestate+1       ;select the state and fix sprites accordingly
         cpx #GAMESTATE_WELLDONE
         beq _fa0
         jmp _fa1        ;wot = GAMESTATE_GAMEOVER

_fa0     ldx #SPR_W
         stx SPRITEPTR+0
         ldx #SPR_E
         stx SPRITEPTR+1
         stx SPRITEPTR+7 ;donE
         ldx #SPR_L
         stx SPRITEPTR+2
         stx SPRITEPTR+3 ;welL
         ldx #SPR_D
         stx SPRITEPTR+4
         ldx #SPR_O
         stx SPRITEPTR+5
         ldx #SPR_N
         stx SPRITEPTR+6
         jmp fawhat

_fa1     ldx #SPR_G
         stx SPRITEPTR+0
         ldx #SPR_A
         stx SPRITEPTR+1
         ldx #SPR_M
         stx SPRITEPTR+2
         ldx #SPR_E
         stx SPRITEPTR+3
         stx SPRITEPTR+6 ;ovEr
         ldx #SPR_O
         stx SPRITEPTR+4
         ldx #SPR_V
         stx SPRITEPTR+5
         ldx #SPR_R
         stx SPRITEPTR+7

fawhat   ldx #$00       ;NOTE: The value is used as a counter and modified as SMC (sta fawhat+1)
         cpx #$00       ;show sprites
         bne faw1
         ldx sprFAy+1
         inx
         cpx #$20
         bne _fw1
         inc fawhat+1
         dex
_fw1     stx sprFAy+1
         jmp fa2

faw1     cpx #$01       ;wait
         bne faw2
wdwait   ldx #$00
         inx
         cpx #$90
         bne _ww0
         inc fawhat+1
         ldx #$00
_ww0     stx wdwait+1
         jmp fa2

faw2     cpx #$02       ;remove sprites
         bne faw3
         ldx sprFAy+1
         dex
         cpx #$ff
         bne _fw2
         inc fawhat+1
         inx
_fw2     stx sprFAy+1
         jmp fa2

faw3     lda #$00       ;we're ready with this
         jmp fa2b

         ;show the sprites and go on
fa2      jsr putfadespr

         ldx $d012
         cpx #$60
         bcc *-5
         jsr Music_Play

         lda #$ff       ;we're not ready yet
fa2b     rts

;----------------------------------------------
;--- Well done sprites to screen

putfadespr ldx #$ff
         stx $d015
         
         ldx #$00
         stx $d010
         stx $d01b
         stx $d01c
         stx $d027
         stx $d028
         stx $d029
         stx $d02a
         stx $d02b
         stx $d02c
         stx $d02d
         stx $d02e
         lda #$80
         sta $d000
         clc
         adc #$20
         sta $d002
         clc
         adc #$20
         sta $d004
         clc
         adc #$20
         sta $d006
         sec
         sbc #$80
         clc
         adc #$20
         sta $d008
         clc
         adc #$20
         sta $d00a
         clc
         adc #$20
         sta $d00c
         clc
         adc #$20
         sta $d00e
sprFAy   ldx #$00
         lda sinus2,x
         clc
         adc #$1c
         sta $d009
         sta $d00b
         sta $d00d
         sta $d00f
         eor #$ff
         clc
         adc #$1c
         sta $d001
         sta $d003
         sta $d005
         sta $d007
         lda #$1f
         sec
         sbc sprFAy+1
         tay

         cpx #$00           ;Don't clear screen if X is 0
         beq _pf_end
         lda #EMPTYCHAR
         sta SCOREROW-1,x         
         sta SCOREROW+9,y
;         sta SCOREROW+$d3ff,x
;         sta SCOREROW+$d409,y
_pf_end  rts


;----------------------------------------------
;This routine will count the block we are in.
;
;IN:  Y sprite number
;OUT: A the block
;
;Uses $02 as temp

inblock  
         lda spr_yl,y
         lsr
         lsr
         lsr
         lsr
         tax            ;Y block

         lda spr_xh,y
         sta $02
         lda spr_xl,y
         lsr $02
         ror
         lsr $02
         ror
         lsr $02
         ror
         lsr $02
         ror            ;X block
         clc
         adc ker20lo,x  ;A=X+Y*20
         
         ;store the block to both source and destination
         sta spr_scrbls,y
         sta spr_scrbld,y
         tax 
         
         ;Modify source/destination block only if we're moving.
         ;Initial source/destination is set at birth.
         lda spr_xl,y   
         and #%00001111
         bne _ib_cnt
         lda spr_yl,y
         and #%00001111
         beq _ib_end
_ib_cnt
         txa
         ldx spr_move,y
         cpx #JOY_NONE
         beq _ib_end
         cpx #JOY_UP
         beq _ib_up
         cpx #JOY_DOWN
         beq _ib_down
         cpx #JOY_LEFT
         beq _ib_left
         cpx #JOY_RIGHT
         beq _ib_right
         ;JOY_NONE - We should never reach this
_ib_end  rts
         
_ib_up   ;sec
         ;sbc #20
         clc
         adc #20
         sta spr_scrbls,y
         rts; jmp _ib_end

_ib_down clc
         adc #20
         sta spr_scrbld,y
         rts  ;jmp _ib_end         

_ib_left ;sec
         ;sbc #01
         clc
         adc #01
         sta spr_scrbls,y
         rts  ;jmp _ib_end

_ib_right clc
         adc #01
         sta spr_scrbld,y
         rts  ;jmp _ib_end

;----------------------------------------------
;Scan the eggs found on the map

scanmuna ldy #$00
         ldx #$00
         stx temp1
         lda scanj,x
         asl
         asl
         asl
         asl
         tax
         clc
         adc #$10
         jsr scan
         ldx temp1
         inx
         cpx #$0f
         bne scanmuna+4
         lda #$ff           ;last slot is marked with $ff
         sta muna,y
         rts
         
scan     sta sm3+1
sm5      lda gamemap,x
         cmp #BLOCK_EGG_W
         beq sm2
         cmp #BLOCK_EGG_Y
         beq sm2
         cmp #BLOCK_EGG_B
         beq sm2
sm1      inx
sm3      cpx #$00
         bne sm5
         rts

sm2      txa
         sta muna,y
         iny
         jmp sm1

;The order of lines to scan for eggs
scanj    !byte 4,7,0,6,9,$0d,$0c,$0b
         !byte 1,8,5,2,3,$0e,$0a