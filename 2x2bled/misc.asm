;----------------------------------------------------
;Count char datastart address
;
;getCharAddress_CNO: Returns the address on CNO+1 (the active character)
; IN: nothing 
; OUT: ($fd) with char address
;
;getCharAddress: Returns the address of char in A
; IN:  A=char number
; OUT: ($fd) with char address

getCharAddress_CNO
         lda CNO+1
getCharAddress
         ldy #$00     ;FONTstaRT
         sta $FD
         sty $FE
         asl $FD      ;KERROTAAN 8:LLA
         rol $FE
         asl $FD
         rol $FE
         asl $FD
         rol $FE
         lda $FE
         clc
         adc #FDAT/$0100  ;CHARDATAN HI
         sta $FE
         rts

;----------------------------------------------------
;Count block number under cursor
;
; IN: nothing
; OUT: X=Block number
;      Y=..possible something 

getBlockNumber  
         ldy #$00
BLONO    lda #$00     ;SMC!
         cmp #$28
         bcc C401     ;BLOCK NO = X
         sec          ;BDAT(Y)
         sbc #$28
         iny
         iny
C401     lsr
         clc
         adc BlockNum
         tax
         lda BLONO+1
         and #%00000001
         beq *+3
         iny
         rts

;---------------------------
;clearScreen

clearScreen
         ldx #$00         
_cs0     lda #$00
         sta $D800,x
         sta $D900,x
         sta $DA00,x
         sta $DB00,x
         lda #$20
         sta $0400,x
         sta $0500,x
         sta $0600,x
         sta $0700,x
         inx
         bne _cs0
         rts 
;---------------------------
;setDefaultScreen
;
; Reset screen to default c64 font

setDefaultScreen
         lda #$00
         sta $d021
         sta $d020
         lda #$14       ;$16
         sta $d018
         lda #$08
         sta $d016
;         ldx #$1B
;         stx $d011         
         rts

;---------------------------------------
;printNumber
; IN: A=number
;     X=position on infoline

PRINTDECIMAL = 0
PRINTHEX = 1

printNumber
         stx _pn_smc+1
         cpy #PRINTHEX
         beq _pn00
         ;convert the hex number to BCD
         jsr hexToBcd

_pn00    pha
         lsr
         lsr
         lsr
         lsr
         tay
_pn_smc  ldx #$00       ;SMC
         lda Numchars,y
         sta IPLC,x
         inx
         pla
         and #%1111
         tay
         lda Numchars,y
         sta IPLC,x
         rts

;---------------------------------------
;putNo
;
;print hex number to screen position
;
; IN: A,Y=screen address to print to ($AAYY)
;     X=number to print

putNo    sta F1+2
         sta F2+2
         sty F2+1
         iny
         sty F1+1
         txa
         and #%00001111
         tay
         lda NumcharsReverse,y
F1       sta $1000        ;SMC
         txa
         lsr
         lsr
         lsr
         lsr
         tay
         lda NumcharsReverse,y
F2       sta $1000        ;SMC
         rts

;----------------------------------------------------
;PUT Y OR N TO SCREEN
;
; IN: X= 0 or 1 for Y/N
;     AAYY=Screen location as AAYY

PUTYORN  sta F3+2
         sty F3+1
         lda #$99
         cpx #$00
         bne *+4
         lda #$8E
F3       sta $1000
         rts

;----------------------------------------------------
PUTARROW sta F4+2
         sty F4+1
         ldx #$9F
         lda #$A0
         sta $0463+1
         sta $048B+1
         sta $04B3+1
         sta $04DB+1
F4       stx $1000
         rts

;----------------------------------------------------
;Copy/paste block details
; Blocks, colors (but NOT chardata)

block_copy
         jsr getBlockNumber
         lda BCOL0,x
         sta BCOPYTEMP+0
         lda BCOL1,x
         sta BCOPYTEMP+1
         lda BCOL2,x
         sta BCOPYTEMP+2
         lda BCOL3,x
         sta BCOPYTEMP+3
         lda BDAT0,x
         sta BCOPYTEMP+4
         lda BDAT1,x
         sta BCOPYTEMP+5
         lda BDAT2,x
         sta BCOPYTEMP+6
         lda BDAT3,x
         sta BCOPYTEMP+7
         rts
         
block_paste
         jsr getBlockNumber
         lda BCOPYTEMP+0
         sta BCOL0,x
         lda BCOPYTEMP+1
         sta BCOL1,x
         lda BCOPYTEMP+2
         sta BCOL2,x
         lda BCOPYTEMP+3
         sta BCOL3,x
         lda BCOPYTEMP+4
         sta BDAT0,x
         lda BCOPYTEMP+5
         sta BDAT1,x
         lda BCOPYTEMP+6
         sta BDAT2,x
         lda BCOPYTEMP+7
         sta BDAT3,x
         rts

;----------------------------------------------------
;Copy/paste full block details (Blocks, colors, chardata)
;
; The block copied is the one under cursor.

fullBlock_copy
         jsr getBlockNumber
         lda BDAT0,x
         sta COPYTEMP_BLOCK_CHARS+0
         lda BDAT1,x
         sta COPYTEMP_BLOCK_CHARS+1
         lda BDAT2,x
         sta COPYTEMP_BLOCK_CHARS+2
         lda BDAT3,x
         sta COPYTEMP_BLOCK_CHARS+3
         lda BCOL0,x
         sta COPYTEMP_BLOCK_COLORS+0
         lda BCOL1,x
         sta COPYTEMP_BLOCK_COLORS+1
         lda BCOL2,x
         sta COPYTEMP_BLOCK_COLORS+2
         lda BCOL3,x
         sta COPYTEMP_BLOCK_COLORS+3
         
         lda #<COPYTEMP_BLOCK_CHARDATA
         sta $02
         lda #>COPYTEMP_BLOCK_CHARDATA
         sta $03
         
         ldx #$00
_fbc1    lda COPYTEMP_BLOCK_CHARS,x
         jsr getCharAddress
         ldy #$00
_fbc0    lda ($fd),y
         sta ($02),y
         iny
         cpy #$08
         bne _fbc0
         jsr fb_inc02with8
         inx
         cpx #$04
         bne _fbc1
         
         rts

fullBlock_paste
         jsr getBlockNumber         
         lda COPYTEMP_BLOCK_COLORS+0
         sta BCOL0,x
         lda COPYTEMP_BLOCK_COLORS+1
         sta BCOL1,x
         lda COPYTEMP_BLOCK_COLORS+2
         sta BCOL2,x
         lda COPYTEMP_BLOCK_COLORS+3
         sta BCOL3,x

         ldy CNO+1
         tya
         sta BDAT0,x
         iny
         tya
         sta BDAT1,x
         iny
         tya
         sta BDAT2,x
         iny
         tya
         sta BDAT3,x
         
         lda #<COPYTEMP_BLOCK_CHARDATA
         sta $02
         lda #>COPYTEMP_BLOCK_CHARDATA
         sta $03
         
         ldx #$00
_fbp1    ;lda COPYTEMP_BLOCK_CHARS,x
         txa
         clc
         adc CNO+1
         jsr getCharAddress
         ldy #$00
_fbp0    lda ($02),y
         sta ($fd),y
         iny
         cpy #$08
         bne _fbp0
         jsr fb_inc02with8
         inx
         cpx #$04
         bne _fbp1

         rts

;paste_temp  !byte 0,0,0,0

fb_inc02with8
         lda $02
         clc
         adc #$08
         sta $02
         lda $03
         adc #$00
         sta $03
         rts

