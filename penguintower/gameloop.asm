;-------------------------------------------------
;The game irq
;output: A=wot(STATE)

gameirq  ;Timing to proper cycle so we don't get flicker
         ldx #$07       
         dex
         bne *-1
         lda #$00
         sta $d020
         nop
         nop
         nop
         ;Timing ends here
         jsr fixlowerline
         jsr Music_Play
         
         ;GAMESTATE_PLAYON    = keep on playing
         ;GAMESTATE_WELLDONE  = level done
         ;GAMESTATE_GAMEOVER  = game over
         ;GAMESTATE_PAUSE     = pause

gamestate ldx #$00           ;NOTE: The value is used as a counter and modified as SMC (sta gamestate+1)
         cpx #GAMESTATE_PLAYON
         beq _wot1

         ;GAMESTATE_WELLDONE
         jsr setgamescreen
         jsr fixscreen
         jsr fadeaway
         cmp #$00       ;A=0 ready to move on...
         beq *+5
         jmp nexttha
         lda gamestate+1      ;ok, done. Return with (wot) value
         jmp nexttha2

         ;GAMESTATE_PLAYON
_wot1    ldx #$00       ;press P to pause (TBD)
;         lda #%11011111
;         sta $dc00
;         lda $dc01
;         cmp #%11111101
;         bne _wot2
;         +incd020
;         jmp _n2

_wot2    
!ifdef CHEAT {
         lda #%11111101 ;press E to kill players)
         sta $dc00      
         lda $dc01
         cmp #%10111111
         bne _wot7
         ldy #$00
         jsr initplr_death
         ldy #$01
         jsr initplr_death
_wot7
         lda #%11111011 ;press T to enter next level)
         sta $dc00      
         lda $dc01
         cmp #%10111111
         bne _wot5
         jsr lvlend
_wot5
         lda #%11110111 ;press U to jump 10 levels
         sta $dc00      
         lda $dc01
         cmp #%10111111
         bne _wot6
         lda level
         clc
         adc #09
         sta level_next
         jsr lvlend
}
_wot6    ldx #$ff
         stx $dc00
         stx $dc01

         +setd020 7
         ldy #$00
_cm0     lda spr_happen,y
         cmp #H_NULL
         beq _cm04a
         jsr chk_spr
         jsr handle_player
         jsr chk_spr_collision
         jsr chk_spr_fire
         jsr extralifecheck
         jmp _cm04
_cm04a   jsr checkcredits
_cm04    iny
         cpy #$02
         bne _cm0
         +setd020 0

         +setd020 1
         ldy #$02
_cm1     jsr chk_spr
         jsr handle_penguin
         iny
         cpy #$02+DEF_MON_AMOUNT
         bne _cm1
         +setd020 0

         +setd020 3
         jsr setgamescreen
         +setd020 0
         ;put sprites outside of screen
         +setd020 2
         jsr put_spr
         +setd020 0
         +setd020 6
         jsr fixscreen
         +setd020 0

         +setd020 5
         jsr HandleBomb
         +setd020 7
         jsr handlecounters
         +setd020 0

         ldx $d012              ;wait for $d012 to be atleast on line $60
         cpx #$60
         bcc *-5

         jsr Music_Play

         +setd020 5
         jsr ExplodeBlock
         +setd020 0

         +setd020 1
         ldy #$00               ;player one
         jsr PrintPlrStatus
         ldy #$01               ;player two
         jsr PrintPlrStatus
         +setd020 0

         +setd020 6
         jsr animate_block
         +setd020 0

         +setd020 7
         jsr LastLevel_code
         +setd020 0

         ;Game over check (old gaovchk)

         lda $d015
         and #%00000011         ;if no active players, game is over
         
!ifdef GOHOF{
;         ldx #%01               ;Set only one player
;         stx plram
         ;put a score to player
         ldx #$00
         lda #$50
         sta score+0,x
         lda #$09
         sta score+2,x
         lda #$31
         sta score+4,x
         ;played to level 22
         lda #LASTLEVEL-1
         sta level
         ;no active players - game is over
         lda #$00               
}         
         bne _goc
         ldx #GAMESTATE_GAMEOVER 
         stx gamestate+1
         ldy #MUZ_GAMEOVER
         jsr Music_Init
         jmp nexttha

         ;Check if the level is to end
_goc     ldx munal
         lda muna,x
         cmp #$ff               ;if egg index is to last egg, we shall check for level to end
         bne nexttha
         jsr lvlendchk
         
nexttha  lda #GAMESTATE_PLAYON          ;keep on playing
nexttha2 

