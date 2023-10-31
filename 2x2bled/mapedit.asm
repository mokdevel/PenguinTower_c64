;---------------------------------------
;MAPEDITOR

;---------------------------------------
;MAPEDITOR IRQ

MAPIRQ   ;set the details screen 
         lda MRETURN
         bne _mi01

         +setd020 2
         jsr drawMapeditInfo
         +setd020 0

         lda #$e2
         cmp $d012
         bne *-3

         ;fixing timings
         ldx #$07
         dex
         bne *-1
         nop
         nop

         ldx #$08
         stx $d016
         ldx #INFO_MAPEDIT_D018
         stx $d018
         ldx #$00
         stx $d021
         
         lda #$ea
         cmp $d012
         bne *-3

         ;fixing timings
         ldx #$07
         dex
         bne *-1
         nop
         nop
         
_mi01    
         ldx #$D8
         stx $d016
         ldx #$1C
         stx $d018
         ldx MAPCOLOR_D021
         stx $d021
         ldx MAPCOLOR_D022
         stx $d022
         ldx MAPCOLOR_D023
         stx $d023
         
         ldx #%00000011
         stx $d015
         ldx #$01
         stx $d027 ;SPR
         stx $d028 ;SPR
         ldx #(SPRITE-$80)/$40
         stx $07F8
         stx $07F9
         ldx #$A8
         stx $d002
         ldx #$EA
         stx $d003

         ldx MAPX
         ldy MAPY
         txa
         asl
         tax
         lda SPRX,x
         sec
         sbc #$08
         sta $d000
         lda #$00
         cpx #$1D
         bcc *+4
         lda #%00000001
         sta $d010

         tya
         asl
         tay
         lda SPRY,y
         sec
         sbc #$06
         sta $d001

;         lda #BLOCKLINE_MAPEDIT
;         jsr drawBlockLine

         +setd020 7
         jsr MAPKEYS
         +setd020 0
         
         lda UpdateMapscreen
         beq _mi00
          jsr mapscreenUpdate
          lda #$00
          sta UpdateMapscreen
_mi00         
         rts


;---------------------------------------
;drawMapeditInfo

drawMapeditInfo
         ldx #$00
_dmi00   lda TextMapeditInfo,x
         sta IPLC,x
         lda #$0b
         sta ID8PLC,x
         inx
         cpx #40
         bne _dmi00

         lda LevelNum
         ldx #04
         ldy #PRINTDECIMAL
         jsr printNumber
         
         lda MAPCOLOR_D021
         ldx #13
         ldy #PRINTHEX
         jsr printNumber
         lda MAPCOLOR_D022
         ldx #13+9
         ldy #PRINTHEX
         jsr printNumber
         lda MAPCOLOR_D023
         ldx #13+18
         ldy #PRINTHEX
         jsr printNumber
                  
         lda BlockNum
         clc
         adc #9
         tax
         lda BCOL0,x
         and #BIT_THROUGH
         tax
         ldy #<($0400+22*40+36)
         lda #>($0400+22*40+36)
         jsr PUTYORN

         lda BlockNum
         clc
         adc #9
         tax
         lda BCOL0,x
         and #BIT_EXPLODE
         tax
         ldy #<($0400+22*40+39)
         lda #>($0400+22*40+39)
         jsr PUTYORN         
         
         rts         
                     ;0123456789012345678901234567890123456789
TextMapeditInfo !scr "lvl:##-d021:$## d022:$## d023:$##  tY xY"

;---------------------------------------
;mapscreenUpdate
         
mapscreenUpdate
         lda MRETURN
         bne _fs01
          lda #BLOCKLINE_MAPEDIT
          jsr drawBlockLine
          ldx #$00
          lda #$00
_fs02     sta $0400+(22*40),x
          sta $d800+(22*40),x
          inx
          cpx #$28
          bne _fs02

_fs01    ldx #$0B
         lda MRETURN
         beq _fs00
         inx
_fs00    stx RowCount
         jsr PLOTBLOCK
         jsr PLOTCOLOR
         rts

         ;The map editor IRQ
;---GET MAP KEYS---
;see: https://sta.c64.org/cbm64petkey.html

MAPKEYS  lda keypress
         bne _mk0
         rts

_mk0     cmp #$9D            ; CRSR L
         bne M01
         ldx MAPX
         dex
         cpx #$FF
         beq M0_end
         stx MAPX
M0_end   rts
M01      cmp #$1D            ; CRSR R
         bne M2
         ldx MAPX
         inx
         cpx #$14
         beq M1_end
         stx MAPX
M1_end   rts
M2       cmp #$11            ; CRSR D
         bne M3
         ldx MAPY
         inx
         stx MAPY         
         ;depending on MRETURN, we may go a line further
         lda MRETURN
         beq _m201
         cpx #$0c
         bcc M2_end         
         ldx #$0b
         stx MAPY
         jmp M2_end         
_m201    cpx #$0B
         bcc M2_end
         ldx #$0a
         stx MAPY
M2_end   rts

M3       cmp #$91            ; CRSR U
         bne M4
         ldx MAPY
         dex
         stx MAPY
         cpx #$FF
         bne M3_end
         inc MAPY
M3_end   rts
M4       cmp #$20             ;SPACE
         bne M5
         ldx MAPY
         lda KER20LO,x
         sta M4B+1
         lda KER20HI,x
         sta M4B+2
         lda BlockNum         ;this is the first block on the blockline
         clc
         adc #$09             ;pick the middle block 
         ldy MAPX
