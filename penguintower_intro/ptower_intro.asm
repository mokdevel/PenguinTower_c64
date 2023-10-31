;-------------------------------------------------
;DEFINES

;RELEASE

!ifndef RELEASE {
DEBUG            ;Enable various debug things
NOMUSIC          ;Does not compile nor play music.
BASICSTART        ;Starts from basic with run. Should be only used for development.
;GOLASTPAGE        ;Show the last text page of text
;LASTSCREEN       ;When working on the last transition
LASTSCREEN_SKIP  ;Do not load the last screen to $c000+
}

;-------------------------------------------------

!source "..\common\macro.asm"
!source "globals.asm"
!source "macro_loadimages.asm"

;-------------------------------------------------
        *= $0340
spr_behind_txt                                  ;0340-03ff - sprite behind text
;SCR04                                          ;0400-07ff - main screen
;                                               ;0800-12ff - data and code
;                                               ;1900-27ff - FREE (for music)
        *= $2800
!media  "font.charsetproject",char,0,256        ;2800-2fff - font
        *= g0                                   ;3000-573f - intro pictures
!media   "gfx_intro_pics.graphicscreen",color
        *= g1
!media   "gfx_intro_pics.graphicscreen",screen
        *= pic
!media   "gfx_intro_pics.graphicscreen",bitmap

buf0     !fill $80                              ;5740-57bf - buffer
;                                               ;57c0-57ff - FREE
;                                               ;5800-7f3f - picture: the frame
        *= $7f40
spr_border !fill $40, SPRITE_PATTERN            ;7f40-7f7f - sprite for border
buf1     !fill $80                              ;7f80-7fff - buffer
;                                               ;8000-bf3f - picture: penguin tower
;                                               ;bf40-bfff - FREE
;                                               ;c000-ef3f - picture: penguin tower+parrots

;-------------------------------------------------

!ifdef BASICSTART {
         *= $0801
         !basic
         jmp introStart
}
;---------------------------------------

         *= $0810
!source "data.asm"
!source "text.asm"

;---------------------------------------
;START
         *= $1070
         
introStart
         lda #$36
         sta $01

         ldx #$00
         stx phase+1
loop1    lda GFX_RAAMI_CLR+$000,x
         sta $d800,x
         lda GFX_RAAMI_CLR+$100,x
         sta $d900,x
         lda GFX_RAAMI_CLR+$200,x
         sta $da00,x
         lda GFX_RAAMI_CLR+$300,x
         sta $db00,x
         lda #$20
         sta $0400,x
         sta $0500,x
         sta $0600,x
         sta $0700,x
         inx
         bne loop1

         ldx #$00
loop4    lda bcol,x
         beq *+7
         lda #$0e
         jmp *+5
         lda #$06
         sta tscr+$d400,x
         sta tscr+$d428,x
         sta tscr+$d450,x
         sta tscr+$d478,x
         sta tscr+$d4a0,x
         sta tscr+$d4c8,x
         inx
         cpx #$28
         bne loop4

         lda #%00111111
         sta $d015
         sta $d017
         sta $d01d

         lda #$b0
         sta $d000
         sta $d006
         clc
         adc #$30
         sta $d002
         sta $d008
         clc
         adc #$10
         sta $d004
         sta $d00a

         lda #$e0
         sta $d001
         sta $d003
         sta $d005
         lda #$0a
         sta $d007
         sta $d009
         sta $d00b

         lda #$00
         sta $d020
         sta $d021

         ldx #$00
loop3    lda #((spr_border-$4000)/$40)
         sta $5ff8,x
         lda #(spr_behind_txt/$40)
         sta $07f8,x
         lda #$00
         sta $d027,x
         inx
         cpx #$06
         bne loop3

         ldx #$00
         lda #SPRITE_PATTERN
loop5    sta spr_behind_txt,x
         inx
         cpx #$40
         bne loop5

         ;store byte at $3fff. This is the one in the border, but as there are gfx in the same spot, we need to store it.
         lda $3fff
         sta d3fff
         lda $7fff
         sta d7fff
         lda #$00
         sta $3fff
         sta $7fff

         ;Fill color fader table
         ldx #$00
loop2    lda col2,x
         asl
         asl
         asl
         asl
         sta col2h,x
         inx
         cpx #$80
         bne loop2

         sei
         lda #<irq
         ldy #>irq
         sta $0314
         sty $0315

         lda #$36           ;Make RAM at $A000 visible.
         sta $01

         ldx #$7f
         stx $dc0d
         ldx #$01
         stx $d01a
         ldx #$1B
         stx $d011
         lda #$ff
         sta $d012
         
         cli
         jmp *

dd021_1  !byte $00

;---------------------------------------
;IRQ code

irq      ;+setd020 7
         +setd020 $0d
         jsr HandleState
         +setd020 $00
         
         lda state
         cmp #STATE_SHOW_PIC
         bcs irq_end    ;no need to open borders for pictures

         ldx #$c0
