;---------------------------------------------------------
;Print text on the main screen depending on the wanker stuff
;After calling this function ($fb) will include the pointer
;to the next page

added   = 11     ;offset ?
textptrnew !byte 0,0    ;Text pointer for the next page.
textptr    !byte 0,0,0  ;Text pointer. First byte used for wanktemp (old code you know)
wanktemp = textptr

printWankText ldy wankwait+1
;         dec $d020
         sty wanktemp
         lda textptr+1
         sta $fb
         lda textptr+2
         sta $fc

         lda sin,y      ;Fix x-offset for the wanker
         lsr
         lsr
         lsr
         clc
         adc #added
         tax
         lda l1+1
         sta textd8-1+(0*$28),x
         sta textd8-1+(1*$28),x
         sta textd8+2+(0*$28),x
         sta textd8+2+(1*$28),x
         lda dc0+0
         sta textd8+0+(0*$28),x
         lda dc0+1
         sta textd8+1+(0*$28),x
         lda dc0+2
         sta textd8+0+(1*$28),x
         lda dc0+3
         sta textd8+1+(1*$28),x
EMPTYCHAR = $00
         lda #EMPTYCHAR         ;Fix the leftedge for printtext
         sta scr-1+(40*0),x
         sta scr-1+(40*1),x
         lda sin+(sinadd*1),y
         lsr
         lsr
         lsr
         tax
         lda #EMPTYCHAR
         sta scr+added-1+(40*2),x
         sta scr+added-1+(40*3),x
         lda sin+(sinadd*2),y
         lsr
         lsr
         lsr
         tax
         lda #EMPTYCHAR
         sta scr+added-1+(40*4),x
         sta scr+added-1+(40*5),x
         lda sin+(sinadd*3),y
         lsr
         lsr
         lsr
         tax
         lda #EMPTYCHAR
         sta scr+added-1+(40*6),x
         sta scr+added-1+(40*7),x
         lda sin+(sinadd*4),y
         lsr
         lsr
         lsr
         tax
         lda #EMPTYCHAR
         sta scr+added-1+(40*8),x
         sta scr+added-1+(40*9),x
         lda sin+(sinadd*5),y
         lsr
         lsr
         lsr
         tax
         lda #EMPTYCHAR
         sta scr+added-1+(40*10),x
         sta scr+added-1+(40*11),x
         lda sin+(sinadd*6),y
         lsr
         lsr
         lsr
         tax
         lda #EMPTYCHAR
         sta scr+added-1+(40*12),x
         sta scr+added-1+(40*13),x

         lda #$00
         sta _lineno+1
_lineno  ldy #$00
         ldx wanktemp   ;fix x offset to screen
         lda sin,x
         beq _done      ;When sinvalue=0, whole line has been printed
         lsr
         lsr
         lsr
         clc
         adc #added
         tax
         tya            ;fix y offset to screen
         asl            ;*2
         clc
         adc #$05       ;+offset on screen
         tay
         jsr printtext  ;print it

         lda wanktemp   ;fix wankcounter
         clc
         adc #sinadd
         sta wanktemp
         inc _lineno+1  ;next line

         ldy #$00       ;was this the last line on this page?
         lda ($fb),y
         cmp #TEXTEOP
         bne _lineno    ;nope, print next line

         ;Fix left side of the screen as
         ;characters seem to bleed to right side.
         ;TBD: The fix below is stupid

_done    lda #EMPTYCHAR
         sta scr+(40*0)
         sta scr+(40*1)
         sta scr+(40*2)
         sta scr+(40*3)
         sta scr+(40*4)
         sta scr+(40*5)
         sta scr+(40*6)
         sta scr+(40*7)
         sta scr+(40*8)
         sta scr+(40*9)
         sta scr+(40*10)
         sta scr+(40*11)
         sta scr+(40*12)
         sta scr+(40*13)
         sta scr+(40*14)
;         inc $d020
         rts

;----------------------------------------------
;Print text to screen x,y from ($fb)
;
; IN: Y=yplace (line on the screen)
;     X=xplace (offset on the line on the screen)
;     ($fb)=textoffset
;
;       After calling this function ($fb) will include the pointer for the next line
;
;       font character order
;        pt0 pt1
;        pt2 pt3
;
; TBD: There is some bug that prints one char too much on the last column. Dirty fix above.

printtext
         lda $fd                ;$fd to be returned untouched
         pha
         
         stx $fd
         ldx ylo,y
         stx pt0+1
         stx pt1+1
         lda yhi04,y
         sta pt0+2
         sta pt1+2
         ldx ylo+1,y
         stx pt2+1
         stx pt3+1
         lda yhi04+1,y
         sta pt2+2
         sta pt3+2

         ldy #$00               ;reset textoffset
         sty textoff+1
         ldx $fd                ;get text offset on screen
textoff  ldy #$00
         inc textoff+1
         lda ($fb),y            ;0=end of text
         beq EOT
         tay
         cpy #$20               ;was the char space? Print only 1x2 char
         beq pt5
         lda fontdat+$00,y
pt0      sta $ff00,x
         lda fontdat+$80,y
pt2      sta $ff00,x
         inx
pt5      lda fontdat+$40,y
pt1      sta $ff00,x
         lda fontdat+$c0,y
pt3      sta $ff00,x
         inx
         cpx #$28
         bcc textoff

pt4      ldy textoff+1          ;search for the end of line
         inc textoff+1
         lda ($fb),y
         bne pt4                ;0=end of text

EOT      lda $fb                ;move text pointer with textoff + 1
         clc
         adc textoff+1
         sta $fb
         lda $fc
         adc #$00
         sta $fc
         
         pla
         sta $fd
         rts

ylo      !byte $00,$28,$50,$78,$a0,$c8
         !byte $f0,$18,$40,$68,$90,$b8
         !byte $e0,$08,$30,$58,$80,$a8
         !byte $d0,$f8,$20,$48,$70,$98
yhi04    !byte $04,$04,$04,$04,$04,$04
         !byte $04,$05,$05,$05,$05,$05
         !byte $05,$06,$06,$06,$06,$06
         !byte $06,$06,$07,$07,$07,$07

;---------------------------------------------------
;Copy the block mentioned in text to FONTBMPDATA
;in character '%'.

datablk  ldx #$00             ;!!SMC
         cpx #TEXTNOGFX
         bne db3
         lda l1+1
         sta dc0+0
         sta dc0+1
         sta dc0+2
         sta dc0+3
         rts

dc0      !byte 0,0,0,0

db3      lda bcol0,x
         sta dc0+0
         lda bcol1,x
         sta dc0+1
         lda bcol2,x
         sta dc0+2
         lda bcol3,x
         sta dc0+3
         ldx datablk+1
         ldy bdat0,x
         lda #$00
         jsr db0
         ldx datablk+1
         ldy bdat1,x
         lda #$08
         jsr db0
         ldx datablk+1
         ldy bdat2,x
         lda #$10
         jsr db0
         ldx datablk+1
         ldy bdat3,x
         lda #$18
         jsr db0
         rts

db0      ldx #$00
         sta db2+1
         sty db1+1
         stx db1+2
         asl db1+1
         rol db1+2
         asl db1+1
         rol db1+2
         asl db1+1
         rol db1+2
         lda db1+2
         clc
         adc #>GAMEBMPDATA
         sta db1+2
         ldx #$00
db2      ldy #$00
db1      lda $ff00,x
         sta PERCENTCHAR,y
         iny
         inx
         cpx #$08
         bne db1
         rts

