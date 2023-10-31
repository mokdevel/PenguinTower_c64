;-------------------------------------------------
;plasma interrupt

plasmairq ;ldx #$1e
         ;cpx $d012
         ;bne *-3
         ldx #$01
         stx $d019
         ldx #$1b
         stx $d011
         ldx #D018_NEXT
         stx $d018
         ldx #$08
         stx $d016
         ldx col+0
         stx $d021
         jsr setGRspr
         jsr Music_Play
         jsr anplas
         jsr whatGR
         ldx $d012              ;wait for $d012 to be atleast on line $60
         cpx #$60
         bcc *-5
         jsr Music_Play
         ;was it the last thing to do?
         lda whatGR+1
         cmp #$07
         bne *+4
         lda #$00
         rts ;plasmairq done

whatGR   ldx #$00       ;the state machine for getready sprites
         beq iline
         cpx #$01
         beq line1
         cpx #$02
         beq iline
         cpx #$03
         beq line2
         cpx #$04
         beq dosprite
         cpx #$05
         beq waiter
         cpx #$06
         beq dospr2
         ;whatGR+1 = #$07 then ok, done!
         rts

;--- init text lines
iline    ldx #$00
         stx cno
         stx mno
         inc whatGR+1
         rts

;--- do text line1
line1    ldx mno
         lda text1,x
         sta atemp
         lda plcl,x     ;count offset to screen to ($fb) ($fd)
         sec
         sbc #$28
         sta $fb
         lda #>SCR04
         sta $fc
         jsr putmark
         rts

;--- do text line2
line2    ldx mno
         lda text2,x
         sta atemp
         lda plcl,x
         clc
         adc #$40
         sta $fb
         lda #>(SCR04+$200)
         sta $fc
         jsr putmark
         rts

dosprite ldx sprGRy+1   ;sprite sin counter
         inx
         cpx #$20
         bne _ds1
         inc whatGR+1
         dex
_ds1     stx sprGRy+1
         rts

waiter   ldx #$00       ;wait a while
         inx
         cpx #$50
         bne *+5
         inc whatGR+1
         stx waiter+1
         rts

dospr2   ldx sprGRy+1
         dex
         cpx #$ff
         bne _ds2
         inc whatGR+1
         inx
_ds2     stx sprGRy+1
         txa
         lsr
         sta musicvolume
         rts

;set getready sprites on screen
setGRspr ldx #$ff
         stx $d015
         ldx #$00
         stx $d01c
         stx $d017
         stx $d01b
         stx $d01d
         stx $d010
         lda #$90
         sta $d000
         clc
         adc #$20
         sta $d002
         clc
         adc #$20
         sta $d004
         sec
         sbc #$60
         sta $d006
         clc
         adc #$20
         sta $d008
         clc
         adc #$20
         sta $d00a
         clc
         adc #$20
         sta $d00c
         clc
         adc #$20
         sta $d00e
         ldx #$00
         jsr PutSprCol

         ldx #SPR_G
         stx SPRITEPTR+0    ;g
         ldx #SPR_E
         stx SPRITEPTR+1    ;e
         stx SPRITEPTR+4    ;rEady
         ldx #SPR_T
         stx SPRITEPTR+2    ;t
         ldx #SPR_R
         stx SPRITEPTR+3    ;r
         ldx #SPR_A
         stx SPRITEPTR+5    ;a
         ldx #SPR_D
         stx SPRITEPTR+6    ;d
         ldx #SPR_Y
         stx SPRITEPTR+7    ;y

sprGRy   ldx #$00
         lda sinus2,x
         clc
         adc #$1c
         sta $d007
         sta $d009
         sta $d00b
         sta $d00d
         sta $d00f
         eor #$ff
         clc
         adc #$1c
         sta $d001
         sta $d003
         sta $d005
         rts

;---------------------------------------------------
;--- write text on screen ---

putmark  ldx cno
         inc cno
         lda varit,x
         sta atemp1
         lda varit+1,x
         cmp #$ff
         bne _pm10
         ldx #$00
         stx cno
         inc mno
         ldx mno
         cpx #$05
         bne _pm10
         inc whatGR+1
         rts

_pm10    ldy #$00
_pm0     sty atemp2             ;rivilaskuri

         lda $fb                ;fix also $d800 area pointers
         sta $fd
         lda $fc
         clc
         adc #>(SCRD8-SCR04)
         sta $fe

         ldy #$00
_pm1     ldx atemp
         lda kirjain,x
         and cander,y
         beq _pm2
         lda #$10             ;BUG: the plasma screen text character. Currently incorrect one
         sta ($fb),y
         lda atemp1               ;the color
         sta ($fd),y
