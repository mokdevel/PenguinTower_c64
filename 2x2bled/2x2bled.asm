;-------------------------------------------------
;DEFINES

RELEASE
STARTWITHRUN

!ifndef RELEASE {
DEBUG
LOADGFX         ;Load default graphics at compile time
STARTWITHRUN    ;Run will start the program. Otherwise compiled from $0810
}



;---------------------------------------------------
;Include files

!source "..\common\macro.asm"
!source "bledglobal.asm"

;===================================================
;MEMORY MAP
                                                      ;0800 23ff - CODE
        *= HELP_EDITOR
!media  "help_editor.charscreen",char,0,0,40,25       ;2400 27e7 - screen: bled help
                                                      ;27e8 27ff - empty
        *= HELP_MAPEDIT
!media  "help_mapedit.charscreen",char,0,0,40,25      ;2800 2be7 - screen: map editor help
                                                      ;2be8 2dff - empty
        *= BLEDSPRITES
!media  "bledsprites.spriteproject",sprite,0,4        ;2e00 2eff - sprites
        *= BTEMP
        !fill $100                                    ;2f00 2fff - temp of 256 bytes
!ifdef LOADGFX { ;load the graphics automatically
        *= FDAT
!bin    "bindatatest\gamegfx85.prg",,10                           ;2ff8 3fff - block graphics
;!bin    "bindatatest\blocanim78.prg",,10                         ;2ff8 3fff - block graphics
}
        *= BLEDSCREEN
!media  "bledscreen.charscreen",char,0,0,40,25        ;4000 43e7 - screen: block editor
                                                      ;4400 47ff - CODE
                                                      ;4800 48ff - level map during editing
                                                      ;4900 acff - 100 levels
                                                      ;ad00 ffff - area available for packed levels
!ifdef LOADGFX { ;load a test map automatically     
        *= MAP_LEVELS
!bin    "bindatatest\level01.bin",,2                    
}

!ifndef LOADGFX {
        *= FDAT
        !fill $0800   ;clear font data
        !fill $0800   ;clear block data
        *= MAP
        !fill $0100   ;clear map data 
}
    
;---------------------------------------------------
;start jump vectors

!ifdef STARTWITHRUN {
         *= $0801
         !basic
}

!ifndef STARTWITHRUN {
         *= $0810
}
         
;         lda #$00
;         sta $c6
;         jsr $ffe4
;         lda #$00
;         sta $c6
;         jsr $ffe4
;         beq *-3
;         jmp packlevels

         lda #$36
         sta $01
         ldx #$80               
         stx $0291              ;disable shift
         ldx #$00
         stx $c6                ;clear key buffer
         jsr Inithelp
         lda #S_IRQ_HELP_EDITOR
         sta s_irq
         jmp START

;---------------------------------------------
!source "irq.asm"
;---------------------------------------------


;---------------------------------------------

FIXSCREEN ldx FINDER      ;;;;;;;
         beq SPR1X
         
         ldx BLONO+1
         lda BPLC,x
         sta CNO+1

         ;character bitmap sprite
SPR1X    ldx #$00
SPR1Y    ldy #$00
         lda SPRX,x
         clc
         adc #$01
         sta $d000
         lda SPRY,y
;         sec
;         sbc #13
         clc
         adc #$03
         sta $d001

         lda #$00
         sta $d010

         ;other sprites
         ldy #$00
         lda BLONO+1
         cmp #$28
         bcc FS1
         sec
         sbc #$28
         ldy #$01
FS1      tax
         lda SPRX,x
         sec
         sbc #$08
         sta $d004
         cpx #$1D
         bcc *+10
         lda $d010
         ora #%00000100
         sta $d010
         lda SPRY,y
         clc
         adc #$4A
         sta $d005

         lda CNO+1
         cmp #$F0
         bcc FS3-2
         sec
         sbc #$F0
         ldx #$07
         jmp FS4
         ldx #$FF
FS3      inx
         cmp SCRYLOPLC,x
         bcs FS3
         sec
         sbc SCRYLOPLC-1,x
