;----------------------------------------------
;Bomb related functions

;----------------------------------------------
;Drop a bomb (by player) to screen
;IN : Y sprite (player)
;OUT: Y sprite

dropbomb sty tmp1       ;which sprite
         lda bombamou,y
         bne *+3
         rts

         ;Drop bomb only when source and destination block is the same 
         ;This way bomb drops nicely below the player
         lda spr_scrbld,y
         cmp spr_scrbls,y
         bne _db_end

         ;Search for an empty spot for the bomb. It's free if bomb timer has run to -1 ($ff)
         ldx #$00
_db1      lda bombti,x
          cmp #BOMBNULL
          beq _db2
         inx
         cpx #$10
         bne _db1
         ;There was no slot in the tables. This is a really rare situation!
         jmp _db_end

_db2     stx tmp2         ;bomb number

         ldx tmp1         ;X is used as the sprite number
         ldy spr_scrbls,x ;don't drop another on another
         lda gamemap,y
         cmp #BLOCK_WBOMB
         beq _db_end
         cmp floor        ;has to be floor
         bne _db_end

         ;let's drop it
         dec bombamou,x   ;decrease bomb amount to drop
         tya              ;coordinate to A
         ldy tmp2         ;the bomb number
         sta bombxy,y     ;put bomb coordinate
         lda bombsize,x   ;get size for the bomb
         sta bombsi,y     ;put bomb size
         txa              ;player number to A
         sta bombused,y   ;put bomb owner
         lda #$01         ;reset explosion counter
         sta bombco,y
         lda #$00         ;and reset the rest of the stuff
         sta bombfix,y
         sta lend,y
         sta rend,y
         sta uend,y
         sta dend,y
         lda #BOMBTIME    ;set the time
         sta bombti,y

         ldx bombxy,y     ;xy coord
         lda gamemap,x    ;store the block under bomb
         pha
         ldy #BLOCK_WBOMB
         tya
         sta gamemap,x    ;paint on map
         jsr oneblock     ;print it

         pla              ;give points
         cmp floor
         beq _db_end
         
         tay              ;The block we found
         ldx tmp1         ;Sprite number        
         jsr scorecou

_db_end  ldy tmp1         ;and return with correct Y player number
         rts

;----------------------------------------------
;Explode blocks
;
; NOTE: Uses $10

ExplodeBlock 
         ldy #$00
bf4      sty $10
         ldx explosion_size,y
         beq bf2        ;Last animation frame -> find stuff or floor
         cpx #$ff
         beq nextexp1   ;Nothing to explode
    
         ;Do the animation only every second frame
         txa
         and #%01
         beq nextexp2
         
         lda block_expl_anim,x
bf1      ldx explosion_xy,y
         sta gamemap,x
         tay
         jsr oneblock
         ldy $10
         
nextexp2 tya
         tax
         dec explosion_size,x
nextexp1 iny
         cpy #$40       ;bomb max amount to four different directions
         bne bf4
         rts

bf2      ;Check if you find anything
         lda level
         cmp #LASTLEVEL-1
         bne bf5
         ;If playing the last level, you will not find anything .. only ICE
         lda #BLOCK_FIRE_ICE  
         jmp bf3
         
bf5      inc sat
         ldx sat
         lda loyda,x
         bne bf1
         lda floor
bf3      jmp bf1

;-------------------------------------------------
;EXPLODE THE BOMBS
;
; NOTE: Code here uses zeropage $10 and $11

HandleBomb 
         ldx #$00
_ba3     stx $10                ;we're using $10 as the bomb number

         ldy bombxy,x
         lda gamemap,y
         cmp #BLOCK_BOMBACTIVE
         ;cmp block_expl_anim+block_expl_anim_len-1       ;Check if the first block animation frame is on screen. Don't know why....
         bne _ba4
         lda bombti,x
         cmp #BOMBNULL
         beq nextbomb

         lda #BOMBACTIVE        ;activate bomb NOW, crossfire
         sta bombti,x
_ba4     lda bombti,x
         bne _ba5
         jsr bombexpl           ;bomb is exploding
         jmp nextbomb

_ba5     cmp #BOMBACTIVE
         beq bombacti
         cmp #BOMBNULL
         beq nextbomb
nextbdec dec bombti,x

nextbomb ldx $10
         inx
         cpx #$10
         bne _ba3
         rts

bombacti ldx $10
         lda bombxy,x
         tax
         lda #BLOCK_FIRE
         sta gamemap,x
         ;tay
         jsr oneblock_fire  ;oneblock
         ldx $10
         jmp nextbdec

bombexpl ldx $10
         lda bombsi,x
         asl
         asl
         asl
         asl
         sta _be1+1
_be0     ldy bombco,x
_be1     lda expl,y     ;what is the maximum size now
         sta $11
         bpl _be2       ;the bomb is growing until expl,y=$80
         lda #$01
         sta bombfix,x
         dec bombco,x
         jmp _be0

_be2     lda bombfix,x
         bne fix
         jsr lboex
         jsr rboex
         jsr uboex
         jsr dboex
         ldx $10
         inc bombco,x
         rts

