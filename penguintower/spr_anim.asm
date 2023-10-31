;-------------------------------------------------
;Put all game sprites on screen
;
;IN: Nothing

put_spr  lda #$ff           ;By default the everything is on top of gfx
         sta $d01b
         
         ldx #$00
         stx $d010
         stx $d015
         
         ldy #$00
_cm30    lda spr_happen,y
         cmp #H_NULL
         beq _cm32
         cmp #H_BIRTH
         beq _cm33
         
         ;Penguins are behind graphics when born
         lda $d01b
         eor ander,y
         sta $d01b
         
_cm33    ;Enable sprites
         lda $d015
         eor ander,y
         sta $d015
         
         lda spr_xl,y
         clc
         adc #$17
         sta $d000,x
         lda spr_xh,y
         adc #$00
         beq _cm31
         lda $d010
         ora ander,y
         sta $d010
_cm31    lda spr_yl,y
         clc
         adc #$32
         sta $d001,x
         lda spr_color,y
         sta $d027,y
         lda spr_pic,y
         sta SPRITEPTR,y
_cm32    iny
         inx
         inx
         cpy #$02+DEF_MON_AMOUNT
         bne _cm30

         ldx #$01
         stx $d025
         ldx #$0b
         stx $d026

         ldx #%00000000
         stx $d017
         stx $d01d
;         stx $d01b
         ldx #$ff
         stx $d01c
         rts


;----------------------------------------------
;Animate sprite death
;
;IN : Y sprite to animate (0-1=player, 2-7=penguin)
;OUT: A sprite number 
;
;NOTE: Original Y is returned

_as_death 
         ldx spr_happcou,y
         beq spr_death
         txa
         lsr                    ;The deathanim count in short, but the time has been *8
         lsr
         lsr
         cpy #$02               ;branch for player
         bcc _ad00
         clc
         adc #DEATHANIMLEN
         
_ad00    tax         
         lda death,x
         rts

spr_death 
         lda #H_NULL
         sta spr_happen,y
         lda #$00
         sta spr_happcou,y
         lda $d015
         and andff,y
         sta $d015
         lda $d010
         and andff,y
         sta $d010
         
         cpy #$02           ;branch for penguins
         bcs _sd00
         
         ;PLR death - Spend nuts and initialize
         lda #NULL_COORD
         sta spr_scrbls,y
         sta spr_scrbld,y

         tya
         tax
         dec nuts,x
         bmi _sd02            ;Full death
         ;Initialize player death
         lda #PLR_INIT_DEATH     
         jsr initplr
_sd02    lda #SPRITE_EMPTY
         rts
         
_sd00    ;MON death - Drop some points
         tya        ;store original Y
         pha
         ldx spr_scrbls,y
         
         lda gamemap,x
         cmp #BLOCK_WBOMB ;Don't drop points in case there is a bomb on the floor
         beq _sd03
         
         lda sat
         and #%00001111
         tay
         lda kilsco,y
         sta gamemap,x
         tay
         jsr oneblock

         ;no need to return sprite gfx in A as it's invisible ($d015)
_sd03    pla
         tay        ;return with original Y
         
         lda #NULL_COORD
         sta spr_scrbls,y
         sta spr_scrbld,y
         rts

;----------------------------------------------
;Animate sprites
;
;IN : Y sprite to animate (0-1=player, 2-7=penguin)
;OUT: A sprite number 
;
;NOTE: Original Y is returned

anim_spr 
         lda spr_happen,y
         cmp #H_DYING
         beq _as_death

         cpy #$02               ;branch for penguins as there are no effects for monsters
         bcs _as_joy

         cmp #H_NORMAL
         beq _as09
         
         ;When any effect is on, show a different color. 
         ;Might be changed later by differemt effect
         pha
         lda spr_coloreff,y
         sta spr_color,y
         pla ;reload spr_happen,y

         ;If shield is active, flicker the color
_as09    cmp #H_SHIELD
         bne _as05
          ;H_SHIELD
          lda spr_happcou,y
          and #%00001111
          tax
          lda col_vilk,x
          sta spr_color,y
          jmp _as_joy
         
_as05    cmp #H_KILLNORM
         beq _as04b
         cmp #H_KILLFAST
         beq _as04
         cmp #H_HITAUS
         bne _as07          
          lda #PLR_SPEED_SLOW
          jmp _as06
_as07    cmp #H_SPEED
         bne _as08
          lda #PLR_SPEED_FAST
_as06     sta spr_speed,y
          jmp _as_joy
          
           ;more checks can be added here
_as08      jmp _as_joy 
           
_as04     ;H_KILLFAST
          lda #PLR_SPEED_FAST
          sta spr_speed,y
          ;H_KILLNORM
_as04b    ;If killmode is active, blink the color
          lda spr_happcou,y
          and #%00000001
          sta spr_color,y

         ;animate movements
_as_joy  lda #JOY_DOWN*4-4      ;By default we are looking down.
         sta _as_smc+1
         lda spr_move,y
         ;if 0, the we're just standing
         beq _as_standing
         ;1=UP and we need to fix that to 0=UP, ...
         sec
         sbc #$01
         ;fix the pointer
         asl
         asl
         sta _as_smc+1
         ;cmp #JOY_UP*4
         beq _as02
         cmp #JOY_LEFT*4-4
         beq _as01
         cmp #JOY_RIGHT*4-4
         beq _as01
         ;cmp #JOY_DOWN*4
         ;beq _as02

_as02    lda spr_yl,y           ;up or down
         jmp _as03

_as01    lda spr_xl,y           ;left or right

_as03    and #%00001111         ;Take two lower bits of position for the animation frames
         lsr
         lsr
_as00    clc
_as_smc  adc #$00               ;SMC!
         tax

         lda ationsp,x
         cpy #$02               ;branch for penguins
         bcs _as_penguin        
         
         ;player stuff
         ldx spr_happen,y       ;check for effect
         cpx #H_DOPPEL
         bne _as_exit_plr
         clc
         adc #PENG_ANIM_IDX_ADD  ;player looks like a penguin
         pha
         lda #DEF_MON_COLOR     ;and is penguin colored
         sta spr_color,y
         pla
_as_exit_plr         
         rts                    ;player exit

_as_penguin
         ;select penguin animation
         clc
         adc #PENG_ANIM_IDX_ADD
         rts                    ;penguin exit

         ;player standing animation
_as_standing
         cpy #$02               ;branch for penguins
         bcs _as00              ;penguins don't step
         lda spr_standctr,y
         clc
         adc #$01
         sta spr_standctr,y
         cmp #STEPWAIT
         bcs _as_s0             ;less than STEPWAIT
         lda #$00
         jmp _as00
_as_s0   lsr
         lsr
         lsr            
         lsr
         lda #(STEPIDX-4)
         adc #$00               ;carry is used to add 0 or 1
         jmp _as00
