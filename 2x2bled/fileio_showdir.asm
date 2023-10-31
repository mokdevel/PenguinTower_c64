;-----------------------------
;Show directory

DIR_show
         jsr $E566          ;set cursor to 0,0
         
         lda #73
         jsr $FFC3
         lda #73
         ldx #$08
         ldy #$60     ;0
         jsr $FFBA
         lda #1
         ldx #<DIRNAME
         ldy #>DIRNAME
         jsr $FFBD
         jsr $FFC0
         ldx #73
         jsr $FFC6
         jsr $FFCF
         jsr $FFCF
DLINE    jsr $FFCF
         jsr $FFCF
         cmp #$00
         beq DIREND
         jsr $FFCC
         
         ldx #73
         jsr $FFC6
         ldx #$05
         stx $0286
         ldx $D6
         ldy #$00
         clc
         jsr $FFF0
         jsr $FFCF
         tay
         jsr $FFCF
         pha
         tya
         tax
         pla
         jsr $BDCD

DSKIP    jsr $FFCF
         cmp #$22
         beq DSKIP
         pha
         ldx #$0F
         stx $0286
         ldx $D6
         ldy #$04
         clc
         jsr $FFF0
         pla
         jmp DOVER
DNEXT    jsr $FFCF
DOVER    cmp #$00
         beq D1001
         jsr $FFD2
         jmp DNEXT
D1001    lda #13
         jsr $FFD2
         jmp DLINE

DIREND   lda #73
         jsr $FFC3
         jsr $FFCC

         ldx $DC01
         cpx #$EF
         bne *-5
         rts

DIRNAME  !pet "$"