fix      jsr lbofix
         jsr rbofix
         jsr ubofix
         jsr dbofix
         ldx $10        ;has the bomb exploded long enough?
         dec bombco,x
         bmi *+3
         rts
         lda #BOMBNULL
         sta bombti,x
         lda bombused,x ;who is the bomb owner
         tax
         inc bombamou,x ;give the bomb back
         rts

lboex    ldy $10
         lda lend,y
         beq *+3
         rts
         lda bombxy,y
         sec
         sbc $11
         tax
         ldy gamemap,x
         beq plend
         jsr flameCheck
         lda bcol0,y
         and #BIT_THROUGH_EXPLODE
         beq plend
         and #BIT_EXPLODE
         bne putle
         lda #BLOCK_FIRE
         sta gamemap,x
         jmp oneblock_fire  ;oneblock
putle    ldy $10
         txa
         sta explosion_xy,y
         lda #block_expl_anim_len
         sta explosion_size,y
plend    ldy $10
         lda bombco,y
         sta lend,y
         rts

rboex    ldy $10
         lda rend,y
         beq *+3
         rts
         lda bombxy,y
         clc
         adc $11
         tax
         ldy gamemap,x
         beq prend
         jsr flameCheck
         lda bcol0,y
         and #BIT_THROUGH_EXPLODE
         beq prend
         and #BIT_EXPLODE
         bne putre
         lda #BLOCK_FIRE
         sta gamemap,x
         jmp oneblock_fire  ;oneblock
putre    ldy $10
         txa
         sta explosion_xy+$10,y
         lda #block_expl_anim_len
         sta explosion_size+$10,y
prend    ldy $10
         lda bombco,y
         sta rend,y
         rts

uboex    ldy $10
         lda uend,y
         beq *+3
         rts
         lda bombxy,y
         ldx $11
         sec
         sbc ker20lo,x
         tax
         ldy gamemap,x
         beq puend
         jsr flameCheck
         lda bcol0,y
         and #BIT_THROUGH_EXPLODE
         beq puend
         and #BIT_EXPLODE
         bne putue
         lda #BLOCK_FIRE
         sta gamemap,x
         jmp oneblock_fire  ;oneblock
putue    ldy $10
         txa
         sta explosion_xy+$20,y
         lda #block_expl_anim_len
         sta explosion_size+$20,y
puend    ldy $10
         lda bombco,y
         sta uend,y
         rts

dboex    ldy $10
         lda dend,y
         beq *+3
         rts
         lda bombxy,y
         ldx $11
         clc
         adc ker20lo,x
         tax
         ldy gamemap,x
         beq pdend
         jsr flameCheck
         lda bcol0,y
         and #BIT_THROUGH_EXPLODE
         beq pdend
         and #BIT_EXPLODE
         bne putde
         lda #BLOCK_FIRE
         sta gamemap,x
         jmp oneblock_fire  ;oneblock
putde    ldy $10
         txa
         sta explosion_xy+$30,y
         lda #block_expl_anim_len
         sta explosion_size+$30,y
pdend    ldy $10
         lda bombco,y
         sta dend,y
         rts

;----------------------------------------------
;flameCheck
;
; We check what is under this flame. If the flame hits ... 
; - an egg, change the color
; - a white bomb, active it
;
; IN: x=position on map
;     y=block from the map
;
; OUT: MUST return X/Y unmodified

flameCheck
         cpy #BLOCK_WBOMB
         bne _t1
         lda #BLOCK_BOMBACTIVE  ;Bomb activated due to crossfire
         sta gamemap,x
         ;Returns correct Y (BLOCK_WBOMB)
         rts
         
_t1      cpy #BLOCK_EGG_W
         bne _t2
         lda #BLOCK_EGG_Y
         jmp _t4
         
_t2      cpy #BLOCK_EGG_Y
         bne _t3
         lda #BLOCK_EGG_B         
         
_t4      sta gamemap,x
         tay
         jmp oneblock         ;NOTE: This function returns X and Y unchanged
         
_t3      rts

;----------------------------------------------
lbofix   ldy $10
         lda lend,y
         beq lfi1
         lda bombco,y
         cmp lend,y
         bcc *+3
         rts
         lda #$00
         sta lend,y
lfi1     lda bombxy,y
         sec
         sbc $11
         tax
         lda floor
         sta gamemap,x
         tay
         jmp oneblock

rbofix   ldy $10
         lda rend,y
         beq rfi1
         lda bombco,y
         cmp rend,y
         bcc *+3
         rts
         lda #$00
         sta rend,y
rfi1     lda bombxy,y
         clc
         adc $11
         tax
         lda floor
         sta gamemap,x
         tay
         jmp oneblock

ubofix   ldy $10
         lda uend,y
         beq ufi1
         lda bombco,y
         cmp uend,y
         bcc *+3
         rts
         lda #$00
         sta uend,y
ufi1     lda bombxy,y
         ldx $11
         sec
         sbc ker20lo,x
         tax
         lda floor
         sta gamemap,x
         tay
         jmp oneblock

dbofix   ldy $10
         lda dend,y
         beq dfi1
         lda bombco,y
         cmp dend,y
         bcc *+3
         rts
         lda #$00
         sta dend,y
dfi1     lda bombxy,y
         ldx $11
         clc
         adc ker20lo,x
         tax
         lda floor
         sta gamemap,x
         tay
         jmp oneblock
