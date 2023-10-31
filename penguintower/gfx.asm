;----------------------------------------------
;put scores on screen
;IN: Y=position on screen
;    temp1=

putscore sty temp1
_ps00    lda score,x
         lsr
         lsr
         lsr
         lsr
         tay
         lda numero,y
         ldy temp1
         inc temp1
         sta SCOREROW,y
         lda score,x
         and #$0f
         tay
         lda numero,y
         ldy temp1
         inc temp1
         sta SCOREROW,y
         dex
         dex
         bpl _ps00
         rts

         !byte $ed
numero   !byte $f6,$f7,$f8,$f9,$fa
         !byte $fb,$fc,$fd,$fe,$ff

;----------------------------------------------
;flick the colors for score (etc) on screen

flikala  lda esf
;         cmp #$00
         bne *+3
         rts
         ldy #$00
fc0      ldx #$00

         ;credits
         lda flico+$08,x
         sta SCOREROWD8+19

         ;flick texts
fc1      lda flico+$00,x
         ;P1: and P2:
         sta SCOREROWD8,y
         sta SCOREROWD8+23,y
         
         ;NUTS:
         lda flico+$20,x
         sta SCOREROWD8+11,y
         sta SCOREROWD8+13,y         
         sta SCOREROWD8+34,y  ;NUT
         sta SCOREROWD8+37,y  ;TS:
         iny
         cpy #$03
         bne fc1
         
         ;flick nuts-values
         lda flico+$10,x
         sta SCOREROWD8+16
         sta SCOREROWD8+39 
         inx
         cpx #$10
         bne *+4
         ldx #$00
         stx fc0+1

         ;flick the score line
fc2      ldx #$00
         lda flico,x
         sta SCOREROWD8+3
         sta SCOREROWD8+32
         lda flico+1,x
         sta SCOREROWD8+4
         sta SCOREROWD8+31
         lda flico+2,x
         sta SCOREROWD8+5
         sta SCOREROWD8+30
         lda flico+3,x
         sta SCOREROWD8+6
         sta SCOREROWD8+29
         lda flico+4,x
         sta SCOREROWD8+7
         sta SCOREROWD8+28
         lda flico+5,x
         sta SCOREROWD8+8
         sta SCOREROWD8+27
         lda flico+6,x
         sta SCOREROWD8+9
         sta SCOREROWD8+26
         inx
         cpx #$30
         bne *+4
         ldx #$00
         stx fc2+1
         rts

;----------------------------------------------
;Draw the map to screen

;Plot the blocks to the screen memory
plotmap  lda #<gamemap
         sta $c3
         lda #>gamemap
         sta $c4
         lda #<SCR04
         sta $fb
         lda #>SCR04
         sta $fc
         lda #<(SCR04+$28)
         sta $fd
         lda #>(SCR04+$28)
         sta $fe
         lda #bdat0/$0100
         sta p2x22+2
         lda #bdat1/$0100
         sta p2x24+2
         lda #bdat2/$0100
         sta p2x23+2
         lda #bdat3/$0100
         sta p2x25+2
         jmp p2x2ud

;Plot the colors of blocks to the color memory
plotmapcol lda #<gamemap
         sta $c3
         lda #>gamemap
         sta $c4
         lda #<SCRD8
         sta $fb
         lda #>SCRD8
         sta $fc
         lda #<(SCRD8+$28)
         sta $fd
         lda #>(SCRD8+$28)
         sta $fe
         lda #bcol0/$0100
         sta p2x22+2
         lda #bcol1/$0100
         sta p2x24+2
         lda #bcol2/$0100
         sta p2x23+2
         lda #bcol3/$0100
         sta p2x25+2
         ;jmp p2x2ud ;this is unnecessary

p2x2ud   ldx #$00
         stx temp2
p2x21    ldy #$00
         sty temp1
         lda ($c3),y
         tax
         tya
         asl
         tay
p2x22    lda $ff00,x
         sta ($fb),y
p2x23    lda $ff00,x
         sta ($fd),y
         iny
p2x24    lda $ff00,x
         sta ($fb),y
