;---------------------------------------
bcolon0
         ldx bcolctr

         lda bacol,x
         sta $d020
         sta $d021
         sta bcl+1
         sta $d027
         sta $d028
         sta $d029
         sta $d02a
         sta $d02b
         sta $d02c
         sta $d02d
         sta $d02e

         lda bacol1,x
         sta dd021_1
         inx
         cpx #$13
         bne ebcolon
         
         ;set screen data correctly
         lda #$3b
         sta dd011+1
         lda #GFX_RAAMI_d018        ;$7c
         sta dd018+1
         lda #GFX_RAAMI_dd00        ;$fe
         sta ddd00+1

         inc state
ebcolon  stx bcolctr
         rts

;---------------------------------------
bcolon1
         ldx bcolctr

         lda bacol,x
         sta $d020
         sta $d021
         sta bcl+1
         sta $d027
         sta $d028
         sta $d029
         sta $d02a
         sta $d02b
         sta $d02c
         sta $d02d
         sta $d02e

         lda #$3f
         cmp $d012
         bne *-3
         lda #$00
         sta $d021

         lda bacol1,x
         sta dd021_1
         inx
         cpx #$26
         bne ebcolon1
         inc state
ebcolon1 stx bcolctr
         rts

;---------------------------------------
bcolof0
         ldx bcolctr

         lda bacol,x
         sta $d020
         sta $d021
         sta bcl+1
         sta $d027
         sta $d028
         sta $d029
         sta $d02a
         sta $d02b
         sta $d02c
         sta $d02d
         sta $d02e
         sta dd021_1

;         lda bacol1,x
;         sta dd021_1
         dex
         cpx #$ff
         bne ebcolof
         
         inc state
ebcolof  stx bcolctr
         rts

;---------------------------------------
;Color fader off
;
; This is called just one frame to hide the screen and sprites

bcolof1
         ldx #$14
         stx bcolctr

         lda bacol,x
         sta $d020
         sta $d021
         sta bcl+1
         sta $d027
         sta $d028
         sta $d029
         sta $d02a
         sta $d02b
         sta $d02c
         sta $d02d
         sta $d02e
         sta dd021_1

         ;hide screen
         lda #$1b
         sta dd011+1
         lda #$15
         sta dd018+1
         lda #$ff
         sta ddd00+1
         lda #$00
         sta $d015

         inc state
         rts

;---------------------------------------
;Create the vertical bar to screen

verticalbar_on   
         ldx vertctr
         lda vertcol,x
         sta $d027
         sta $d028
         sta $d029
         sta $d02a
         sta $d02b
         sta $d02c
         sta $d02d
         sta $d02e
         ldy #$00
von1     sta $d813,y
         sta $d813+(1*40),y
         sta $d813+(2*40),y
         sta $d813+(3*40),y
         sta $d813+(4*40),y
         sta $d813+(5*40),y
         sta $d813+(6*40),y
         sta $d813+(7*40),y
         sta $d813+(8*40),y
         sta $d813+(9*40),y
         sta $d813+(10*40),y
         sta $d813+(11*40),y
         sta $d813+(12*40),y
         sta $d813+(13*40),y
         sta $d813+(14*40),y
         sta $d813+(15*40),y
         sta $d813+(16*40),y
         sta $d813+(17*40),y
         iny
         cpy #$0e
         bne von1

         lda #$3f
         cmp $d012
         bne *-3
         lda dd021_1
         sta $d021
         
         inx
         cpx #$0f
         bne *+7
         lda #STATE_CLTSCR
         sta state
         stx vertctr
         rts

;---------------------------------------
;Remove the vertical bar from screen

verticalbar_off
         ldx vertctr          ;when entering here 1st time, verton has put the value to $0f
         lda vertcol,x
         sta $d027
         sta $d028
         sta $d029
         sta $d02a
         sta $d02b
         sta $d02c
         sta $d02d
         sta $d02e
         ldy #$00