_pm2     iny
         cpy #$05
         bne _pm1
         inc atemp
         lda $fb
         clc
         adc #$28
         sta $fb
         lda $fc
         adc #$00
         sta $fc
         ldy atemp2
         iny
         cpy #$08
         bne _pm0
         rts

         !byte $80,$40,$20
cander   !byte $10,$08,$04,$02,$01
mno      !byte 0
cno      !byte 0
plcl     !byte $ce,$d4,$da,$e0,$e6

;---------------------------------------------------
;--- animate plasma ---

anplas   ldx #$00
         ldy #$00
ap3      stx atemp

         txa
         asl
         asl
         asl
         clc
         sta ap1+1
         tya
         asl
         asl
         asl
         sta ap2+1
         ldx #$00
ap1      lda ANIMPLASMADATA,x    ;from data...
ap2      sta PLASMAFONT,x        ;...to font
         inx
         cpx #$08
         bne ap1

         ldx atemp
         inx
         cpx #$10
         bne *+4
         ldx #$00
         iny
         cpy #$10
         bne ap3

         ldx anplas+1
         inx
         cpx #$10
         bne *+4
         ldx #$00
         stx anplas+1
         rts

atemp    !byte 0
atemp1   !byte 0
atemp2   !byte 0
atemp3   !byte 0
atemp4   !byte 0
atemp5   !byte 0

;---draw plasma---

makescr  lda #$00
         sta atemp3
         ldx sy+0
         ldy sy+1
         stx atemp1
         sty atemp2
         ldx sx+0
         ldy sx+1
         stx s3+1
         sty s4+1

ms0      nop
s3       ldx #$00
s4       ldy #$00
         stx atemp4
         sty atemp5
         ldx atemp1
         ldy atemp2
         lda #>SCR04
         sta ms1+2
         lda atemp3
         sta ms1+1
         lda sinus,x
         clc
         adc sinus,y
         sta tmp
         ldx #$00
         stx tmp+1

ms5      ldx atemp4
         ldy atemp5
         lda sinus,x
         clc
         adc sinus,y
         clc
         adc tmp
         and #%00001111
ms1      sta SCR04
         lda ms1+1
         clc
         adc #$28
         sta ms1+1
         lda ms1+2
         adc #$00
         sta ms1+2
         lda atemp4
         clc
         adc ael+0
         sta atemp4
         lda atemp5
         clc
         adc ael+1
         sta atemp5
         inc tmp
         inc tmp+1
         ldx tmp+1
         inx
         cpx #$1a
         bne ms5
         lda atemp1
         clc
         adc ay+0
         sta atemp1
         lda atemp2
         clc
         adc ay+1
         sta atemp2
         lda s3+1
         clc
         adc ax+0
         sta s3+1
         lda s4+1
         clc
         adc ax+1
         sta s4+1
         inc atemp3
         lda atemp3
         cmp #$28
         beq *+5
         jmp ms0
         rts

;---------------------------------------------------
; PLASMA EFFECT DATAS

sx       !byte $40,$00
sy       !byte $00,$40
ael      !byte $fa,$03
ax       !byte $03,$02
ay       !byte $02,$03
ex1      !byte $09,$07,$04,$fe
         !byte $02,$01,$00,$08
         !byte $08,$06,$01,$00
         !byte $00,$04,$3d,$01
         !byte $18,$f5,$f6,$fc
         !byte $08,$81,$ea,$ff
ex2      !byte $f0,$09,$02,$fc
         !byte $07,$00,$00,$07
         !byte $00,$05,$01,$03
         !byte $01,$03,$3d,$0f
         !byte $07,$fe,$ff,$fd
         !byte $08,$7e,$00,$01
ey1      !byte $f0,$09,$fa,$03
         !byte $05,$07,$09,$07
         !byte $00,$04,$01,$04
         !byte $00,$02,$3d,$01
         !byte $f5,$11,$0f,$fe
         !byte $0a,$81,$00,$ff
ey2      !byte $f8,$07,$fd,$02
         !byte $03,$00,$00,$08
         !byte $00,$03,$01,$00
         !byte $02,$03,$3d,$02
         !byte $ff,$0a,$07,$01
         !byte $0e,$7f,$00,$13
c1       !byte $05,$05,$06,$09
         !byte $04,$06,$0a,$05,$09,$0c
         !byte $05,$02,$09,$0c,$06,$0a
c2       !byte $08,$04,$0e,$02
         !byte $0a,$0f,$07,$0c,$08,$06
         !byte $0e,$0a,$05,$0f,$04,$0e
col      !byte $0a,$0e
tmp      !byte 0,0,0

varit    !byte $01,$01,$07,$07
         !byte $0d,$0d,$0f,$0f
         !byte $0c,$0c,$0b,$0b
         !byte $ff

         !text "d'arc/topaz/pp"

