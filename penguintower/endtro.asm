;-------------------------------------------------
;endtro interrupt

ENDTRO_RUN  = 0
ENDTRO_STOP = 1

EndtroIrq 
         ldx #$1b
         stx $d011
         ldx #D018_FONT
         stx $d018
         ldx #$08
         stx $d016

         ;Row#1 of sprites
         lda #$32
         jsr PutYSpr
         lda #$0f
         ldx #$0c
         sta $d021
         jsr PutSprCol

         +setd020 2
         jsr endtro_blink
         +setd020 5
         lda #DOP_INC*0
         ldx #$00
         jsr dopattern
         lda #DOP_INC*3
         ldx #$02
         jsr dopattern
         lda #DOP_INC*6
         ldx #$04
         jsr dopattern
         +setd020 0
         
;         lda #$06
;         sta $d020
         
         lda #$32+21*2*1-4
         cmp $d012
         bne *-3

         ;Row#2 of sprites
         lda #$32+21*2*1
         jsr PutYSpr
         lda #$0c
         ldx #$0b
         sta $d021
         jsr PutSprCol

;         ldx $d012              ;wait for $d012 to be atleast on line $60
;         cpx #$6c
;         bcc *-5
         jsr Music_Play

         lda #$32+21*2*2-4
         cmp $d012
         bne *-3

         ;Row#3 of sprites
         lda #$32+21*2*2
         jsr PutYSpr
         lda #$0b
         ldx #$00
         sta $d021
         jsr PutSprCol

         lda #$32+21*2*3-4
         cmp $d012
         bne *-3

         ;Row#4 of sprites
         lda #$32+21*2*3
         jsr PutYSpr
         lda #$0b
         ldx #$0c
         sta $d021
         jsr PutSprCol

         lda #$32+21*2*4-4
         cmp $d012
         bne *-3

         ;Row#5 of sprites
         lda #$32+21*2*4
         jsr PutYSpr         
         lda #$0c
         ldx #$0f
         sta $d021
         jsr PutSprCol

         jsr Music_Play
         
         ;either fire pressed
         lda $dc00
         eor $dc01
         and #%00010000         ;fire pressed
         beq _ei00              ;no         
         lda #ENDTRO_STOP
         sta endtro_state
_ei00         
         ;was it the last thing to do?
         lda #$00               ;return 0 stay in endtro
         ldx endtro_state
         cpx #ENDTRO_STOP
         bne *+4
         lda #$01               ;return 0 stay in endtro
         rts                    ;endtroirq done

endtro_state  !byte 1

;cols
;flico $40
;vari1 $8
;vari2 $8
;vari3 $12
;vari4 $8

;sin1 

!realign $100,0

pattern   
          !byte %00000000
          !byte %00000010
          !byte %01001000
          !byte %00101001
          !byte %10101010
          !byte %11101010
          !byte %10111011
          !byte %11011111
          !byte %11111111
          !byte %11111111
          
          !byte %11111111
          
          !byte %11111111
          !byte %11111111
          !byte %11011111
          !byte %10111011
          !byte %11101010
          !byte %10101010
          !byte %00101001
          !byte %01001000
          !byte %00000010
          !byte %00000000

          !byte %00000000
          !byte %00000010
          !byte %01001000
          !byte %00101001
          !byte %10101010
          !byte %11101010
          !byte %10111011
          !byte %11011111
          !byte %11111111
          !byte %11111111
          
          !byte %11111111
          
          !byte %11111111
          !byte %11111111
          !byte %11011111
          !byte %10111011
          !byte %11101010
          !byte %10101010
          !byte %00101001
          !byte %01001000
          !byte %00000010
          !byte %00000000

          !byte %00000000
          !byte %00000010
          !byte %01001000
          !byte %00101001
          !byte %10101010
          !byte %11101010
          !byte %10111011
          !byte %11011111
          !byte %11111111
          !byte %11111111
          
          !byte %11111111
          
          !byte %11111111
          !byte %11111111
          !byte %11011111
          !byte %10111011
          !byte %11101010
          !byte %10101010
          !byte %00101001
          !byte %01001000
          !byte %00000010
          !byte %00000000

;-------------------------------------------------
;do pattern
;
; IN: A=sprite column
;     X=sprite number

dopattern
         pha
;         ldy #$00
         lda SPR_POINTERS+0,x
         tay
         sty $02
         iny
         sty $04
         iny
         sty $06
         lda SPR_POINTERS+1,x
         sta $03
         sta $05
         sta $07
         pla
         clc
         adc dop_ctr
         and #%01111111
         tax
         lda sin1,x
         lsr
         lsr
         sta _doptr1+1
         txa
         clc
         adc #DOP_INC
         and #%01111111
         tax
         lda sin1,x
         lsr
         lsr
         sta _doptr2+1
         txa
         clc
         adc #DOP_INC
         and #%01111111
         tax
         lda sin1,x
         lsr
         lsr
         sta _doptr3+1
         
         ldy #21*3-3
         ldx #$00