FS4      tay
         lda SPRX,y
         sec
         sbc #$08
         sta $d006
         cpy #$1D
         bcc *+10
         lda $d010
         ora #%00001000
         sta $d010
         lda SPRY,x
         clc
         adc #$82
         sta $d007

         ;draw the individual block
         jsr getBlockNumber
         ldy #$01
         jsr printSingleBlock

         ldy #$04
         jsr printSingleBlock
         ldy #$06
         jsr printSingleBlock
         ldy #$08
         jsr printSingleBlock

         ;Print character number
         ldx CNO+1 
         txa
         clc
         adc #$80
         sta $0437
         ldy #$39+1
         lda #$04
         jsr putNo

         ;Print block number
         jsr getBlockNumber     ;BLOCK NO
         ldy #$43+2
         lda #$04
         jsr putNo

         ;Print block character number
         ldx BLONO+1     ;BMARK NO
         lda BPLC,x
         tax
         ldy #$6B+2
         lda #$04
         jsr putNo

         lda DD021
         tax
         and #%00001111
         sta $D861+1
         sta $D862+1
         ldy #$5F+1
         lda #$04
         jsr putNo

         lda DD022
         tax
         and #%00001111
         sta $D889+1
         sta $D88A+1
         ldy #$87+1
         lda #$04
         jsr putNo

         lda DD023
         tax
         and #%00001111
         sta $D8B1+1
         sta $D8B2+1
         ldy #$AF+1
         lda #$04
         jsr putNo

         jsr getBlockNumber
         lda BCOL0,x
         and #%11110000
         sta BCORA+1
         ldx BLONO+1
         lda BD8PLC,x
         ldy FINDER
         bne *+8
         ldx CNO+1         ;BMARK COL
         lda FD8PLC,x
         and #%00001111
BCORA    ora #$00
         tax
         and #%00000111
         sta $D8D9+1
         sta $D8DA+1
         ldy #$D7+1
         lda #$04
         jsr putNo

COLOR    ldx #$00
         beq A0
         cpx #$01
         beq A1
         cpx #$02
         beq A2
A3       ldy #$DB+1
         lda #$04
         jmp A4
A0       ldy #$63+1
         lda #$04
         jmp A4
A1       ldy #$8B+1
         lda #$04
         jmp A4
A2       ldy #$B3+1
         lda #$04
A4       jsr PUTARROW

         ldx ZLIDE
         ldy #$28+1
         lda #$05
         jsr PUTYORN

         ldx FINDER
         ldy #$50+1
         lda #$05
         jsr PUTYORN

         jsr getBlockNumber            ;BIT5
         lda BCOL0,x
         and #BIT_THROUGH
         tax
         ldy #$E6+1
         lda #$04
         jsr PUTYORN

         jsr getBlockNumber            ;BIT5
         lda BCOL0,x
         and #BIT_EXPLODE
         tax
         ldy #$0E+1
         lda #$05
         jsr PUTYORN

         jsr getBlockNumber            ;BIT6
         lda BCOL0,x
         and #BIT_SPECIAL
         tax
         ldy #$36+1
         lda #$05
         jsr PUTYORN

         jsr getBlockNumber            ;BIT7
         lda BCOL0,x
         and #BIT_KILL
         tax
         ldy #$5E+1
         lda #$05
         jsr PUTYORN

CNO      lda #$00       ;CHARNO
         sec
         sbc #$14
         tax
         ldy #$00
CLOOP1   txa
         sta $0680,y
         lda FD8PLC,x
         sta $DA80,y
         inx
         iny
         cpy #$28
         bne CLOOP1

         jsr getBlockNumber    ;FIXBLOCKS
         lda BCOL0,x
         sta TEMP
         lda BCOL1,x
         sta TEMP1
         lda BCOL2,x
         sta TEMP2
         lda BCOL3,x
         sta TEMP3

         ldy BDAT0,x
         lda TEMP
         sta FD8PLC,y
         ldy BDAT1,x
         lda TEMP1
         sta FD8PLC,y
         ldy BDAT2,x
         lda TEMP2
         sta FD8PLC,y
         ldy BDAT3,x
         lda TEMP3
         sta FD8PLC,y

         ldx BLONO+1
         ldy BPLC,x
         lda BD8PLC,x
         sta FD8PLC,y

         lda #$01
         ldy #$02
         ldx RETURN
         beq *+6
         lda #$02
         ldy #$01
         sty $d029
         sta $d02A
         rts
         
;-------------------------------------------------
;Keypress handler 
;
;see: https://sta.c64.org/cbm64petkey.html

KEYCHECK
         lda keypress
         bne *+3
         rts

         ldx RETURN          ; if cursor in blockline, ignore CRSR keys
         bne K4
         
         cmp #$9D            ; CRSR L
         bne K1
         dec CNO+1
         rts
K1       cmp #$1D            ; CRSR R
         bne K2
         inc CNO+1
         rts
