;---------------------------------------------------
;Initialize main screen

initmainscreen 
         lda #$00
         sta $d011
         jsr resetSpr

         sta what+1
         jsr f2           ;init info text
         ldx #D018_FONT
         stx $d018

         ;TBD: Animate blocks once

         lda #$00
         jsr clrscreen

         ;fix colors for textlines
l1       lda #$01
         sta textd8+(0*$50),x
         lda #$07
         sta textd8+(1*$50),x
         lda #$03
         sta textd8+(2*$50),x
         lda #$05
         sta textd8+(3*$50),x
         lda #$04
         sta textd8+(4*$50),x
         lda #$02
         sta textd8+(5*$50),x
         lda #$06
         sta textd8+(6*$50),x
         inx
         cpx #$50
         bne l1

         ;draw the penguin tower logo
         ldx #$00
loop3    lda PTLOGO_CHARMAP_PENGUIN,x
         clc
         adc #$80
         sta SCR04+1+(0*40),x
         lda #PTLOGO_D800
         sta SCRD8+1+(0*40),x
         lda PTLOGO_CHARMAP_TOWER,x
         clc
         adc #$80
         sta SCR04+6+(20*40),x
         lda #PTLOGO_D800
         sta SCRD8+6+(20*40),x
         inx
         cpx #4*40
         bne loop3

         ldy #MUZ_MAIN
         jsr Music_Init
         ;ldx #$00       ;ERR what?
         lda #$fc
         cmp $d012
         bne *-3
         rts

;---------------------------------------------------
;The main screen irq

waiter1  !byte 9,10,10,10,10,10,10      ;Delays to make sure the first white line does not flicker

mainirq  ldy mii+1
         lda waiter1,y
         tax
         dex
         bne *-1
         ldx #$01
         stx $d020
         stx $d021
         ldx #$0a
         dex
         bne *-1
         ldx #$00
         stx $d020
         stx $d021
         
         jsr wankwait
         ldx #$cc
         cpx $d012
         bne *-3
         nop
         nop
         nop
         nop
         nop
         ldx #$1c
         stx $d011
         dec $d011
         ldx #$0c
         dex
         bne *-1
         ldx #$01
         stx $d020
         stx $d021
         ldx #$0a
         dex
         bne *-1
         ldx #PTLOGO_D020
         stx $d020
         stx $d021
         ldx #PTLOGO_D022
         stx $d022
         ldx #PTLOGO_D023
         stx $d023
         lda #$18
         sta $d016

         jsr Music_Play
         jsr Main_fixscreen

         ;-- Text wanking routine start
what     lda #$00         ;SMC - text wank state machine ctr
         cmp #$00
         beq wc0
         cmp #$01
         beq wc1
         cmp #$02
         beq wc2
         jmp wc3

wc0      sta wfn+1        ;reset waitfornext counter
         sta wankwait+1
         ;Find the datablock mentioned in the text to print
         ;and save it to datablk+1. The datablock is always
         ;the first character on the page.
         lda textptrnew+0
         sta textptr+1
         sta $fb
         lda textptrnew+1
         sta textptr+2
         sta $fc

         ldy #$00
         lda ($fb),y
         cmp #TEXTWRAP
         bne wc4
         lda #$00             ;info
         sta what+1
         jsr InitText
         jmp what
         
wc4      sta datablk+1
         jsr datablk      ;copy gfx for datablock

         ;ok, find the next page and save it
         jsr printWankText
         lda $fb
         clc
         adc #$01         ;jump over TEXTEOP
         sta textptrnew+0
         lda $fc
         adc #$00
         sta textptrnew+1

         inc textptr+1    ;inc text pointer to jump over datablock
         bne *+5
         inc textptr+2
         inc what+1
         jmp conti

wc1      inc wankwait+1
         lda wankwait+1
         cmp #$60
         bne *+5
         inc what+1
         jsr printWankText
         jmp conti