first    cpx $d012
         bcs first
         lda #$c1
         sta $d007
         sta $d009
         sta $d00b
bcl      lda #$00       ;SMC!
         sta $d021
         ldx #$0a
         dex
         bne *-1
         bit $ea
         lda #$1b
         ldy #$1a       ;$1a = font at $2800
         ldx #$ff
         sta $d011
         stx $dd00
         sty $d018
         lda #$08
         sta $d016
         lda #$ff
         sta $d01b

         +setd020 2

         ;jsr play

         ;open border
         ldx #$f9
         cpx $d012
         bne *-3
         ldx #$13
         stx $d011
         lda #$0a
         sta $d007
         sta $d009
         sta $d00b
         lda #$00
         sta $d01b

         ;+setd020 5

irq_end
         ldx #$fd
         cpx $d012
         bne *-3
         
         lda #$d8
         sta $d016
dd011    lda #$1b         ;SMC
dd018    ldy #$15         ;SMC
ddd00    ldx #$ff         ;SMC
         sta $d011
         stx $dd00
         sty $d018

         +setd020 0

         ;jsr play

         lda irq_d012
         sta $d012
         lda #$01
         sta $d019         
         jmp $ea31

;---------------------------------------

irq_d012  !byte $2f
state     !byte STATE_BCOLON0     ;This is the official start
;state     !byte STATE_SHOW_PIC

STATE_CLTSCR    = $00
STATE_PLOTTEXT  = $01
STATE_TEXTON    = $02
STATE_WAIT      = $03
STATE_TEXTOFF   = $04
STATE_FADEOFF   = $05
STATE_MOVEG0    = $06
STATE_MOVEG1    = $07
STATE_MOVEPIC0  = $08
STATE_MOVEPIC1  = $09
STATE_MOVEPIC2  = $0a
STATE_MOVEPIC3  = $0b
STATE_MOVEPIC4  = $0c
STATE_MOVEPIC5  = $0d
STATE_MOVEPIC6  = $0e
STATE_MOVEPIC7  = $0f
STATE_FADEON    = $10
STATE_BCOLON0   = $11
STATE_BCOLON1   = $12
STATE_VERTON    = $13
STATE_FADEOFF2  = $14
STATE_VERTOFF   = $15
STATE_CLEARPIC  = $16
STATE_BCOLOFF1  = $17
STATE_BCOLOFF0  = $18
STATE_SHOW_PIC  = $19 

  !macro state b1,w2,b3 {
    !byte <b1 ;state ID
    !word w2  ;state jsr
    !byte <b3 ;state $d012
    }

  !align 8,0

states    
         +state STATE_CLTSCR,   cltscr,           $3f
         +state STATE_PLOTTEXT, plottext,         $3f
         +state STATE_TEXTON  , texton,           $3f
         +state STATE_WAIT    , waitloop,         $3f
         +state STATE_TEXTOFF , textoff,          $3f

         +state STATE_FADEOFF , fadeoff,          $08
         +state STATE_MOVEG0  , moveg0,           $3f
         +state STATE_MOVEG1  , moveg1,           $3f
         +state STATE_MOVEPIC0, movepic0,         $3f
         +state STATE_MOVEPIC1, movepic1,         $3f
         +state STATE_MOVEPIC2, movepic1,         $3f
         +state STATE_MOVEPIC3, movepic1,         $3f
         +state STATE_MOVEPIC4, movepic1,         $3f
         +state STATE_MOVEPIC5, movepic1,         $3f
         +state STATE_MOVEPIC6, movepic1,         $3f
         +state STATE_MOVEPIC7, movepic1,         $3f
         +state STATE_FADEON  , fadeon,           $08 ;next: STATE_PLOTTEXT

         +state STATE_BCOLON0 , bcolon0,          $00 ;Official start state
         +state STATE_BCOLON1 , bcolon1,          $00
         +state STATE_VERTON  , verticalbar_on,   $00 ;next: STATE_CLTSCR

         +state STATE_FADEOFF2, fadeoff,          $08 ;once text is done, we enter here.
         +state STATE_CLEARPIC, clear_minipic,    $ff
         +state STATE_VERTOFF , verticalbar_off,  $00
         +state STATE_BCOLOFF0, bcolof1,          $00
         +state STATE_BCOLOFF1, bcolof0,          $00
         +state STATE_SHOW_PIC, showlogo_pt,      $ff

;---------------------------------------
;Select state and run it
;

HandleState
         lda state
         asl
         asl 
         tax
         lda states+0,x          
         ;sta
         lda states+1,x          
         sta whatjsr+1
         lda states+2,x          
         sta whatjsr+2
whatjsr  jsr $0000          ;SMC
         lda state
         asl
         asl 
         tax
         lda states+3,x     ;the next IRQ position is read after whatjsr as the state may have changed inside it
         sta irq_d012
         rts

;---------------------------------------
!source "statecode.asm"
!source "state_picture.asm"