_dop00   
_doptr1  lda pattern,x    ;SMC!!
         sta ($02),y
_doptr2  lda pattern,x    ;SMC!!
         sta ($04),y
_doptr3  lda pattern,x    ;SMC!!
         sta ($06),y
         inx
         dey
         dey
         dey
;         cpy #21*3
         bpl _dop00

;         ldy #$00
;         ldx #$00
;_dop00   
;_doptr1  lda pattern,x
;         sta ($02),y
;_doptr2  lda pattern,x
;         sta ($04),y
;_doptr3  lda pattern,x
;         sta ($06),y
;         inx
;         iny
;         iny
;         iny
;         cpy #21*3
;         bcc _dop00
         
         lda dop_ctr
         clc
         adc #$01
         and #%01111111
         sta dop_ctr
         rts
         
         
dop_ctr  !byte 0
DOP_INC = 11

;PTR_SPR = SPRITE_ENDTRO*$40

SPR_POINTERS  !word SPRITE_ENDTRO0, SPRITE_ENDTRO1, SPRITE_ENDTRO2

;-------------------------------------------------
;blink text

e_ctr8   !byte 0
e_ctr40  !byte 0

endtro_blink

         lda e_ctr8
         lsr            ;we slow down the blink
         tax
         lda vari2,x
         sta _eb_c1+1
         lda vari1,x
         sta _eb_c2+1
         lda vari4,x
         sta _eb_c3+1

         ldx e_ctr40
         lda flico,x
         sta _eb_c4+1
         txa
         clc
         adc #$08
         and #%11111
         tax
         lda flico,x
         sta _eb_c5+1
         txa
         clc
         adc #$08
         and #%11111
         tax
         lda flico,x
         sta _eb_c6+1

         ldy #$02
_eb00    
_eb_c1   lda #$00
         sta SCRD8+(40*02),y
         sta SCRD8+(40*03),y
_eb_c2   lda #$00
         sta SCRD8+(40*05),y
         sta SCRD8+(40*06),y
_eb_c3   lda #$00
         sta SCRD8+(40*08),y
         sta SCRD8+(40*09),y
_eb_c4   lda #$00
         sta SCRD8+(40*14),y
         sta SCRD8+(40*15),y
_eb_c5   lda #$00
         sta SCRD8+(40*17),y
         sta SCRD8+(40*18),y
_eb_c6   lda #$00
         sta SCRD8+(40*20),y
         sta SCRD8+(40*21),y
         iny
         cpy #$24
         bne _eb00

         ;increase counters
         ldx e_ctr8
         inx
         txa
         and #%1111
         sta e_ctr8

         ldx e_ctr40
         inx
         txa
         and #%11111
         sta e_ctr40

         rts

;-------------------------------------------------
;endtro init

EndtroInit  
         ldx #$00
         stx $d021
         stx $d020
         jsr resetSpr
         ldx #D018_FONT
         stx $d018

         lda #$06
         jsr clrscreen

         ;set sprite attributes
         lda #%01111111
         sta $d015
         sta $d01b
         ;sta $d01c
         sta $d01d
         sta $d017
         
         ldx #(SPRITE_ENDTRO0/$40)
         stx SPRITEPTR+0
         ldx #(SPRITE_ENDTRO1/$40)
         stx SPRITEPTR+1
         ldx #(SPRITE_ENDTRO2/$40)
         stx SPRITEPTR+2
         ldx #(SPRITE_ENDTRO0/$40)
         stx SPRITEPTR+3
         ldx #(SPRITE_ENDTRO1/$40)
         stx SPRITEPTR+4
         ldx #(SPRITE_ENDTRO2/$40)
         stx SPRITEPTR+5
         ldx #(SPRITE_ENDTRO0/$40)
         stx SPRITEPTR+6
;         stx SPRITEPTR+7
         
         lda #$18
         jsr PutXSprWide
         lda #%11100000
         sta $d010         
         
         ;print texts to screen
         lda #<endtro_text
         sta $fb
         lda #>endtro_text
         sta $fc
         
         ldx #06
         ldy #02
         jsr printtext

         ldx #03
         ldy #05
         jsr printtext

         ldx #02
         ldy #08
         jsr printtext

         ldx #06
         ldy #14
         jsr printtext

         ldx #10
         ldy #17
         jsr printtext

         ldx #15
         ldy #20
         jsr printtext

         ldy #MUZ_HOF
         jsr Music_Init

         lda #ENDTRO_RUN
         sta endtro_state
         rts
         
;---------------------------------------
;The texts for endtro

endtro_text  
         !scr "-- well done --@"
         !scr "the penguin tower@"
         !scr "has been destroyed@"
         !scr "now the parrots@"
         !scr "can live in@"
         !scr "peace@"
