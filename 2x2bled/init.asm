;-------------------------------
;Initialize mapedit screen

Initmapedit
         jsr clearScreen

         ldx #$00
         stx MRETURN
         
         jsr levelRelocate
         
         inc UpdateMapscreen
         rts

;-------------------------------
;Initialize help screen
;
; This is used both by bled and mapedit

Inithelp 
         jsr clearScreen
         rts

;-------------------------------
;Initialize bled screen

Initbled ;sei
         ldx #$00
INILOOP1 lda BLEDSCREEN,x
         sta $0400,x
         lda BLEDSCREEN+$100,x
         sta $0500,x
         lda BLEDSCREEN+$200,x
         sta $0600,x
         lda BLEDSCREEN+$300,x
         sta $0700,x
         lda #$00
         sta $D800,x
         sta $D900,x
         sta $DA00,x
         sta $DB00,x
;         sta $D9D0,x
         inx
         bne INILOOP1

         ;draw the font data colors on screen
         ldx #$00
INILOOP2 ldy BDAT0,x
         lda BCOL0,x
         sta FD8PLC,y
         ldy BDAT1,x
         lda BCOL1,x
         sta FD8PLC,y
         ldy BDAT2,x
         lda BCOL2,x
         sta FD8PLC,y
         ldy BDAT3,x
         lda BCOL3,x
         sta FD8PLC,y
         inx
         bne INILOOP2

         ;color the credits
;         ldx #$00
;INILOOP3 lda #$0b
;         sta $D820,x
;         sta $D848,x
;         sta $D870,x
;         sta $D898,x
;         sta $D8C0,x
;         sta $D8E8,x
;         sta $D910,x
;         sta $D938,x
;         sta $D960,x
;         inx
;         cpx #$07
;         bne INILOOP3

         ldx #%00001111
         stx $d015
         ldx #$01
         stx $d027 ;OUTO SPR
         stx $d028 ;PLOT SPR

         ldx #$80
         stx $028A

         ldx #$B4
         stx $d002
         ldx #$BB
         stx $d003
         ldx #(SPRITE-$40)/$40
         stx $07F9
         ldx #(SPRITE)/$40
         stx $07FA
         stx $07FB
         
         ldx #18            ;Move character cursor on the block line to middle
         stx BLONO+1
         
         ;cli
         rts