K2       cmp #$11            ; CRSR D
         bne K3
         lda CNO+1
         clc
         adc #$28
         sta CNO+1
         rts
K3       cmp #$91            ; CRSR U
         bne K4
         lda CNO+1
         sec
         sbc #$28
         sta CNO+1
         rts

K4       cmp #$21            ; S+1
         bne K5
         lda DD021
         clc
         adc #$01
         and #%00001111
         sta DD021
         rts

K5       cmp #$22            ; S+2
         bne K6
         lda DD022
         clc
         adc #$01
         and #%00001111
         sta DD022
         rts

K6       cmp #$23            ; S+3
         bne K7
         lda DD023
         clc
         adc #$01
         and #%00001111
         sta DD023
         rts

K7       cmp #$24            ; S+4
         bne K8
         jsr getBlockNumber
         tya
         clc
         adc #BCOL0/$0100
         sta K7A+2
         sta K7B+2
         sta K7D+2
K7A      lda $1000,x
         clc
         adc #$01
         and #%00001111
         sta K7C+1
K7B      lda $1000,x
         and #%11110000
K7C      ora #$00
K7D      sta $1000,x
         rts

K8       cmp #$5A            ; Z
         bne K9
         lda ZLIDE
         eor #$01
         sta ZLIDE
         rts

K9       cmp #$03            ; R/S
         bne K10
         ldy #$1C
CD018    ldx #$00
         bne *+4
         ldy #$15
         lda CD018+1
         eor #$01
         sta CD018+1
         sty DD018+1
         rts

K10      cmp #$31            ; 1
         bne K11
         ldx #$00
         stx COLOR+1
         rts

K11      cmp #$32            ; 2
         bne K12
         ldx #$01
         stx COLOR+1
         rts

K12      cmp #$33            ; 3
         bne K13
         ldx #$02
         stx COLOR+1
         rts

K13      cmp #$34            ; 4
         bne K14
         ldx #$03
         stx COLOR+1
         rts

K14      cmp #$93            ; CLR
         bne K15
         jsr getCharAddress_CNO
         ldy #$00
K14B     lda #$00
         sta ($FD),y
         iny
         cpy #$08
         bne K14B
         rts

K15      cmp #$43            ; C
         bne K16
         jsr getCharAddress_CNO
         ldy #$00
K15B     lda ($FD),y
         sta COPYTEMP,y
         iny
         cpy #$08
         bne K15B
         rts

K16      cmp #$56            ; V
         bne K17
         jsr getCharAddress_CNO
         ldy #$00
K16B     lda COPYTEMP,y
         sta ($FD),y
         iny
         cpy #$08
         bne K16B
         rts

K17      cmp #$2C            ; ,
         bne K18
         dec BlockNum
         rts

K18      cmp #$2E            ; .
         bne K17a
         inc BlockNum
         rts

K17a     cmp #$5D            ; ] aka S+,
         bne K18a
         lda BlockNum
         sec
         sbc #10
         sta BlockNum
         rts
         
K18a     cmp #$3A            ; : aka S+.
         bne K19
         lda BlockNum
         clc
         adc #10
         sta BlockNum
         rts

K19      ldx RETURN
         beq K23
         cmp #$9D            ; CRSR L
         bne K20
         ldx BLONO+1
         dex
         cpx #$FF
         beq K20-1
         stx BLONO+1
         rts
K20      cmp #$1D            ; CRSR R
         bne K21
         ldx BLONO+1
         inx
         cpx #$50
         beq K21-1
         stx BLONO+1
         rts
K21      cmp #$11            ; CRSR D
         bne K22
         lda BLONO+1
         clc
         adc #$28
         cmp #$50
         bcs K22-1
         sta BLONO+1
         rts
K22      cmp #$91            ; CRSR U
         bne K23
         lda BLONO+1
         sec
         sbc #$28
         cmp #$D8
         bcs K23-1
         sta BLONO+1
         rts

K23      cmp #$20            ; SPACE
         bne K24
         jsr getBlockNumber
         tya
         clc
         adc #BDAT0/$0100
         sta K23A+2
         clc
         adc #$04
         sta K23B+2
         sta K23C+2

         ldy CNO+1
         tya
K23A     sta $1000,x
K23C     lda $1000,x
         and #%11110000
         sta K23B-1
         lda FD8PLC,y
         and #%00001111
         ora #$00
K23B     sta $1000,x
         rts

