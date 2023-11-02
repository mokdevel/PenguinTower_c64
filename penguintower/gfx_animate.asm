;----------------------------------------------
;Checks if block needs to be animated (queries etc...)
;
;IN:  A=block to check

achk_function 
         ldx #$00
         cmp xanwh,x
         beq _achk2
         inx
         cpx #(xasl-xash)       ;Amount of animations. 
         bne achk_function+2
;         cmp #$a3
;         beq achk2-2
;         rts
;         ldx #$02
         rts

_achk2   dec xanti,x
         bpl _achk3
         lda xantb,x
         sta xanti,x
         jmp _aitb0
_achk3   rts

xash     !byte >xky,>xhe,>xhe,>xbo,>xfi,>xice,>xfla,>xbom,>xybo
xasl     !byte <xky,<xhe,<xhe,<xbo,<xfi,<xice,<xfla,<xbom,<xybo
xanco    !byte $00,$00,$02,$00,$00,$00,$00,$00,$00    ;animation counter
xancb    !byte $14,$04,$04,$03,$10,$10,$08,$08,$18    ;length of animation

xanwh    !byte BLOCK_WQUERY, BLOCK_WHEART, BLOCK_YHEART, BLOCK_BONUSLVL, BLOCK_FIRE, BLOCK_ICECUBE, BLOCK_LIGHTNING, BLOCK_WBOMB, BLOCK_BOMB ;animation target block
xanti    !byte $00,$00,$01,$00,$00,$01,$02,$03,$02    ;animation timer
xantb    !byte $03,$04,$05,$04,$01,$04,$04,$04,$06*2   ;speed - animation timer default value 

xky      !byte $06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e    ;question mark animation
         !byte $0f,$10,$10,$0f,$0e,$0d,$0c,$0b,$0a
         !byte $09,$08,$07,$06
xhe      !byte $03,$04,$05,$04                        ;heart animation
xbo      !byte $00,$01,$02                            ;bonus animation
xfi      !byte $11,$12,$13,$14,$14,$15,$15,$15        ;fire animation
         !byte $15,$15,$15,$14,$14,$13,$12,$11
xice     !byte $16,$16,$16,$16,$16,$16,$16,$16        ;iceblock animation
         !byte $16,$16,$16,$17,$18,$19,$1a,$1b    
xfla     !byte $1c,$1c,$1d,$1c,$1d,$1e,$1d,$1e        ;flash animation
xbom     !byte $1f,$20,$21,$22,$21,$1f,$21,$20        ;white bomb
xybo     !byte $23,$23,$23,$23,$23,$23,$23,$23        ;yellow bomb
         !byte $23,$23,$23,$23,$23,$23,$24,$25        ;yellow bomb
         !byte $26,$27,$27,$27,$27,$26,$25,$24

;----------------------------------------------
;Animate blocks (queries etc...)
;
; This will animate all blocks
;
; TBD: Create an animate_block_reset function to set the default timer values for xanti.
;
animate_block 
         ldx #$00
_ab00    dec xanti,x
         bpl nextan
         jsr aitb

nextan   inx
         cpx #(xasl-xash)       ;Amount of animations. 
         bne _ab00
         rts

;Animate a certain block found in xanwh. X=index to table
aitb     lda xantb,x            ;Anim
         sta xanti,x
         
         ;If we have passed line $b0, save cycles and don't animate block
         lda $d012
         cmp #$b0
         bcc _aitb0
         rts
         
_aitb0   lda #$00
         sta xs0+2
         ldy xanwh,x
         lda bdat0,y    ;take charnumber*8+>fdat
         pha
         asl
         asl
         asl
         sta $02
         pla
         lsr
         lsr
         lsr
         lsr
         lsr
         clc
         adc #>GAMEBMPDATA
         sta $03

         lda bdat1,y
         pha
         asl
         asl
         asl
         sta $04
         pla
         lsr
         lsr
         lsr
         lsr
         lsr
         clc
         adc #>GAMEBMPDATA
         sta $05
         
         lda bdat2,y
         pha
         asl
         asl
         asl
         sta $fb
         pla
         lsr
         lsr
         lsr
         lsr
         lsr
         clc
         adc #>GAMEBMPDATA
         sta $fc
         
         lda bdat3,y
         pha
         asl
         asl
         asl
         sta $fd
         pla
         lsr
         lsr
         lsr
         lsr
         lsr
         clc
         adc #>GAMEBMPDATA
         sta $fe
         
         ;source address for animation data
         lda xash,x
         sta abc1+2
         lda xasl,x
         sta abc1+1
         
         lda xancb,x
         sta abc+1
         ldy xanco,x
         iny
abc      cpy #$00
         bne *+4
         ldy #$00
         tya
         sta xanco,x
abc1     lda $ff00,y
         pha
         asl
         asl
         asl
         asl
         asl
         sta xs0+1
         clc
         adc #$08
         sta xs1+1
         ;clc       ;should never pass the page boundary
         adc #$08
         sta xs2+1
         ;clc
         adc #$08
         sta xs3+1         
         pla
         lsr
         lsr
         lsr
         clc
         adc #>BLOCKANIMDATA
         sta xs0+2
         sta xs1+2
         sta xs2+2
         sta xs3+2
         
         ldy #$00
xs0      lda $ff00,y
         sta ($02),y
xs1      lda $ff00,y
         sta ($04),y
xs2      lda $ff00,y
         sta ($fb),y
xs3      lda $ff00,y
         sta ($fd),y
         iny
         cpy #$08
         bne xs0
         rts