wc2      
wfn      lda #$00
         dec wfn+1
         bne *+5
         inc what+1
         jmp conti

wc3      dec wankwait+1
         jsr printWankText
         lda wankwait+1
         bne conti
         lda #$00
         sta what+1
         ;-- Text wanking routine end

         ;Continue the main screen routine
         
conti    jsr readjoy
         lda datablk+1
         jsr achk_function

         ldx #$ff
         stx $dc00
         stx $dc01
;         ldx #PTLOGO_D020
;         stx $d020
         ldx #$38
         cpx $d012
         bne *-3
         jsr Music_Play
         rts        ;mainirq done

;---------------------------------------------------
;The joystick routine in Main Screen

readjoy  ldx #$00
         beq nowait
         dex
         stx readjoy+1
         rts

nowait   lda $dc01
         and #%00011111
         cmp #%00011111
         bne jcheck
         lda $dc00
         and #%00011111
         cmp #%00011111
         bne jcheck
         rts

jcheck   ldx #$08        ;herkkyys!
         stx readjoy+1
         lsr
         bcc mainjoy_up
         lsr
         bcc mainjoy_down
         lsr
         lsr
         lsr
         bcc mainjoy_fire
         rts

mainjoy_up ldx mii+1
         dex
         cpx #$ff
         bne *+4
         ldx #$06
         stx mii+1
         rts

mainjoy_down ldx mii+1
         inx
         cpx #$07
         bne *+4
         ldx #$00
         stx mii+1
         rts

mainjoy_fire ldx mii+1
         cpx #$00
         beq f0
         cpx #$01
         beq f1
         cpx #$02
         beq f2
         cpx #$03
         beq f3
         cpx #$04
         beq f4
         cpx #$05
         beq f5
         cpx #$06
         beq f6
         rts

f0       ldx plram
         inx
         txa
         and #%00000011
         bne *+4
         lda #$01
         sta plram
         rts

f1       jmp randomizelvl

f2       lda #$00             ;info
         jmp InitText

f3       lda #$02             ;help
         jmp InitText

f4       lda #$01             ;scoretxt
         jmp InitText

f5       jmp highscore_save   ;we restart inside saveScore

f6       lda #GAME_INIT_JSR
         sta irqjump_idx
         rts

;---------------------------------------------------
;Fix various things on the main screen

Main_fixscreen 
         ldx #$fe
         stx $d015
         ldx #%10000110
         stx $d01c
         lda #$20
         sta $d002
         sta $d006
         sta $d00a
         clc
         adc #$18
         sta $d004
         sta $d008
         sta $d00c
         lda #$55+5
         sta $d003
         sta $d005
         clc
         adc #$10-5
         sta $d007
         sta $d009
         clc
         adc #$10
         sta $d00b
         sta $d00d
         jsr checktrans
         
         ;which text we're currently showing
;         lda wtext      ;mika texti
;         clc
;         adc #$01
;         asl
;         tax
;         lda #$01
;         sta scol+2,x
;         sta scol+3,x
         
         ;Put sprites for players, random, <text>
         ;rest is put in wankwait

         ldx #$00
_ww02    lda sprnos,x
         sta SPRITEPTR+1,x
         lda scol,x
         sta $d027+1,x
         inx
         cpx #$06
         bne _ww02    
         
mii      ldx #$00       ;SMC - this is the 'menu' line that is active
         lda arrplc,x
         sta $d00f
         
         ;arrow wank
arrc     ldx #$40
         ldy #$01
         lda sin,x
         lsr
         lsr
         lsr
         lsr
         clc
         adc #$50
         sta $d00e
         cpy #$01
         beq arad
         dex
         dex
         cpx #$20
         bne *+5
         inc arrc+3
         jmp geton

arad     inx
         inx
         cpx #$50
         bne *+5
         dec arrc+3