K24      cmp #$0D            ; RETURN
         bne K25
         lda RETURN
         eor #$01
         sta RETURN
         rts

K25      cmp #$C3            ; S+C
         bne K26
         jsr block_copy
         rts

K26      cmp #$D6            ; S+V
         bne K27
         jsr block_paste
         rts

K27      cmp #$46            ; F
         bne K28
         lda FINDER
         eor #$01
         sta FINDER
         rts

K28      cmp #$94            ; INST
         bne K29
         jsr getBlockNumber
         lda CNO+1
         sta BDAT0,x
         sta BDAT1,x
         sta BDAT2,x
         sta BDAT3,x
         tay
         lda FD8PLC,y
         and #%00001111
         sta BCOL0,x
         sta BCOL1,x
         sta BCOL2,x
         sta BCOL3,x
         rts

K29      cmp #$A7            ; CBM+M - clear all font data
         bne K30
         ldx #$00
K29B     lda #$00
         sta FDAT,x
         sta FDAT+$0100,x
         sta FDAT+$0200,x
         sta FDAT+$0300,x
         sta FDAT+$0400,x
         sta FDAT+$0500,x
         sta FDAT+$0600,x
         sta FDAT+$0700,x
         lda DD021
         sta FD8PLC,x
         inx
         bne K29B
         ldx #$00
         stx DD021
         stx DD022
         stx DD023
         rts

K30      cmp #$BF            ; CBM+B - clear all blocks
         bne K31
         ldx #$00
         lda #$00
K30B     sta BDAT0,x
         sta BDAT1,x
         sta BDAT2,x
         sta BDAT3,x
         sta BCOL0,x
         sta BCOL1,x
         sta BCOL2,x
         sta BCOL3,x
         inx
         bne K30B
         rts

K31      cmp #$13            ; HOME
         bne K32
         ldx #$00
         stx CNO+1
         rts

K32      cmp #$14            ; DEL
         bne K33
         ldx #$00
         stx BlockNum
         stx BLONO+1
         rts

K33      cmp #$85            ; F1
         bne K36
         jsr getBlockNumber
         lda BCOL0,x
         eor #%00010000
         sta BCOL0,x
         rts

K36      cmp #$86            ; F3
         bne K37
         jsr getBlockNumber
         lda BCOL0,x
         eor #%00100000
         sta BCOL0,x
         rts
K37      cmp #$87            ; F5
         bne K38
         jsr getBlockNumber
         lda BCOL0,x
         eor #%01000000
         sta BCOL0,x
         rts

K38      cmp #$88            ; F7
         bne K39
         jsr getBlockNumber
         lda BCOL0,x
         eor #%10000000
         sta BCOL0,x
         rts
K39      cmp #$58            ; X
         beq *+5
         jmp K40              ;Need to jmp as bne cannot reach
         jsr getCharAddress_CNO
         ldx #$00
         stx TEMP
         ldx CNO+1
         lda FD8PLC,x        ;ONKO HIRES
         and #%00001000
         beq K39HIRES

         ldy #$00             ;K39MULTI
K39M5    ldx #$00
         stx K39M4+1
K39M4    ldx #$00
         lda MAND+4,x
         eor #$FF
         sta K39M6+1
         lda ($FD),y
K39M6    and #$00
K39M1    cpx #$00
         beq K39M2
         lsr 
         lsr 
         dex
         jmp K39M1

K39M2    asl 
         asl 
         sta K39M3+1
         lda K39M4+1
         clc
K39M3    adc #$00
         tax
         lda TEMP
         ora MPLOTME,x
         sta TEMP
         inc K39M4+1
         ldx K39M4+1
         cpx #$04
         bne K39M4
         lda TEMP
         sta ($FD),y
         lda #$00
         sta TEMP
         iny
         cpy #$08
         bne K39M5
         rts

K39HIRES ldy #$00
         ldx #$00
K39H2    lda ($FD),y
         and HPLOTME,x
         beq K39H1
         lda TEMP
         ora HPLOTME+8,x
         sta TEMP
K39H1    inx
         cpx #$08
         bne K39H2
         lda TEMP
         sta ($FD),y
         lda #$00
         sta TEMP
         iny
         cpy #$08
         bne K39H2-2
         rts

K40      cmp #$59            ; Y
         bne K41
         jsr getCharAddress_CNO
         ldy #$00
K40B     lda ($FD),y
         sta COPYTEMP,y
         iny
         cpy #$08
         bne K40B
         dey
         ldx #$00