_vof1    sta $d813,y
         sta $d813+(1*40),y
         sta $d813+(2*40),y
         sta $d813+(3*40),y
         sta $d813+(4*40),y
         sta $d813+(5*40),y
         sta $d813+(6*40),y
         sta $d813+(7*40),y
         sta $d813+(8*40),y
         sta $d813+(9*40),y
         sta $d813+(10*40),y
         sta $d813+(11*40),y
         sta $d813+(12*40),y
         sta $d813+(13*40),y
         sta $d813+(14*40),y
         sta $d813+(15*40),y
         sta $d813+(16*40),y
         sta $d813+(17*40),y
         iny
         cpy #$0e
         bne _vof1
         
         lda #$3f
         cmp $d012
         bne *-3
         lda dd021_1
         sta $d021

         dex
         cpx #$ff
         bne _vof0
         inc state
_vof0    stx vertctr
         
;         dec bcolctr
         rts

;---------------------------------------
waitloop 
         ldx dd021_1
         stx $d021

         ldx waitctr
         inx
         cpx #$c0
         bne *+7
         ldx #$00
         inc state
         stx waitctr
         rts
;-
cltscr
         ldx dd021_1
         stx $d021

         ldx #$00
_cs0     lda #$20
         sta tscr,x
         inx
         cpx #6*40
         bne _cs0
         inc state
         rts

;-
texton
         ldx dd021_1
         stx $d021

         jsr puttcol
         ldx cphase+1
         inx
         cpx #$08
         bne *+7
         inc state
         ldx #$07
         stx cphase+1
         rts
;-
textoff
         ldx dd021_1
         stx $d021
         
         jsr puttcol
         ldx cphase+1
         dex
         cpx #$ff
         bne _to0
         ldx #STATE_CLTSCR
         stx state
         ldx #$00
_to0     stx cphase+1
         rts

;---------------------------------------

puttcol  ldx #$00
         lda bcol,x
         clc
cphase   adc #$00
         tay
         lda vipecol,y
         sta $d400+tscr,x
         sta $d428+tscr,x
         sta $d450+tscr,x
         sta $d478+tscr,x
         sta $d4a0+tscr,x
         sta $d4c8+tscr,x
         inx
         cpx #$28
         bne puttcol+2
         rts

;---------------------------------------

imgnum   !byte $02
         
moveg0   
         ldx dd021_1
         stx $d021

         lda imgnum
         asl
         tax
         lda picoff+0,x
         sta $fb
         lda picoff+1,x
         clc
         adc #(g0/$0100)
         sta $fc
         lda #<buf0
         sta $fd
         lda #>buf0
         sta $fe

         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop         
         inc state
         rts

moveg1   
         ldx dd021_1
         stx $d021
         
         lda imgnum
         asl
         tax
         lda picoff+0,x
         sta $fb
         lda picoff+1,x
         clc
         adc #(g1/$0100)
         sta $fc
         lda #<buf1
         sta $fd
         lda #>buf1
         sta $fe

         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         jsr tloop
         inc state
         rts

tloop    ldy #$00
_tl0     lda ($fb),y
         sta ($fd),y
         iny
         cpy #ll
         bne _tl0

         lda $fb
         clc
         adc #$28
         sta $fb
         lda $fc
         adc #$00
         sta $fc
         lda $fd
         clc
         adc #ll
         sta $fd
         lda $fe
         adc #$00
         sta $fe
         rts

;---------------------------------------

movepic0 
         ldx dd021_1
         stx $d021
         
         lda imgnum
         asl
         tax
         lda dataoff+0,x
         sta $fb
         lda dataoff+1,x
         clc
         adc #(pic/$0100)
         sta $fc

         lda #<d1
         sta $fd
         lda #>d1
         sta $fe
movepic1
         ldx dd021_1
         stx $d021
         
         lda d3fff
         sta $3fff        
         lda d7fff
         sta $7fff        

         jsr domove
;         jsr domove
;         jsr domove
;         jsr domove

         lda #$00
         sta $3fff        
         sta $7fff

         inc state
         rts

domove   
         ldy #$00