geton    stx arrc+1

         ;Define arrowsprite to last sprite
         lda #SPRITE_ARROW
         sta SPRITEPTR+7
         lda #$0d
         sta $d027+7

         ldx #$01
         stx $d025
         ldx #$0b
         stx $d026

         lda #$ff
         sta $dc00
         sta $dc01
         rts

;---------------------------------------------------

checktrans nop
;-- 1/2players
         ldx #SPRITE_EMPTY
         lda plram
         and #%00000001
         beq *+4
         ldx #SPRITEDATA+8
         stx sprnos+0
         ldx #SPRITE_EMPTY
         lda plram
         and #%00000010
         beq *+4
         ldx #SPRITEDATA+8
         stx sprnos+1
         rts

;----------------------------------------
;This will just wait for each wanker line
;and fix its $d016 and multiplex the sprites
;on the left. LOTS OF RASTERTIME WASTED... ;)

sinadd  = 5

wankwait ldy #$00
         lda sin,y
         and #$07
         ora #$d0
         sta $d016
         tya
         clc
         adc #sinadd
         tay
         ldx #$6a
         cpx $d012
         bne *-3
         ldx #$07
         dex
         bne *-1
         lda sin,y
         and #$07
         ora #$d0
         sta $d016
         tya
         clc
         adc #sinadd
         tay
         ldx #$7a
         cpx $d012
         bne *-3
         ldx #$06
         dex
         bne *-1
         nop
         lda sin,y
         and #$07
         ora #$d0
         sta $d016
         tya
         clc
         adc #sinadd
         tay
         lda #$85
         sta $d003
         sta $d005
         clc
         adc #$10
         sta $d007
         sta $d009
         
         ;Put sprites for
         ;-...
         ;-...
         ldx #$00
_ww00    lda sprnos+6,x
         sta SPRITEPTR+1,x
         lda scol+6,x
         sta $d027+1,x
         inx
         cpx #$04
         bne _ww00         
                  
;         ldx sprnos+6
;         stx SPRITEPTR+1
;         ldx sprnos+7
;         stx SPRITEPTR+2
;         ldx sprnos+8
;         stx SPRITEPTR+3
;         ldx sprnos+9
;         stx SPRITEPTR+4
;         ldx Mainsprcol+1
;         stx $d028
;         stx $d029
         ldx #$8a
         cpx $d012
         bne *-3
         ldx #$06
         dex
         bne *-1
         nop
         lda sin,y
         and #$07
         ora #$d0
         sta $d016
         tya
         clc
         adc #sinadd
         tay
         ldx #$80
         stx $d01c
;         ldx Mainsprcol+2
;         stx $d02a
;         stx $d02b
;         ldx Mainsprcol+3
;         stx $d02c
;         stx $d02d
         ldx #$9a
         cpx $d012
         bne *-3
         ldx #$07
         dex
         bne *-1
         lda sin,y
         and #$07
         ora #$d0
         sta $d016
         tya
         clc
         adc #sinadd
         tay
         lda #$a5
         sta $d00b
         sta $d00d
         clc
         adc #$10
         sta $d003
         sta $d005
         
         ;Put sprites for
         ;- ..
         ;- ..
         ldx sprnos+10
         stx SPRITEPTR+5
         ldx sprnos+11
         stx SPRITEPTR+6
         ldx sprnos+12
         stx SPRITEPTR+1
         ldx sprnos+13
         stx SPRITEPTR+2
         ldx scol+10
         stx $d027+5
         ldx scol+11
         stx $d027+6
         ldx scol+12
         stx $d027+1
         ldx scol+13
         stx $d027+2
         
         ldx #$aa
         cpx $d012
         bne *-3
         ldx #$06
         dex
         bne *-1
         nop
         lda sin,y
         and #$07
         ora #$d0
         sta $d016
         tya
         clc
         adc #sinadd
         tay
         ldx #$ba
         cpx $d012
         bne *-3
         ldx #$06
         dex
         bne *-1
         nop
         lda sin,y
         and #$07
         ora #$d0
         sta $d016
         
         rts