text1    !byte 0,0,0,0,0 ;text line on screen over plasma
text2    !byte 0,0,0,0,0

charlevel !byte $00,$08,$10,$08,$00     ;char offsets to 'kirjain'
charbonus !byte $18,$20,$28,$30,$38
charfinal !byte $a0,$08,$28,$98,$a0
charnro   !byte $28,$20,$40,$00,$00

kirjain  !byte $18,$18,$18,$18     ;l, $00
         !byte $18,$1b,$1b,$1f
         !byte $00,$1f,$1b,$1f     ;e, $08
         !byte $18,$1b,$1b,$1f
         !byte $1b,$1b,$1b,$1b     ;v, $10
         !byte $1b,$1b,$0e,$04
         !byte $18,$1e,$1b,$1b     ;b, $18
         !byte $1b,$1b,$1b,$1e
         !byte $00,$0e,$1b,$1b     ;o, $20
         !byte $1b,$1b,$1b,$0e
         !byte $00,$1e,$1b,$1b     ;n, $28
         !byte $1b,$1b,$1b,$1b
         !byte $00,$1b,$1b,$1b     ;u, $30
         !byte $1b,$1b,$1b,$0e
         !byte $0e,$1b,$18,$0e     ;s, $38
         !byte $03,$1b,$1b,$0e
         !byte $00,$00,$0c,$0c     ;:, $40
         !byte $00,$0c,$0c,$00
         !byte $0e,$1b,$1b,$1b     ;0, $48
         !byte $1b,$1b,$1b,$0e
         !byte $06,$0e,$06,$06     ;1, $50
         !byte $06,$06,$06,$0f
         !byte $0e,$1b,$03,$0e     ;2, $58
         !byte $18,$1b,$1b,$1f
         !byte $0e,$1b,$03,$0e     ;3, $60
         !byte $03,$1b,$1b,$0e
         !byte $1b,$1b,$1b,$0f     ;4, $68
         !byte $03,$03,$03,$03
         !byte $1e,$1b,$18,$0e     ;5, $70
         !byte $03,$1b,$1b,$0e
         !byte $0e,$1b,$18,$1e     ;6, $78
         !byte $1b,$1b,$1b,$0e
         !byte $1f,$1b,$03,$07     ;7, $80
         !byte $03,$03,$03,$03
         !byte $0e,$1b,$1b,$0e     ;8, $88
         !byte $1b,$1b,$1b,$0e
         !byte $0e,$1b,$1b,$0f     ;9, $90
         !byte $03,$1b,$1b,$0e
         !byte $03,$03,$0f,$1b     ;d, $98
         !byte $1b,$1b,$1b,$0f
         !byte $00,$00,$00,$06     ;space, $a0
         !byte $06,$00,$00,$00
         
;---------------------------------------------------
;SPRITE ON/OFF FADE routines
;
;dofadeoff and dofadeon will return
;        A=$ff fade not done yet
;        A=$00 fade done
;

initfadeon lda #$00       ;do from ff->00
         sta x+1
         jsr AnimSprFade
         rts

initfadeoff lda #$16      ;do from 00->ff
         sta x+1
         jsr AnimSprFade
         rts

dofadeon jsr setfadespr
         ;jsr AnimSprFade
         
         lda #$ff
         ldx x+1
         inx
         stx x+1
         cpx #$16
         bne *+4
         lda #$00
         rts

dofadeoff jsr setfadespr
         ;jsr AnimSprFade

;         +setd020 2
;         ldx #$f1
;         cpx $d012
;         bne *-3
;         jsr fixlowerline
;         +setd020 0         
         
         lda #$ff
         ldx x+1
         dex
         stx x+1
         cpx #$00
         bne *+4
         lda #$00
         rts

;Sets all the sprites on the screen. The screen from top to
;down will be filled with sprites.
;
;note Music_Play2 is called in here!

setfadespr ldx #$00
sfs0     lda #(SPRITE_NEXTLEVEL/64)
         sta SPRITEPTR+0,x
         inx
         cpx #$08
         bne sfs0

         ldx #$00
         jsr PutSprCol
         lda #%11111111
         sta $d01d
         sta $d017
         lda #%01111111
         sta $d015
         lda #$00
         sta $d01c
         lda #$18
         jsr PutXSprWide
         lda #%11100000
         sta $d010

         lda #$32
         jsr PutYSpr

         jsr Music_Play
          
         +setd020 05
         jsr AnimSprFade
         +setd020 00

         ldx #$5a
         cpx $d012
         bne *-3
         lda #$5c
         jsr PutYSpr
         jsr Music_Play
         ldx #$85
         cpx $d012
         bne *-3
         lda #$86
         jsr PutYSpr
         ldx #$af
         cpx $d012
         bne *-3
         lda #$b0
         jsr PutYSpr
         ldx #$d9
         cpx $d012
         bne *-3
         lda #$da
         jsr PutYSpr
         rts

