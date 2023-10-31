;----------------------------------------------
;Last level code
;
; Last level has some special things to it and this is the code part that handles it.

LastLevel_code
          inc lastlevel_ctr
          
          lda level
          cmp #LASTLEVEL-1
          beq _llc0
          rts
_llc0     
          ;Blink the part that needs to be broken
          lda #$01                ;white color
          ldx lastlevel_ctr
          cpx #$10
          bcs _llc1
          lda lastlevel_blink,x
          
          ;Color wand middle part
          ldy gamemap+BLOCK_WAND_LEFT_POS
          cpy #BLOCK_WAND_LEFT
          bne _llc2
          sta $d800+8*2*40+19
          sta $d800+8*2*40+19+40
          
_llc2     ldy gamemap+BLOCK_WAND_RIGHT_POS
          cpy #BLOCK_WAND_RIGHT
          bne _llc1
          sta $d800+8*2*40+20
          sta $d800+8*2*40+20+40
          
_llc1     ;Check if we are in end of level state
          lda eol_ctr
          beq _llc4
          
          ;Do the end of level fade 
          jsr LastLevel_Wandfade
          jmp _llc3
          
_llc4     ;Last level has not ended yet.
          jsr LastLevel_WandBlink
          
          lda lastlevel_ctr
          bne _llc3
          jsr AddRandomThing
          
_llc3          
          rts

;----------------------------------------------
;Check if lastlevel is to end
;
; The wand needs to be broken and then the level ends.
;
; Returns 0 if level is finished

LastLevel_EndCheck
          lda level
          cmp #LASTLEVEL-1
          bne _llec_end

          lda gamemap+BLOCK_WAND_LEFT_POS
          cmp floor
          beq _llec_c1
          cmp #BLOCK_FIRE_ICE
          bne _llec_c2
          
_llec_c1  lda gamemap+BLOCK_WAND_RIGHT_POS
          cmp floor
          beq _llec_end
          cmp #BLOCK_FIRE_ICE
          beq _llec_end

          ;Wand is not broken, do not end the level yet
_llec_c2  lda #$ff
          rts

          ;Wand is broken, end the level
_llec_end lda #$00
          rts

;----------------------------------------------
;For debug purposes, last level needs to break the wand.
;

!ifdef ONLYLASTLEVEL {
LastLevel_end
         ;This to end the last level properly
         lda floor
         sta gamemap+BLOCK_WAND_LEFT_POS
         sta gamemap+BLOCK_WAND_RIGHT_POS
         lda #$ff
         sta eol_ctr
}

;----------------------------------------------
;Cold wand colorings

;The fade color animation
LastLevel_Wandfade
          lda eol_ctr
          lsr
          lsr
          lsr
          clc
          adc #$28
          tax
          jsr LastLevel_paintwand
          ;Fade the middle of wand away.
          lda eol_ctr
          lsr
          and #%01
          sta SCRD8+40*09+19
          sta SCRD8+40*09+20
          sta SCRD8+40*10+19
          sta SCRD8+40*10+20
          rts

;The normal blink color animation
LastLevel_WandBlink
          ldx lastlevel_ctr
          cpx #$20
          bcs _pw0

;Colorize the wand. Enter with X ($00-$1f) as the offset for color
LastLevel_paintwand
          lda lastlevel_wand_blink+00,x
          sta SCRD8+40*06+19     ;   **
          sta SCRD8+40*06+20
          
          lda lastlevel_wand_blink+01,x
          sta SCRD8+40*07+18     ;  ****
          sta SCRD8+40*07+19
          sta SCRD8+40*07+20
          sta SCRD8+40*07+21

          lda lastlevel_wand_blink+02,x
          sta SCRD8+40*08+17     ; **  ** 
          sta SCRD8+40*08+18
          sta SCRD8+40*08+21
          sta SCRD8+40*08+22
          
          lda lastlevel_wand_blink+03,x
          sta SCRD8+40*09+16     ;**    ** 
          sta SCRD8+40*09+17
          sta SCRD8+40*09+22
          sta SCRD8+40*09+23
          
          lda lastlevel_wand_blink+04,x
          sta SCRD8+40*10+16     ;**    ** 
          sta SCRD8+40*10+17
          sta SCRD8+40*10+22
          sta SCRD8+40*10+23

          lda lastlevel_wand_blink+05,x
          sta SCRD8+40*11+17     ; **  ** 
          sta SCRD8+40*11+18
          sta SCRD8+40*11+21
          sta SCRD8+40*11+22

          lda lastlevel_wand_blink+06,x
          sta SCRD8+40*12+18     ;  ****
          sta SCRD8+40*12+19
          sta SCRD8+40*12+20
          sta SCRD8+40*12+21

          lda lastlevel_wand_blink+07,x
          sta SCRD8+40*13+19     ;   **
          sta SCRD8+40*13+20
          
_pw0      rts

;----------------------------------------------
;Adds a random things on map
;
; Mainly icy fire, but randomly also bombs and lightning
;

AddRandomThing
          lda sat
_art1     cmp #LEVELSIZE-(2*LEVEL_X)
          bcc _art0
          clc
          adc #LEVELSIZE
          jmp _art1 
          rts
_art0     clc
          adc #LEVEL_X
          tax
          lda gamemap,x
          cmp floor
          bne _art2
          lda sat
          and #%1111
          tay
          lda random_thing,y
;          lda #BLOCK_FIRE_ICE
          sta gamemap,x
          tay
          jsr oneblock
_art2     
          rts

;----------------------------------------------    
;Last level data

random_thing  !byte BLOCK_BOMB, BLOCK_LIGHTNING, BLOCK_LIGHTNING, BLOCK_LIGHTNING, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE
              !byte BLOCK_FIRE_ICE, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE, BLOCK_FIRE_ICE

lastlevel_ctr !byte 00    ;Counter increaseed by one per frame

         ;blinking colors in last level

lastlevel_blink
         !byte 7,3,5,4,2,2,6,6
         !byte 2,2,4,5,3,7,1,1

lastlevel_wand_blink
         !byte 7,1,7,7,3,7,3,3
         !byte 5,3,5,5,4,5,4,4
         !byte 2,4,2,2,6,2,6,6
         !byte 2,4,2,4,5,3,7,1

         !byte 1,1,1,1,1,1,1,1

         ;The fade colors at offset $28
         !byte 0,0,0,0,0,0,0,0
         !byte 1,0,0,1,0,0,1,0
         !byte 1,0,1,0,1,0,1,0
         !byte 0,1,1,0,1,1,0,1
         
         !byte 0,1,1,1,1,1,1,1
