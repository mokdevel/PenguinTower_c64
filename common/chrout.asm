;------------------------------------
;Print a zero ended string
;
; lda #char
; jsr print_char

print_char
         ldx $0286
         jsr $ea13
         jsr move_cursor
         rts

;------------------------------------
;Print a zero ended string
;
; string !pet "hello world",0
;
; ldx #color
; lda #<string
; ldy #>string
; jsr print

print    sta _p_smc+1
         lda $01
         pha
         lda #$37
         sta $01
         stx $0286      ;set color         
_p_smc   lda #$00
         jsr $ab1e
         
         pla
         sta $01
         rts

;------------------------------------
;Output a 8bit hex number
;
; lda #$number
; jsr print_number_hex
         
print_number_hex
         pha
         lsr
         lsr
         lsr
         lsr
         clc
         adc #$30
         cmp #$3a
         bcc _pn0
         sec
         sbc #$39         ;$a-$f
_pn0     jsr print_char
         ;ldx #0286
         ;jsr $ea13
         ;jsr move_cursor
         pla
         and #%1111
         clc
         adc #$30
         cmp #$3a
         bcc _pn1
         sec
         sbc #$39
_pn1     jsr print_char
         ;ldx #0286
         ;jsr $ea13
         ;jsr move_cursor
         rts
         
;------------------------------------
;Move Cursor

move_cursor
         jmp $e6B6;
         
;------------------------------------
;Set Cursor
; ldx #x-coord
; ldy #y-coord

set_cursor
         sty $d3
         stx $d6        ;TBD: Switch X/Y
         jsr $e56c
         rts

;------------------------------------
;Set Cursor color
; lda #color

set_color
         sta $0286      ;set color
         rts
         
;------------------------------------
;Output Positive Integer in A/X
;
; lda #number
; jsr print_number
         
print_number
         jsr hexToBcd
         pha
         lsr
         lsr
         lsr
         lsr
         clc
         adc #$30
         jsr print_char
         pla
         and #%00001111
         clc
         adc #$30
         jsr print_char
         rts

         ;basic version
;         tax
;         lda #$00       ;A=HI part of 16bit value. We only show upto 255
;         jmp $bdcd

;----------------------------------------------
;Hex to BCD
;in : A hex number ($10 = 16)
;out: X bcd high   (  1)
;     Y bcd low    (  6)
;     A bcd number ( 16)

hexToBcd ldx #$00
         stx ky0+1
         stx yk0+1
hw30     sec
         sbc #10
         bcc hw40
         inc ky0+1
         jmp hw30
hw40     clc
         adc #10
         sta yk0+1
         iny
         iny
ky0      lda #$00
;         clc
;         adc #$30
         sta htbNumb+0
         iny
yk0      lda #$00
;         clc
;         adc #$30
         sta htbNumb+1

         ldx htbNumb+0
         ldy htbNumb+1
         txa 
         asl
         asl
         asl
         asl
         clc
         adc htbNumb+1
         rts

htbNumb !byte 0,0
