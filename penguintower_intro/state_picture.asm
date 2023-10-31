;---------------------------------------
;Show the Penguin Tower logo

showlogo_pt
         lda #$00
         sta $d015

         dec picture_ctr
         bne _slp_end
                  
         ldx picture_ctr2
         lda picture_timer,x
         cmp #$ff
         beq _slp_end
         sta picture_ctr
         inc picture_ctr2

         lda picture_flip
         eor #%01
         sta picture_flip         
         bne _slp_00
         jsr initpic_penguintower_parrots
         jmp showpic_penguintower_parrots

_slp_00  jsr initpic_penguintower
         jmp showpic_penguintower

_slp_end  rts

picture_ctr   !byte $01
picture_ctr2  !byte $00
picture_flip  !byte $00
picture_timer !byte $fe,$2,$2,$2,$4,$4,$4,$8,$8,$8,$8,$8,$ff

;-------------------------------------------------
;Show the picture: Penguin Tower

initpic_penguintower
         +setd020 5
         ldx #$00
_sbl0    lda GFX_2_CLR,x
         sta $d800,x
         inx 
         bne _sbl0
         
_sb11    lda GFX_2_CLR+$100,x
         sta $d900,x
         lda GFX_2_CLR+$200,x
         sta $da00,x
         lda GFX_2_CLR+$300,x
         sta $db00,x
         inx
         bne _sb11
         +setd020 0
         rts

showpic_penguintower
         ;set screen data correctly
         lda #$3b
         sta dd011+1
         lda #GFX_2_d018        ;(($0400/$400)<<4 + ($2000/$0400))
         sta dd018+1
         lda #GFX_2_dd00
         sta ddd00+1
         rts
         
;-------------------------------------------------
;Show the picture: Penguin Tower+Parrots

initpic_penguintower_parrots
         +setd020 5
         ldx #$00
_spl0    lda GFX_3_CLR,x
         sta $d800,x
         inx 
         bne _spl0
         
_sp11    lda GFX_3_CLR+$100,x
         sta $d900,x
         lda GFX_3_CLR+$200,x
         sta $da00,x
         lda GFX_3_CLR+$300,x
         sta $db00,x
         inx
         bne _sp11
         +setd020 0
         rts

showpic_penguintower_parrots         
         ;set screen data correctly
         lda #$3b
         sta dd011+1
         lda #GFX_3_d018
         sta dd018+1
         lda #GFX_3_dd00
         sta ddd00+1

         rts         
         