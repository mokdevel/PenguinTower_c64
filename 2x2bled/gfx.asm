;----------------------------------------------------
;Plot char pixels

EDITSCREENPTR = $d829

BITEIT   lda #<EDITSCREENPTR
         ldy #>EDITSCREENPTR
         sta $FB
         sty $FC
         jsr getCharAddress_CNO
         lda $FD
         clc
         adc #$08
         sta TEMP         ;TEMP used as the loop counter in ____DRAW
         ldx CNO+1
         lda FD8PLC,x     ;TARKISTETAAN
         sta MARKCOLOR    ;ONKO HIRES VAI
         and #%00001000   ;MULTI
         beq HIRESDRAW
         jmp MULTIDRAW
         
;----------------------------------------------------
;PLOTATAAN MULTICOLOR MERKKI

MULTIDRAW lda DD021
         sta COLORS+0
         lda DD022
         sta COLORS+1
         lda DD023
         sta COLORS+2
         
         lda MARKCOLOR
         sec
         sbc #$08
         sta COLORS+3
MLOOP2   ldy #$00
         lda ($FD),y
         sta MSAVE1+1
MLOOP1   lda #$00
         sta MCOL+1
MSAVE1   lda #$00
         asl
         rol MCOL+1
         asl
         rol MCOL+1
         sta MSAVE1+1
MCOL     ldx #$00
         lda COLORS,x
         sta ($FB),y
         iny
         sta ($FB),y
         iny
         cpy #$08
         bne MLOOP1
         lda $FB
         clc
         adc #$28
         sta $FB
         lda $FC
         adc #$00
         sta $FC
         inc $FD
         lda $FD
         cmp TEMP
         bne MLOOP2
         ldx #(SPRITE+$40)/$40
         stx $07F8
         lda SPR1X+1
         and #%11111110
         sta SPR1X+1
         rts

;----------------------------------------------------
;PLOTATAAN HIRES MERKKI

HIRESDRAW nop
HLOOP2   ldy #$00
         lda ($FD),y
         tax
HLOOP1   lda DD021
         sta HCOL+1
         txa
         clc
         asl
         tax
         bcc HCOL
         lda MARKCOLOR
         sta HCOL+1
HCOL     lda #$00
         sta ($FB),y
         iny
         cpy #$08
         bne HLOOP1
         lda $FB
         clc
         adc #$28
         sta $FB
         lda $FC
         adc #$00
         sta $FC
         inc $FD
         lda $FD
         cmp TEMP
         bne HLOOP2
         ldx #(SPRITE)/$40
         stx $07F8
         ldx COLOR+1
         beq *+4
         ldx #$03
         stx COLOR+1
         rts

;----------------------------------------------------
;PLOT MAP BLOCK

PLOTBLOCK 
         lda #<MAP    ;BIG TEMP
         sta $C3
         lda #>MAP
         sta $C4

         lda #<SCR04         ;RUUDUNALKU
         sta $FB             ;PLOT 2X2
         lda #>SCR04         ;ALL
         sta $FC
         lda #<(SCR04+$28)
         sta $FD
         lda #>(SCR04+$28)
         sta $FE
         lda #BDAT0/$0100
         sta P2X22+2
         lda #BDAT1/$0100
         sta P2X24+2
         lda #BDAT2/$0100
         sta P2X23+2
         lda #BDAT3/$0100
         sta P2X25+2
         jmp P2X2UD

;----------------------------------------------------
;PLOTMAPCOLOR

PLOTCOLOR 
         lda #<MAP    ;BIG TEMP
         sta $C3
         lda #>MAP
         sta $C4

         lda #<SCRD8         ;RUUDUNALKU
         sta $FB
         lda #>SCRD8
         sta $FC
         lda #<(SCRD8+$28)
         sta $FD
         lda #>(SCRD8+$28)
         sta $FE
         lda #BCOL0/$0100
         sta P2X22+2
         lda #BCOL1/$0100
         sta P2X24+2
         lda #BCOL2/$0100
         sta P2X23+2
         lda #BCOL3/$0100
         sta P2X25+2
         jmp P2X2UD

;----------------------------------------------------
;DRAW BLOCK LINE
;
; IN: A = BLOCKLINE_BLED - 2x2bled
;     A = BLOCKLINE_MAPEDIT - Map editor block line 

BlocklinePos !byte BLOCKLINE_BLED

drawBlockLine 
         ;store 
         sta BlocklinePos

         lda #<BTEMP    ;BIG TEMP
         sta $C3
         lda #>BTEMP
         sta $C4

         ldy #$00
         ldx BlockNum