K40C     lda COPYTEMP,x
         sta ($FD),y
         dey
         inx
         cpx #$08
         bne K40C
         rts

K41      cmp #$52            ; R
         bne K42
         jsr getCharAddress_CNO
         ldy #$00
         lda ($FD),y
         sta TEMP
K41B     iny
         lda ($FD),y
         dey
         sta ($FD),y
         iny
         cpy #$07
         bne K41B
         lda TEMP
         sta ($FD),y
         rts
K42      cmp #$49            ; I
         bne K43
         jsr getCharAddress_CNO
         ldy #$00
K42B     lda ($FD),y
         eor #$FF
         sta ($FD),y
         iny
         cpy #$08
         bne K42B
         rts
K43      cmp #$4D            ; M
         bne K44
         ;ldx MAP+$01CC
         ldx MAPCOLOR_D021
         stx DD021
         ;ldx MAP+$01CD
         ldx MAPCOLOR_D022
         stx DD022
         ;ldx MAP+$01CE
         ldx MAPCOLOR_D023
         stx DD023
         rts
K44      cmp #$A2            ; C+I
         bne K45
         jsr getBlockNumber
         cpx #$FF
         beq K45-1
         stx K44C+1
         ldx #$FF
K44B     dex
         lda BDAT0,x
         sta BDAT0+1,x
         lda BDAT1,x
         sta BDAT1+1,x
         lda BDAT2,x
         sta BDAT2+1,x
         lda BDAT3,x
         sta BDAT3+1,x
         lda BCOL0,x
         sta BCOL0+1,x
         lda BCOL1,x
         sta BCOL1+1,x
         lda BCOL2,x
         sta BCOL2+1,x
         lda BCOL3,x
         sta BCOL3+1,x
K44C     cpx #$00
         bne K44B

         ldx #$00
K44D     lda MAP,x
         cmp K44C+1
         bcc *+5
         inc MAP,x
         lda MAP+$C8,x
         cmp K44C+1
         bcc *+5
         inc MAP+$C8,x
         inx
         cpx #$C8
         bne K44D
         rts
K45      cmp #$AC            ; C+D
         bne K46
         jsr getBlockNumber
         cpx #$FF
         beq K46-1
         stx K45C+1
K45B     lda BDAT0+1,x
         sta BDAT0,x
         lda BDAT1+1,x
         sta BDAT1,x
         lda BDAT2+1,x
         sta BDAT2,x
         lda BDAT3+1,x
         sta BDAT3,x
         lda BCOL0+1,x
         sta BCOL0,x
         lda BCOL1+1,x
         sta BCOL1,x
         lda BCOL2+1,x
         sta BCOL2,x
         lda BCOL3+1,x
         sta BCOL3,x
         inx
         cpx #$FF
         bne K45B

         ldx #$00
K45D     lda MAP,x
K45C     cmp #$00
         bcc *+5
         dec MAP,x
         lda MAP+$C8,x
         cmp K45C+1
         bcc *+5
         dec MAP+$C8,x
         inx
         cpx #$C8
         bne K45D
         rts

K46      cmp #"H"            ; H
         bne K47
         jsr Inithelp
         lda #S_IRQ_HELP_EDITOR
         sta s_irq
         rts
         
K47      cmp #$26            ; & -> Show DIR
         bne K48
         jmp FileDirectory_Show ;NOTE: This never returns and jumps to editor init

K48      cmp #$5F            ; _
         bne K49
         jsr Initmapedit
         lda #S_IRQ_MAPEDIT
         sta s_irq
         rts

K49      cmp #$CC            ; S+L
         bne K50
         jsr NOIRQ
         ldx #LOADSAVE_BLED_LOAD
         jmp GETNAME

K50      cmp #$D3            ; S+S
         bne K51
         jsr NOIRQ
         ldx #LOADSAVE_BLED_SAVE
         jmp GETNAME

K51      cmp #$BC            ; C+C
         bne K52
         jsr fullBlock_copy
         rts

K52      cmp #$BE            ; C+V
         bne K53
         jsr fullBlock_paste
         rts
K53
         rts

;---CHECK JOYSTICK---

JOYCHECK ldx #$00
         beq J1
         dex
         stx JOYCHECK+1
         rts
J1       ldx #$03
         stx JOYCHECK+1
         ldx CNO+1
         lda FD8PLC,x      ;TARKISTETAAN
         and #%00001000    ;MULTI/HIRES
         sta TEMP
         lda $DC00
         and #%00011111
         eor #%00011111
         bne *+3
         rts
         ldx CNO+1
         lda FD8PLC,x
         sta $DAD0,x
         lda $DC00
         lsr
         bcs DOWN
         ;Joy Up