;ot6      jsr animate_block
;         ldx levelcol+0
;         stx $d021
;         ldx levelcol+1
;         stx $d022
;         ldx levelcol+2
;         stx $d023
;         jmp otno

;otno     jsr AnimSprFade               ;do sprite ON/OFF fading plot
;         jsr deccer
;         lda #$1e
;         cmp $d012
;         bne *-3
;         jsr Music_Play2
;         lda #$32
;         jsr PutYSpr
;         jmp $ea81

AnimSprFade ldy #$21               ;do sprite ON/OFF fading plot
x        ldx #$00
as2      lda p1+$00,x
         sta SPRITE_NEXTLEVEL+0,y
         lda p2+$00,x
         sta SPRITE_NEXTLEVEL+1,y
         lda p3+$00,x
         sta SPRITE_NEXTLEVEL+2,y
         inx
         dey
         dey
         dey
         bpl as2
         ldx #$00
         ldy #$3c
as1      lda SPRITE_NEXTLEVEL+0,x
         sta SPRITE_NEXTLEVEL+0,y
         lda SPRITE_NEXTLEVEL+1,x
         sta SPRITE_NEXTLEVEL+1,y
         lda SPRITE_NEXTLEVEL+2,x
         sta SPRITE_NEXTLEVEL+2,y
         inx
         inx
         inx
         dey
         dey
         dey
         cpy #$1e
         bne as1
         rts

p1       !byte $00,$00,$00,$00
         !byte $00,$00,$00,$00
         !byte $00,$00,$00,$00
         !byte $80,$c0,$e0,$f0
         !byte $f8,$fc,$fe,$ff
         !byte $ff,$ff,$ff,$ff
         !byte $ff,$ff,$ff,$ff
         !byte $ff,$ff,$ff,$ff
         !byte $ff,$ff
p2       !byte $00,$00,$00,$00
         !byte $00,$00,$00,$00
         !byte $00,$00,$00,$00
         !byte $00,$00,$00,$00
         !byte $00,$00,$00,$00
         !byte $81,$c3,$ff,$ff
         !byte $ff,$ff,$ff,$ff
         !byte $ff,$ff,$ff,$ff
         !byte $ff,$ff
p3       !byte $00,$00,$00,$00
         !byte $00,$00,$00,$00
         !byte $00,$00,$00,$00
         !byte $01,$03,$07,$0f
         !byte $1f,$3f,$7f,$ff
         !byte $ff,$ff,$ff,$ff
         !byte $ff,$ff,$ff,$ff
         !byte $ff,$ff,$ff,$ff
         !byte $ff,$ff

;---------------------------------------------------
;INIT PLASMA

initplasma lda #$00
         sta $d011
         sta $d020
         sta sprGRy+1
         sta whatGR+1
         sta waiter+1
         lda #D018_NEXT
         sta $d018
         lda #$08
         sta $d016

         lda sat
         and #%00011111
         cmp #24
         bcc *+4
         and #%00001111
         tay
         lda ex1,y
         sta ax+0
         lda ex2,y
         sta ax+1
         lda ey1,y
         sta ay+0
         lda ey2,y
         sta ay+1
         lda sat
         lsr
         lsr
         and #%00001111
         tay
         lda c1,y
         sta col+0
         sta $d021
         lda c2,y
         sta col+1

         ldx #$00
iloop1   lda col+1
         sta $d800,x
         sta $d900,x
         sta $da00,x
         sta $db00,x
         inx
         bne iloop1
         jsr makescr
         ldy #MUZ_PLASMA
         jsr Music_Init
         ldy #$00
         
         ldx level_next
         cpx #LASTLEVEL-1
         beq il4
         
         ldx bonus
         cpx #NO_BONUS
         beq il3
         
il2      lda charbonus,y
         sta text1,y
         lda charlevel,y
         sta text2,y
         iny
         cpy #$05
         bne il2
         jmp iniend

il4      lda charfinal,y
         sta text1,y
         lda charlevel,y
         sta text2,y
         iny
         cpy #$05
         bne il4
         jmp iniend

il3      lda charlevel,y
         sta text1,y
         lda charnro,y
         sta text2,y
         iny
         cpy #$05
         bne il3
         lda level_next
         clc
         adc #$01
         ldx #$00
         stx ky+1
         stx yk+1
hw3      sec
         sbc #10
         bcc hw4
         inc ky+1
         jmp hw3
hw4      clc
         adc #10
         sta yk+1
ky       lda #$00
         asl
         asl
         asl
         clc
         adc #$48
         sta text2+3
yk       lda #$00
         asl
         asl
         asl
         clc
         adc #$48
         sta text2+4
iniend   inc fade
         rts