!ifdef TOBEREMOVED {
         pha
         jsr ToBeRemoved
         pla
}
          rts

;-----------------------------------
;Check if credits used
;The player is dead, check is credits can be used.

checkcredits
         ;check for fire
         lda $dc00,y
         eor #$ff
         lsr
         lsr
         lsr
         lsr
         beq _cc01
         ;init credits
         ldx credits
         beq _cc01
         dec credits
         lda #PLR_INIT_START
         jsr initplr
_cc01    rts

;-----------------------------------
;Check sprite collision
;
;Check if player collides with the penguin
; 
;IN: Y = sprite number (0-1 for player)
;
;NOTE: Original Y is returned

chk_spr_collision
         
         ldx #$02
_csc00   lda spr_happen,x
         cmp #H_NULL          ;If penguin does not exist, ignore
         beq _csc01
         cmp #H_DYING
         beq _csc01
         lda spr_scrbls,y 
         cmp spr_scrbls,x     ;player collision happens when penguin 
         beq _csc10           ;collision
         cmp spr_scrbld,x     ;player collision happens when penguin 
         beq _csc10           ;collision
_csc01   inx
         cpx #$02+DEF_MON_AMOUNT
         bne _csc00

_csc_end rts

         ;There was a collision
_csc10   lda spr_happen,y
         cmp #H_NULL
         beq _csc_end
         cmp #H_DYING
         beq _csc_end
         cmp #H_SHIELD        ;no effect when having shield (yellow heart)
         beq _csc_end
         cmp #H_KILLNORM      ;Kill penguin
         beq _csc_killmon
         cmp #H_KILLFAST      ;Kill penguin
         beq _csc_killmon
         
;         cmp #H_FREEZE        ;When clock is on, you will not die from penguins
;         beq _csc_end
         lda ctr_h_freeze     ;The clock is on if ctr_h_freeze > 0
         bne _csc_end
         
         ;Penguin catches player resultin in death
         
         jsr initplr_death
         jmp _csc_end

_csc_killmon
         ;kill the penguin
         jsr initmon_death
         rts

;-----------------------------------
;Handle player
;IN: Y = sprite number (0-1 for player)
;
;NOTE: Original Y is returned

handle_player
         lda spr_colordef,y   ;By default, use the original colors. It may be changed due to an effect H_xxxx below.
         sta spr_color,y

         ;test what happens in the block we're in.
         tya
         pha
         jsr test_plrcross
         pla
         tay

         ;animate the sprites
         jsr anim_spr
         sta spr_pic,y
         rts

;-----------------------------------
;Handle penguin
;IN: Y = sprite number (2-7 for penguins)
;
;NOTE: Original Y is returned

handle_penguin 
         lda spr_colordef,y   ;By default, use the original colors. It may be changed due to an effect H_xxxx below.
         sta spr_color,y

          sty tmp1
          lda spr_happen,y
          cmp #H_DYING
          beq _hm_end
          cmp #H_NULL         ;if we don't exist, give birth
          bne _hm01
          
          ;penguin is not alive yet, give birth
          ldx munal
          lda muna,x
          cmp #$ff
          beq _hm02
           sta spr_munapos,y
           tax                ;penguin pos to X
           lda #BIRTH_LENGTH
           sta spr_happcou,y
           lda #H_BIRTH
           sta spr_happen,y
           ;active penguin
           jsr initmon
           
           ldy tmp1
           inc munal
           jmp _hm03
          
_hm01     cmp #H_BIRTH
          bne _hm02
          
;          lda eff             ;things happen every fourth frane
;          beq _hm02
          
_hm03     ;animate egg
          ldx spr_munapos,y   ;egg coordinate to X
          lda spr_happcou,y   ;load animate index
          tay                 ;move to Y
          lda mnime,y         ;get egg animation
          beq _hm05           ;if animation is 0, it was the last one and thus needs to be cleared with floor
          tay                 ;block number to Y
          sta gamemap,x
          jsr oneblock_nocolor  ;the egg needs to be keep the color
          jmp _hm02

_hm05     jsr paint           ;paint the floor
          
_hm02     ;more handling here
          ldy tmp1
          ;test what happens in the block we're in.
          tya
          pha
          jsr test_moncross
          pla
          tay

_hm_end   ;exit with original Y
          ldy tmp1
          
          ;animate the sprites
          jsr anim_spr
          sta spr_pic,y          
          rts
          