_db02    txa
         sta ($C3),y
         inx
         iny
         cpy #$14
         bne _db02

         ldx #$01            ;How many lines on blocks to draw
         stx RowCount

         ;draw block data
         lda BlocklinePos
         cmp #BLOCKLINE_MAPEDIT
         beq _db00
         
         ;set bled position
         lda #<BPLC          ;RUUDUNALKU
         sta $FB             ;PLOT 2X2
         lda #>BPLC
         sta $FC
         lda #<(BPLC+$28)
         sta $FD
         lda #>(BPLC+$28)
         sta $FE
         jmp _db01
         
         ;set mapedit position
_db00    lda #<BMPLC         ;RUUDUNALKU
         sta $FB             ;PLOT 2X2
         lda #>BMPLC
         sta $FC
         lda #<(BMPLC+$28)
         sta $FD
         lda #>(BMPLC+$28)
         sta $FE
         
_db01    lda #BDAT0/$0100
         sta P2X22+2
         lda #BDAT1/$0100
         sta P2X24+2
         lda #BDAT2/$0100
         sta P2X23+2
         lda #BDAT3/$0100
         sta P2X25+2
         jsr P2X2UD

         ;draw block colors
         ;reset ($C3)
         lda #<BTEMP         ;BIG TEMP
         sta $C3
         lda #>BTEMP
         sta $C4
         
         lda BlocklinePos
         cmp #BLOCKLINE_MAPEDIT
         beq _db03
         
         lda #<BD8PLC        ;RUUDUNALKU
         sta $FB
         lda #>BD8PLC
         sta $FC
         lda #<(BD8PLC+$28)
         sta $FD
         lda #>(BD8PLC+$28)
         sta $FE
         jmp _db04

_db03    lda #<BMD8PLC       ;RUUDUNALKU
         sta $FB
         lda #>BMD8PLC
         sta $FC
         lda #<(BMD8PLC+$28)
         sta $FD
         lda #>(BMD8PLC+$28)
         sta $FE
         
_db04    lda #BCOL0/$0100
         sta P2X22+2
         lda #BCOL1/$0100
         sta P2X24+2
         lda #BCOL2/$0100
         sta P2X23+2
         lda #BCOL3/$0100
         sta P2X25+2
         jsr P2X2UD
         rts

;----------------------------------------------------
;The main routine to draw blocks
;
; ($C3)   : point to the temp/buffer which has the block numbers to print. This could be the whole map
; RIVIM+1 : the amount of block lines to draw. TBD: This is ugly SMC code, but too lazy to fix.
; ($FB)   : the position on screen for [12]
; ($FD)   : the position on screen for [34]
;
; Block looks like this [12]
;                       [34]

P2X2UD   ldx #$00           ;RIVILASKURI
         stx TEMP2
P2X21    ldy #$00
         sty TEMP1
         lda ($C3),y        ;read the block number to print
         tax                ;move to x
         tya
         asl
         tay
P2X22    lda $1000,x        ;read block data - char or color
         sta ($FB),y        ;print 1
P2X23    lda $1000,x
         sta ($FD),y        ;print 3
         iny
P2X24    lda $1000,x        ;print 2
         sta ($FB),y
P2X25    lda $1000,x        ;print 4
         sta ($FD),y
         ldy TEMP1
         iny
         cpy #$14           ;We can draw 20 ($14) 2x2 blocks on one line
         bne P2X21+2
         
         ;move pointers to next block line. 
         lda $FB
         clc
         adc #$50           ;next block line is 80 characters
         sta $FB
         lda $FC
         adc #$00
         sta $FC
         lda $FD
         clc
         adc #$50
         sta $FD
         lda $FE
         adc #$00
         sta $FE
         lda $C3
         clc
         adc #$14
         sta $C3
         lda $C4
         adc #$00
         sta $C4
         
         ;if we need to print more lines, repeat
         inc TEMP2
         ldx TEMP2
         cpx RowCount
         bne P2X21
         rts

;----------------------------------------------------
;printSingleBlock
;
;IN:  X = blocknumber
;     Y = offset from left side

printSingleBlock
         lda BDAT0,x
         sta BPLC+$78,y
         lda BDAT1,x
         sta BPLC+$79,y
         lda BDAT2,x
         sta BPLC+$A0,y
         lda BDAT3,x
         sta BPLC+$A1,y
         lda BCOL0,x
         sta BD8PLC+$78,y
         lda BCOL1,x
         sta BD8PLC+$79,y
         lda BCOL2,x
         sta BD8PLC+$A0,y
         lda BCOL3,x
         sta BD8PLC+$A1,y
         rts