UP       ldx SPR1Y+1
         dex
         cpx #$FF
         beq UP1
         stx SPR1Y+1
         jmp FIRE
UP1      ldx #$00
         ldy ZLIDE
         beq UP2
         lda CNO+1
         sec
         sbc #$28
         sta CNO+1
         ldx #$07
UP2      stx SPR1Y+1
         jmp FIRE
         ;Joy Down
DOWN     lsr
         bcs LEFT
         ldx SPR1Y+1
         inx
         cpx #$08
         beq DOWN1
         stx SPR1Y+1
         jmp FIRE
DOWN1    ldx #$07
         ldy ZLIDE
         beq DOWN2
         lda CNO+1
         clc
         adc #$28
         sta CNO+1
         ldx #$00
DOWN2    stx SPR1Y+1
         jmp FIRE
         ;Joy Left
LEFT     lsr
         bcs RIGHT
         ldx SPR1X+1
         dex
         ldy TEMP
         beq *+3
         dex
         cpx #$FF
         beq LEFT1
         cpx #$FE
         beq LEFT1
         stx SPR1X+1
         jmp FIRE
LEFT1    ldx #$00
         ldy ZLIDE
         beq LEFT2
         dec CNO+1
         ldx #$07
LEFT2    stx SPR1X+1
         jmp FIRE
         ;Joy Right
RIGHT    lsr
         bcs FIRE
         ldx SPR1X+1
         inx
         ldy TEMP
         beq *+3
         inx
         cpx #$08
         beq RIGHT1
         cpx #$09
         beq RIGHT1
         stx SPR1X+1
         jmp FIRE
RIGHT1   ldx #$07
         ldy ZLIDE
         beq RIGHT2
         inc CNO+1
         ldx #$00
RIGHT2   stx SPR1X+1
         jmp FIRE

FIRE     lda $DC00
         lsr
         lsr
         lsr
         lsr
         lsr
         bcc PLOT
         rts
PLOT     jsr getCharAddress_CNO
         ldx TEMP
         beq HIRESPLO

         ;Plot multicolor
         lda COLOR+1  ;MULTIPLO
;         ldx MTEMP
;         beq M1
;         lda #$00
         sta MUCOL+1
;         lda MTEMP
;         eor #$01
;         sta MTEMP
         lda SPR1X+1
         lsr
         sta MLISA+1
         tax
         ldy SPR1Y+1
         lda ($FD),y
         and MAND,x
         tay
MUCOL    lda #$00
         asl
         asl
         clc
MLISA    adc #$00
         tax
         tya
         ora MPLOTME,x
         ldy SPR1Y+1
         sta ($FD),y
         rts

;MTEMP    !byte 0
MAND     !byte $3F,$CF,$F3,$FC
         !byte $FC,$F3,$CF,$3F
MPLOTME  !byte $00,$00,$00,$00
         !byte $40,$10,$04,$01
         !byte $80,$20,$08,$02
         !byte $C0,$30,$0C,$03

         ;Plot hires
HIRESPLO ldy SPR1Y+1
         lda ($FD),y
         ldx SPR1X+1
         eor HPLOTME,x
         jmp HPLO
         ldx COLOR+1
         beq H2
         ldx SPR1X+1
         ora HPLOTME,x
         jmp HPLO
H2       ldx SPR1X+1
         lda HPLOTME,x
         eor #$FF
         sta HAND+1
         lda ($FD),y
HAND     and #$00
HPLO     sta ($FD),y
         rts

FINDER   !byte 0
ZLIDE    !byte 0
;TRANS    !byte 0
HPLOTME  !byte $80,$40,$20,$10
         !byte $08,$04,$02,$01
         !byte $01,$02,$04,$08
         !byte $10,$20,$40,$80

;-----------------------------------
;CODE_1 - $0800 - $23ff
;CODE_2 - $4400 - $47ff

!source "mapedit.asm"
!source "misc.asm"
!source "gfx.asm"
!source "getfilename.asm"
!source "bledfileio.asm"
!source "fileio_showdir.asm"
!source "pack.asm"
!source "packer.asm"
;
         * = CODE_2
!source "init.asm"
!source "data.asm"
!source "..\common\fileio.asm"
!source "..\common\chrout.asm"

;