_dm0     lda ($fb),y
         sta ($fd),y
         iny
         lda ($fb),y
         sta ($fd),y
         iny         
         lda ($fb),y
         sta ($fd),y
         iny         
         lda ($fb),y
         sta ($fd),y
         iny         
         lda ($fb),y
         sta ($fd),y
         iny         
         lda ($fb),y
         sta ($fd),y
         iny         
         lda ($fb),y
         sta ($fd),y
         iny         
         lda ($fb),y
         sta ($fd),y
         iny         
         cpy #8*ll
         bne _dm0

         lda $fb
         clc
         adc #$40
         sta $fb
         lda $fc
         adc #$01
         sta $fc
         lda $fd
         clc
         adc #$40
         sta $fd
         lda $fe
         adc #$01
         sta $fe

         rts


;---------------------------------------
;Clears the are where we had the story mini picture
;This is needed for the screen fade off 

clear_minipic
         lda #<d1
         sta $fd
         lda #>d1
         sta $fe
         ldx #$00
_cm01    jsr clear_minipic_do
         inx
         cpx #$08
         bne _cm01
         inc state
         rts

clear_minipic_do
         lda #$aa
         ldy #$00
_cm00    sta ($fd),y
         iny
         sta ($fd),y
         iny
         sta ($fd),y
         iny
         sta ($fd),y
         iny
         sta ($fd),y
         iny
         sta ($fd),y
         iny
         sta ($fd),y
         iny
         sta ($fd),y
         iny         
         cpy #8*ll
         bne _cm00

         lda $fd
         clc
         adc #$40
         sta $fd
         lda $fe
         adc #$01
         sta $fe
         rts

;---------------------------------------
fadeon
         lda #<c0
         sta $fb
         lda #>c0
         sta $fc
         lda #<c1
         sta $fd
         lda #>c1
         sta $fe

         lda #ll*0
         jsr dofade
         lda #ll*1
         jsr dofade
         lda #ll*2
         jsr dofade
          lda dd021_1
          sta $d021
         lda #ll*3
         jsr dofade
         lda #ll*4
         jsr dofade
         lda #ll*5
         jsr dofade
         lda #ll*6
         jsr dofade
         lda #ll*7
         jsr dofade

         lda #STATE_PLOTTEXT
         ldx phase+1
         inx
         cpx #$08
         bne _fon00
         ldx #$07
         sta state
_fon00   stx phase+1
         rts
         
;---------------------------------------
fadeoff
         lda #<c0
         sta $fb
         lda #>c0
         sta $fc
         lda #<c1
         sta $fd
         lda #>c1
         sta $fe

         lda #ll*0
         jsr dofade
         lda #ll*1
         jsr dofade
         lda #ll*2
         jsr dofade
          lda dd021_1
          sta $d021         
         lda #ll*3
         jsr dofade
         lda #ll*4
         jsr dofade
         lda #ll*5
         jsr dofade
         lda #ll*6
         jsr dofade
         lda #ll*7
         jsr dofade

         ldx phase+1
         dex
         cpx #$ff
         bne _fof00
         inc state
         ldx #$00
_fof00   stx phase+1
         rts

;---

TMPZP = $37

dofade
         tay
         clc
         adc #ll
         sta comp+1
         
phase    ldx #$00
         stx _nl0_smc+1
         stx _nl1_smc+1
         stx _nl2_smc+1
newline  lda buf0,y
         and #%00001111
         asl              ;multiply with 8 to point to correct place in col2
         asl
         asl
         tax
_nl0_smc lda col2,x       ;SMC
         sta ($fb),y
         
         lda buf1,y
         pha
         and #%00001111
         asl
         asl
         asl
         tax
_nl1_smc lda col2,x       ;SMC  
         sta TMPZP
         pla
         and #%11110000
         lsr
         tax
_nl2_smc lda col2h,x      ;SMC
         ora TMPZP
         sta ($fd),y
         iny
comp     cpy #0           ;SMC
         bne newline

         lda $fb
         clc
         adc #40-ll
         sta $fb
         lda $fc
         adc #$00
         sta $fc
         lda $fd
         clc
         adc #40-ll
         sta $fd
         lda $fe
         adc #$00
         sta $fe

         rts

