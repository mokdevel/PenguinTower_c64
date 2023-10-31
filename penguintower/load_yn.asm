;-------------------------------------------------
;Load highscores screen
;
; This is the first screen shown to players.

BASECOLOR = $07
LOAD_YES  = $00
LOAD_NO   = $01

Load_YesNo
         lda #$05
         sta $d020
         sta $d021
         lda #$08
         sta $d016
         lda #D018_FONT
         sta $d018

         lda #BASECOLOR
         jsr clrscreen

         lda #<loadyn_txt0
         ldx #>loadyn_txt0
         sta $fb
         stx $fc
         ldx #$05
         ldy #$04
         jsr printtext

         lda #<loadyn_txt1
         ldx #>loadyn_txt1
         sta $fb
         stx $fc
         ldx #$0b
         ldy #$07
         jsr printtext

_lyn     lda #$00
         cmp $d012
         bne *-3

         jsr blinktext

         ;either joy left
         lda $dc00
         eor $dc01
         and #%00000100         ;left
         beq _lyn1              ;no
         lda #LOAD_YES
         jmp _lyn10

         ;either joy right
_lyn1    lda $dc00
         eor $dc01
         and #%00001000         ;right
         beq _lyn11             ;no
         lda #LOAD_NO
         jmp _lyn10
         
_lyn10   pha
         lda #BASECOLOR
         jsr _bt10
         pla
         sta yes_or_no
         
         ;either fire pressed
_lyn11   lda $dc00
         eor $dc01
         and #%00010000         ;fire pressed
         bne _lyn0              ;yes
         jmp _lyn

         ;exiting
_lyn0    lda yes_or_no
         bne _lyn_end
         jsr highscore_load
_lyn_end rts

yes_or_no !byte LOAD_NO

blinktext
_bt_ctr  ldx #$00             ;SMC
         lda flico,x
_bt10    ldy #$00
_bt00    ldx yes_or_no
         beq _bt02
         sta $d800+7*40+21,y
         sta $d800+8*40+21,y
         jmp _bt01
_bt02    sta $d800+7*40+11,y
         sta $d800+8*40+11,y         
_bt01    iny
         cpy #$06
         bne _bt00
         
         ldx _bt_ctr+1
         inx
         txa
         and #%011111
         sta _bt_ctr+1
         
         rts
         
loadyn_txt0 !scr "load highscores @"
loadyn_txt1 !scr "yes - no @"
         
