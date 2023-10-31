LEVEL_NORMAL_COUNT_TO_PACK = 100
LEVEL_BONUS_COUNT_TO_PACK = 16

level_count_p !byte 0

text_pack1 !pet "packing levels...",$d,"packed to: $ad00-$", 0  ;The $ad00 is same as PACKTO
text_pack2 !pet $d,$d,"saving"
           !pet $d,"-levels:", 0
text_pack3 !pet $d,"-pointers", 0
text_pack4 !pet $d,"ready.", 0

text_ask1  !pet "press",$d
           !pet "1 - normal levels (100)",$d
           !pet "2 - bonus levels (16)",$d
           !pet "return - back", 0

;----------------------------------------------
;packlevels
;
; This will pack levels and save level data and pointers
;
; IN: A=level count to pack
;
; lda #<level count to pack>
; jsr level_count_p

packlevels
         jsr NOIRQ
         jsr clearScreen
         jsr setDefaultScreen         

         jsr $E566        ;cursor to 0,0

         lda #$07
         jsr set_color

         ldx #$0b
         lda #<text_ask1
         ldy #>text_ask1
         jsr print

_pl0     jsr $ffe4
         sta $d020
         beq _pl0
         
         cmp #"1"
         beq _pl01

         cmp #"2"
         beq _pl02
         
         cmp #$0d            ; RETURN
         bne _pl0
         jmp _pl_end

_pl01    lda #LEVEL_NORMAL_COUNT_TO_PACK
         sta level_count_p
         jmp _pl1

_pl02    lda #LEVEL_BONUS_COUNT_TO_PACK
         sta level_count_p
         jmp _pl1

_pl1     jsr $E566        ;cursor to 0,0

         ldx #$0b
         lda #<text_pack1
         ldy #>text_pack1
         jsr print
;         jsr $ab1e

         lda #<PACKFROM     ;Set pointer to Source.Memory
         ldy #>PACKFROM
         sta $02
         sty $03
         lda #<PACKTO       ;Set pointer to Target.Memory
         ldy #>PACKTO
         sta $04
         sty $05
         ldx level_count_p ;levels to pack
         jsr dopack

         lda #$00
         sta $d020
         
         lda $04
         sta pack_end+0
         lda $05
         sta pack_end+1

         lda pack_end+1
         jsr print_number_hex
         lda pack_end+0
         jsr print_number_hex

         ldx #$0b
         lda #<text_pack2
         ldy #>text_pack2
         jsr print
         lda level_count_p
         jsr print_number
         
         ;inc $d020
         ;jmp *-3
         
         jsr SAVE_packed_levels
         
         lda #$37           ;Make ROM at $A000 visible.
         sta $01

         ldx #$0b
         lda #<text_pack3
         ldy #>text_pack3
         jsr print
         jsr SAVE_packed_level_pointers

         ldx #$0b
         lda #<text_pack4
         ldy #>text_pack4
         jsr print

_pl_end
         ldx #14          ;Read 14 values from stack as we came to this routine 'ugly'
_pl00    pla
         dex
         bne _pl00

         jmp _in_end

pack_end  !byte 0,0

;------------------------------------

              ;1234567890123456789
PNAME1   !pet "@0:pt64-pack-levels"
PNAME1_END
PNAME2   !pet "@0:pt64-pack-ptrs"
PNAME2_END

PNAME3   !pet "@0:pt64-bonus-levels"
PNAME3_END
PNAME4   !pet "@0:pt64-bonus-ptrs"
PNAME4_END

;------------------------------------
;Save packed levels

SAVE_packed_levels
         lda level_count_p
         cmp #LEVEL_BONUS_COUNT_TO_PACK
         beq _spl1

         ;set the normal save filename
         lda #(PNAME1_END-PNAME1)   ;filename length
         ldx #<PNAME1
         ldy #>PNAME1
         jmp _spl0

         ;set the bonus save filename
_spl1    lda #(PNAME3_END-PNAME3)   ;filename length
         ldx #<PNAME3
         ldy #>PNAME3
         
_spl0    jsr SAVE_init_byte
         
         lda #<PACKTO       ;Set pointer to Source.Memory
         sta $02
         lda #>PACKTO
         sta $03

         lda pack_end+0
         sta $04
         lda pack_end+1
         sta $05

;         lda #<(PACKTO+100)
;         sta $04
;         lda #>(PACKTO+100)
;         sta $05

         jsr SAVE_file_byte
         rts

;------------------------------------
;Save packed level pointers

SAVE_packed_level_pointers

         ;move pointer data back to back
         ldx #$00
         ldy level_count_p
_spp0    lda lvldata_hi,x
         sta lvldata_lo,y
         iny
         inx
         cpx level_count_p
         bne _spp0

         lda level_count_p
         cmp #LEVEL_BONUS_COUNT_TO_PACK
         beq _spp2
         
         ;set the normal save filename         
         lda #(PNAME2_END-PNAME2)   ;filename length
         ldx #<PNAME2
         ldy #>PNAME2
         jmp _spp1

         ;set the bonus save filename
_spp2    lda #(PNAME4_END-PNAME4)   ;filename length
         ldx #<PNAME4
         ldy #>PNAME4
         
_spp1    jsr SAVE_init_byte

         lda #<lvldata_lo
         sta $02
         lda #>lvldata_lo
         sta $03
         lda #<(lvldata_lo)     ;LOPPU
         clc
         adc level_count_p
         asl
         sta $04
         lda #>(lvldata_lo) 
         sta $05

         jsr SAVE_file_byte
         rts
         