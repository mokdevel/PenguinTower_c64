;---------------------------------------
;LevelDEPACKer routine
;(c)copyright 1995 Scapegoat/Topaz Beerline
;---------------------------------------
;
; lda #<packed_data_address
; ldy #>packed_data_address
; sta $fb
; sty $fc
; lda #<data_destination
; ldy #>data_destination
; jsr depacker

ENDCHAR = $ff
REPEAT_CTRL = $fe

depacker ;sei
         sta $fd
         sty $fe
         
         lda $01
         pha
         lda #$30
         sta $01
         
loop     ldy #$00
         lda ($fb),y
         cmp #ENDCHAR
         bne flag

         ;all done!
         pla
         sta $01
         ;cli
         rts
         
flag     cmp #REPEAT_CTRL
         beq diffrent ;bne
         jsr getrepeats2
         lda ($fb),y
r2       sta ($fd),y
         jsr add04
         dex
         bne r2
         jsr add2b
         jmp loop
diffrent jsr getrepeats
d2       lda ($fb),y
         sta ($fd),y
         jsr add2b
         jsr add04
         dex
         bne d2
         jmp loop

getrepeats jsr add2b
getrepeats2 lda ($fb),y
         tax
add2b    inc $fb
         bne *+4
         inc $fc
         rts
add04    inc $fd
         bne *+4
         inc $fe
         rts

;Important license text :-)         
!pet "problemchildren have horny minds"         