M4B      sta $1000,y
         inc UpdateMapscreen
         rts

M5       cmp #$14            ; DEL
         bne M7
         ldx #$F7
         stx BlockNum
         rts

M7       cmp #"F"            ; F
         bne M8
         ldx MAPY
         lda KER20LO,x
         clc
         adc MAPX
         tax
         lda MAP,x
         sec
         sbc #$09             ;pick the middle block 
         sta BlockNum
         inc UpdateMapscreen         
         rts
         
M8       cmp #$93            ; CLR
         bne M9
         ldx #$00
M8B      lda BlockNum
         clc
         adc #$09
         sta MAP,x
         inx
         cpx #20*12
         bne M8B
         inc UpdateMapscreen
         rts

M9       cmp #$2C            ; ,
         bne M10
         dec BlockNum
         inc UpdateMapscreen         
         rts
M10      cmp #$2E            ; .
         bne M9a
         inc BlockNum
         inc UpdateMapscreen         
         rts

M9a      cmp #$5D            ; ] aka S+,
         bne M10a
         lda BlockNum
         sec
         sbc #10
         sta BlockNum
         inc UpdateMapscreen         
         rts
M10a     cmp #$3A            ; : aka S+.
         bne M11
         lda BlockNum
         clc
         adc #10
         sta BlockNum
         inc UpdateMapscreen         
         rts

M11      cmp #$0D            ; RETURN
         bne M12
         lda MRETURN
         eor #$01
         sta MRETURN

         lda MRETURN
         bne _m1101
         ldx MAPY
         cpx #$0b
         bne _m1101         
         ldx #$0a
         stx MAPY
_m1101   inc UpdateMapscreen         
         rts
         
M12      cmp #"H"            ; H
         bne M13
         jsr Inithelp
         lda #S_IRQ_HELP_MAPEDIT
         sta s_irq
         rts
         
M13      cmp #$5F            ; _ - Go to BLED
         bne M15
         jsr mapStore
         jsr Initbled
         lda #S_IRQ_BLED
         sta s_irq
         rts

M15      cmp #$21            ; S+1
         bne M16
         lda MAPCOLOR_D021
         clc
         adc #$01
         and #%00001111
         sta MAPCOLOR_D021
         rts

M16      cmp #$22            ; S+2
         bne M17
         lda MAPCOLOR_D022
         clc
         adc #$01
         and #%00001111
         sta MAPCOLOR_D022
         rts

M17      cmp #$23            ; S+3
         bne M18
         lda MAPCOLOR_D023
         clc
         adc #$01
         and #%00001111
         sta MAPCOLOR_D023
         rts
M18      cmp #$CC            ; S+L
         bne M19
         jsr NOIRQ
         ldx #LOADSAVE_MAPEDIT_LOAD
         jmp GETNAME

M19      cmp #$D3            ; S+S
         bne M20
         jsr NOIRQ
         ldx #LOADSAVE_MAPEDIT_SAVE
         jmp GETNAME
         
M20      cmp #"M"            ; M
         bne M21
         jsr mapStore
         lda #01
         jsr levelNumModify
         jsr levelRelocate
         inc UpdateMapscreen         
         rts
         
M21      cmp #"N"            ; N
         bne M22
         jsr mapStore
         lda #-01
         jsr levelNumModify
         jsr levelRelocate
         inc UpdateMapscreen         
         rts
         
M22      cmp #$CD            ; S+M
         bne M23
         jsr mapStore
         lda #10
         jsr levelNumModify
         jsr levelRelocate
         inc UpdateMapscreen
         rts
         
M23      cmp #$CE            ; S+N
         bne M24
         jsr mapStore
         lda #-10
         jsr levelNumModify
         jsr levelRelocate
         inc UpdateMapscreen         
         rts
         
M24      cmp #$CF            ; S+O  - batch load all maps. 
         bne M25
         jmp level_LoadAll

M25      cmp #$D1            ; S+Q  - pack levels
         bne M26
         jmp packlevels
M26      
         rts

;---------------------------------------
;levelNumModify
;
; IN: A=amount to modify 

levelNumModify
         clc
         adc LevelNum
         cmp #100
         bcc _lnm0        ;value between 0-99
         bmi _lnm1        ;value is negative
         ;value rolled over 100, reduce to an allowed value
         sec
         sbc #100
         jmp _lnm0
_lnm1    ;fix the negative value like -1 ($ff) to go to 99
         clc
         adc #100
_lnm0    sta LevelNum
         rts
         
;---------------------------------------
;mapStore
;
; Store current map to proper place in memory

mapStore 
         lda $01
         pha
         
         lda #$36
         sta $01
         lda LevelNum
         clc
         adc #>MAP_LEVELS
         sta $fc
         lda #$00
         sta $fb

         ldy #$00
_ms00    lda MAP,y
         sta ($fb),y
         iny
         ;cpy #MAP_SIZE     ;unnecessary
         bne _ms00
         
         pla
         sta $01
         rts

;---------------------------------------
;mapLoad
;
; Move chosen level to map editor from memory

levelRelocate
         lda $01
         pha

         lda #$36
         sta $01
         lda LevelNum
         clc
         adc #>MAP_LEVELS
         sta $fc
         lda #$00
         sta $fb

         ldy #$00
_ml00    lda ($fb),y
         sta MAP,y
         iny
         ;cpy #MAP_SIZE     ;unnecessary
         bne _ml00
         
         inc UpdateMapscreen

         pla
         sta $01
         rts 
         