p2x25    lda $ff00,x
         sta ($fd),y
         ldy temp1
         iny
         cpy #$14
         bne p2x21+2
         lda $fb
         clc
         adc #$50
         sta $fb
         lda $fc
         adc #$00
         sta $fc
         lda $fd
         clc
         adc #$50
         sta $fd
         lda $fe
         adc #$00
         sta $fe
         lda $c3
         clc
         adc #$14
         sta $c3
         lda $c4
         adc #$00
         sta $c4
         inc temp2
         ldx temp2
         cpx #$0c
         bne p2x21
         rts

;----------------------------------------------
;Prints one block on the screen
;
;IN: X = coordinate for the block to draw to
;    Y = block to draw
;
;NOTE: Does not modify X or Y
;NOTE: Does not modify gamemap
;
;oneblockmap tya
;         sta gamemap,x

oneblock 
         ;store X/Y 
         txa 
         pha
         tya
         pha
         
         lda blo01,x            ;scr&map
         sta $06
         sta $08
         lda bhi01,x
         sta $07
         clc
         adc #$d4
         sta $09
         tya
         tax
         ldy #$00
         lda bdat0,x
         sta ($06),y
         lda bcol0,x
         sta ($08),y
         iny
         lda bdat1,x
         sta ($06),y
         lda bcol1,x
         sta ($08),y
         ldy #$28               ;second line
         lda bdat2,x
         sta ($06),y
         lda bcol2,x
         sta ($08),y
         iny 
         lda bdat3,x
         sta ($06),y
         lda bcol3,x
         sta ($08),y

         ;restore X/Y
         pla
         tay
         pla
         tax
         rts

;----------------------------------------------
;Prints one block on the screen
;
;IN: X = coordinate for the block to draw to
;    Y = block to draw
;
;NOTE: Does not modify X or Y
;NOTE: Does not modify gamemap

oneblock_nocolor
         ;store X/Y 
         txa 
         pha
         tya
         pha
         
         lda blo01,x
         sta $06
         lda bhi01,x
         sta $07
         tya
         tax
         ldy #$00
         lda bdat0,x
         sta ($06),y
         iny
         lda bdat1,x
         sta ($06),y
         ldy #$28         ;second line
         lda bdat2,x
         sta ($06),y
         iny
         lda bdat3,x
         sta ($06),y
         
         ;restore X/Y
         pla
         tay
         pla
         tax
         rts

;----------------------------------------------
;Prints one fire block on the screen
;
;IN: X = coordinate for the block to draw to
;
; This is on optimized way to print fire on screen. Hardcoded blocks and colors.
;
; NOTE: This needs to be initialized with oneblock_fire_init
; NOTE: Will modify X and Y
; NOTE: Does not modify gamemap

oneblock_fire
         lda blo01,x            ;scr&map
         sta $06
         sta $08
         lda bhi01,x
         sta $07
         clc
         adc #$d4
         sta $09

         ldy #$00
_fc0     lda #$00               ;SMC: Fireblock data
         sta ($06),y
         iny
_fc1     lda #$00               ;SMC: Fireblock data
         sta ($06),y
         ldy #$28               ;second line
_fc2     lda #$00               ;SMC: Fireblock data
         sta ($06),y
         iny
_fc3     lda #$00               ;SMC: Fireblock data
         sta ($06),y

         ;print color, starting from lower right block corner
_fc4     lda #$00               ;SMC: Fireblock color data
         sta ($08),y
         dey
         sta ($08),y
         ldy #$00
         sta ($08),y
         iny
         sta ($08),y
         rts

;----------------------------------------------
;Initialize oneblock_fire
;
; Copies the right data as SMC for the optimized fire-printer

oneblock_fire_init
         lda bdat0+BLOCK_FIRE
         sta _fc0+1
         lda bdat1+BLOCK_FIRE
         sta _fc1+1
         lda bdat2+BLOCK_FIRE
         sta _fc2+1
         lda bdat3+BLOCK_FIRE
         sta _fc3+1
         lda bcol0+BLOCK_FIRE     ;NOTE: Only one color data is used 
         sta _fc4+1
         rts

;----------------------------------------------
;put a floor block to screen and map
;IN: X = coordinate for the block to draw to

paint    lda floor
         sta gamemap,x
         tay
         jmp oneblock
         