;-------------------------------------------------
;The routine that handles ALL player and penguin movements and related
;
;IN : Y=sprite to test (0-1=player, 2-7=penguin)
;     A=value of spr_happen,y
;
;NOTE: Original Y is returned

chk_sprno  !byte 0

chk_spr  sty chk_sprno
         cmp #H_NULL
         bne _cm05
_cm05    cmp #H_DYING
         bne _cm06
         rts
_cm06    cmp #H_NOMOVE
         bne _cm07
         rts

_cm07    ;Are we allowed to read the movement?
         ;The sprite must be over a block; aligned correctly

         lda spr_xl,y
         and #%1111
         bne _cm99
         lda spr_yl,y
         and #%1111
         bne _cm99

         cpy #$02           ;branch for penguins
         bcs _cm98

         ;Joystick - read the wanted movement for players
         lda $dc00,y
         eor #$ff
         cmp #JOY_NONE      ;no movement
         beq _cm08
         pha
         lda #$00
         sta spr_standctr,y ;reset standing 
         pla
_cm08    pha
         and #%1111
         tax
         
         lda spr_happen,y
         cmp #H_KAANT
         bne _cm94
         lda joy_dir_opposite,x
         jmp _cm93
         
_cm94    lda joy_dir,x
_cm93    sta spr_joy,y
         pla
         lsr
         lsr
         lsr
         lsr
         sta spr_fire,y
         jmp _cm99
         
_cm98    ;if H_FREEZE is active, no movement for penguins
         lda ctr_h_freeze
         beq _cm96
         jmp _cm10          ;branch does not reach _cm10

         ;'read' the wanted movement for penguins
_cm96    jsr mon_joy

         ;find out in which block we are on map (source)
_cm99    jsr inblock
         ldx spr_scrbls,y         

         lda spr_happen,y
         cmp #H_NOMOVE
         bne _cm95
         jmp _cm10          ;branch does not reach _cm10

_cm95    lda spr_joy,y
         sta spr_move,y

         ;The direction and do the movement
         lda spr_move,y
         bne _cm00
         jmp _cm10

         ;Check for movements
         ; Also check if the destination is block
         ; where we actually can go to.

_cm00    cmp #JOY_UP
         bne _cm01
          lda spr_yl,y
          and #%1111
          bne _cm00a
           lda gamemap-20,x
           tax
           lda bcol0,x
           and #BIT_THROUGH
           beq _cm00b           ;branch can not reach _cm10
_cm00a   lda spr_yl,y           ;load sprite position
          ldx spr_speed,y       
          and speedand,x        ;use speed to make sure it's aligned correctly
          sec                   ;Example: if speed was changed from 1 to 2 and we were at coord 3, to coord needs to be divisible with current speed (eg. 4 or 6)
          sbc spr_speed,y
          sta spr_yl,y
_cm00b   jmp _cm10

_cm01    cmp #JOY_DOWN
         bne _cm02
          lda spr_yl,y
          and #%1111
          bne _cm01a
           lda gamemap+20,x
           tax
           lda bcol0,x
           and #BIT_THROUGH
           beq _cm10
_cm01a   lda spr_yl,y
          ldx spr_speed,y
          and speedand,x
          clc
          adc spr_speed,y
          sta spr_yl,y
         jmp _cm10

_cm02    cmp #JOY_LEFT
         bne _cm03
          lda spr_xl,y
          and #%1111
          bne _cm02a
           lda gamemap-1,x
           tax
           lda bcol0,x
           and #BIT_THROUGH
           beq _cm10
_cm02a   lda spr_xl,y
          ldx spr_speed,y
          and speedand,x
          sec
          sbc spr_speed,y
          sta spr_xl,y
         lda spr_xh,y
          sbc #$00
          sta spr_xh,y
         jmp _cm10

_cm03    cmp #JOY_RIGHT
         bne _cm10
          lda spr_xl,y
          and #%1111
          bne _cm03a
           lda gamemap+1,x
           tax
           lda bcol0,x
           and #BIT_THROUGH
           beq _cm10
_cm03a   lda spr_xl,y
          ldx spr_speed,y
          and speedand,x
          clc
          adc spr_speed,y
          sta spr_xl,y
         lda spr_xh,y
          adc #$00
          sta spr_xh,y
         ;jmp _cm10 

_cm10    
         ;return with original sprite number in Y
         ldy chk_sprno
         rts

;-------------------------------------------------
;The routine that handles player fire button.
;
; Not to be used for penguins.
;
;IN : Y sprite to test (0-1=player)
;
;NOTE: Original Y is returned

chk_spr_fire  
         sty chk_sprno

         ;check for FIRE
         lda spr_happen,y
         cmp #H_DROPBOMB        ;drops bombs all the time
         beq _cm11
         lda spr_happen,y
         cmp #H_NOBOMB          ;can not drop bombs
         beq _cm20
          lda spr_fire,y
          beq _cm20
          ;drop a bomb
_cm11     jsr dropbomb
         ;return with original sprite number in Y
_cm20    ldy chk_sprno
         rts

;----------------------------------------------
;Test what happens in the block we're standing in
;IN : Y sprite number
;
;NOTE: No need to return original Y

test_moncross 
         lda spr_happen,y
         cmp #H_DYING
         beq _tm_end
         cmp #H_NULL         ;if we don't exist, skip
         beq _tm_end

         tya               
         tax                  ;This routine uses x as sprite number!
;         jmp deadm            ;REMOVE: Kill penguin immediately after spawn
;        stx sprno
         
;         lda spr_colordef,x   ;By default, use the original colors. It may be changed due to H_xxxx below.
;         sta spr_color,x
         
         ldy spr_scrbls,x
         lda gamemap,y        ;Get the information on the block
         tay
         lda bcol0,y
         and #BIT_KILL
         bne deadm

         ldy spr_scrbld,x
         lda gamemap,y        ;Get the information on the block
         tay
         lda bcol0,y
         and #BIT_KILL
         bne deadm
         
         ;mom_notdead
_tm_end  rts

deadm    jmp initmon_death

;----------------------------------------------
;Test what happens in the block we're standing in
;IN : Y sprite number
;
;NOTE: No need to return original Y

test_plrcross 
         tya               
         tax                  ;NOTE: This routine uses x as sprite number!
         stx sprno
         
         lda spr_happen,x
         cmp #H_DYING         ;If player already dying, no need to check anything
         beq _tst_end

         ldy spr_scrbld,x
         lda gamemap,y        ;Get the information on the block
         cmp floor            ;ignore floor
         beq _tst_end
         cmp #BLOCK_WBOMB     ;Don't pick dropped bombs    
         beq _tst_end
         
         ;check if the block has some significancy
         tay
         lda bcol0,y
         and #BIT_KILL
         bne cBIT_KILL
         lda bcol0,y
         and #BIT_SPECIAL
         bne cBIT_SPECIAL
         ;nothing to do
_tst_end rts

cBIT_KILL   
         lda spr_happen,x
         ;Check if there is something protecting player         
         cmp #H_SHIELD
         beq plr_notdead
         ;cmp #H_KILLNORM     ;You can die under the pill effect
         ;beq plr_notdead
         ;cmp #H_KILLFAST
         ;beq plr_notdead
         
         cmp #H_DYING         ;If player already dying, don't rekill
         beq plr_notdead
         lda ctr_h_freeze     ;The clock is on if ctr_h_freeze > 0
         bne plr_notdead

         ;continue to die
         ldy sprno
         jsr initplr_death
plr_notdead rts

cBIT_SPECIAL 
         ;Check a block only if you're fully on it.
         lda spr_scrbld,x
         cmp spr_scrbls,x
         bne _tst_end

         sty tmp1               ;store the information for the block we found
         stx pickspr+1          ;store the sprite detail in order to clear right block
         tya
         cmp #BLOCK_FIRE_ICE    ;This is a special block that kills players
         bne _cs3
         lda spr_happen,x
         ;Check if there is something protecting player         
         cmp #H_SHIELD
         beq plr_notdead
         txa
         tay
         jmp initplr_death
         
_cs3     cmp #BLOCK_LVLJUMP1
         bne *+5
         jmp ad1level
         cmp #BLOCK_LVLJUMP3
         bne *+5
         jmp ad3level
         cmp #BLOCK_WHEART
         bne *+5
         jmp adnuts
         cmp #BLOCK_YHEART
         bne *+5
         jmp adsuoj
         cmp #BLOCK_BONUSLVL
         bne *+5
         jmp adbonus
         cmp #BLOCK_CLOCK
         bne *+5
         jmp adkello
         cmp #BLOCK_GLUE
         bne *+5
         jmp adglue
         cmp #BLOCK_BOMB
         bne *+5
         jmp adpommi
         cmp #BLOCK_LIGHTNING
         bne *+5
         jmp adsize
         cmp #BLOCK_WPILL
         bne *+5
         jmp adkino
         cmp #BLOCK_BPILL
         bne *+5
         jmp adkifa
         cmp #BLOCK_BALLOON
         bne *+5
         jmp adspeed
         cmp #BLOCK_WQUERY
         bne _cs2
         lda sat
         and #%00011111         
         jmp supris
_cs2     cmp #BLOCK_YQUERY
         bne done
         ;only bad things for yellow
         lda sat
         and #%1111
         clc
         adc #$10
         jmp supris

         ;Here is the exit

done0    sta spr_happen,x
         lda #HAPPEN_TIME
         sta spr_happcou,x
done     lda #$01               ;Flash when picking up
         sta spr_color,x
         ldy tmp1               ;The block we found
         jsr scorecou
         ;paint floor were we were
pickspr  ldx #$00               ;SMC - the player that picked it. In case a query changed this, we need to clear the right block. 
         lda spr_scrbls,x
         tax
         jsr paint
         rts

supris_ptr  !word adkello, adkello, adkello, adkello, adkello, adsuoj, adsuoj, adsuoj ;0
            !word adsuoj,  adsuoj,  adsuoj,  adkifa,  adkifa,  adkifa, adkino, adkino ;8
            !word adkino,  adkino, adspeed,  adspeed, nomove,  nomove, doppel, doppel ;10
            !word kaante,  kaante,  nobom,   nobom,   albomb,  albomb, adslow, adslow ;18

supris   asl                    ;word table -> multiply with 2
         tay
         lda $d015              ;Effect could go to friend
         and #%00000011
         cmp #%00000011
         bne sup1
         lda sat
         and #%00000011
         cmp #%00000011
         bne sup1
         txa
         eor #$01
         tax
sup1     lda supris_ptr+0,y
         sta sup_smc+1
         lda supris_ptr+1,y
         sta sup_smc+2
sup_smc  jmp $0000              ;SMC!!!!

albomb   lda #H_DROPBOMB
         jmp done0
nobom    lda #H_NOBOMB
         jmp done0
kaante   lda #H_KAANT
         jmp done0
adslow   lda #H_HITAUS
         jmp done0
adspeed  lda #H_SPEED
         jmp done0
adkello  lda #CLOCK_FREEZETIME
         sta ctr_h_freeze
         jmp done
adkino   lda #H_KILLNORM
         jmp done0
adkifa   lda #H_KILLFAST
         jmp done0
adsuoj   lda #H_SHIELD
         jmp done0
adnuts   ldy nuts,x
         cpy #NUTS_AM_MAX
         beq *+5
         inc nuts,x
         jmp done
adpommi  ldy bombmax,x
;         iny
         cpy #BOMB_AM_MAX
         beq *+8
         inc bombamou,x
         inc bombmax,x
         jmp done
adsize   ldy bombsize,x
;         iny
         cpy #BOMBSIZE_MAX
         beq *+5
         inc bombsize,x
         jmp done
nomove   lda #H_NOMOVE
         jmp done0
doppel   lda #H_DOPPEL
         jmp done0

adglue   ldy #$00
_adglue1 lda spr_speed+2,y
         lsr
         bne _adglue0
         lda #$01
_adglue0 sta spr_speed+2,y
         iny 
         cpy #DEF_MON_AMOUNT
         bne _adglue1
         jmp adkello

adbonus  lda sat            ;Select a random bonus level
!ifdef DEBUG {         
bontmp   lda #$00           ;bonus levels come in order
         inc bontmp+1
}         
         and #%00001111
         sta bonus
         jsr lvlend
         jmp done

ad1level jsr lvlend
         jmp done

ad3level jsr lvlend         ;TBD: +3 shall not jump over the last level!
         lda level_next
         cmp #LASTLEVEL-3   ;97
         beq _ad3_1
         cmp #LASTLEVEL-2   ;98
         beq _ad3_0
         inc level_next
_ad3_1   inc level_next
_ad3_0   jmp done

lvlend   jsr lvlend_init
         lda #$01       ;to get the level to end immediately eol=1
         sta eol_ctr
!ifdef ONLYLASTLEVEL {
         jsr LastLevel_end
}         
         rts

;-------------------------------------------------
;Simulate a joystick for penguins.
; IN: Y = sprite (penguin)

mon_joy  lda spr_happen,y
         cmp #H_DYING
         beq _mj_end

         ldx spr_movecou,y
         dex
         txa
         bne _mj00

         jsr do_random

         ;create some random movement to penguins
         lda sat
         and #%00000011
         clc
         adc #$01
;         tax
;         lda joy_dir,x
         sta spr_joy,y
         
         lda sat
         lsr
         lsr
         lsr
         and #%00000111
         clc
         adc #$03
_mj00    sta spr_movecou,y
_mj_end  rts
