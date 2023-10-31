
START    sei
         lda #<IRQ
         ldy #>IRQ
         sta $0314
         sty $0315

         ldx #$7F
         stx $DC0D
         ldx #$01
         stx $d01A
         ldx #$1B
         stx $d011
         
         lda #$36           ;Make RAM at $A000 visible.
         sta $01
         
         ldx #$00
         stx keypress
         
         cli
         jmp *
         
;_4ever   lda s_irq
;         cmp #S_IRQ_MAPEDIT
;         bne _4ever
;         jsr mapedit4everloop
;         jmp _4ever

error     ;this is a piece of code that should never be executed.
         inc $d020
         jmp error

;-----------------------------
;IRQ states

s_irq    !byte S_IRQ_HELP_EDITOR

S_IRQ_BLED          = 1
S_IRQ_HELP_EDITOR   = 2
S_IRQ_MAPEDIT       = 3
S_IRQ_HELP_MAPEDIT  = 4

;-----------------------------
IRQ      lda s_irq

         cmp #S_IRQ_HELP_EDITOR
         bne _i0
         jsr IRQ_HELP_EDITOR
         ldx #$80
         jmp end_irq
         
_i0      cmp #S_IRQ_BLED
         bne _i1
         jsr IRQ_BLED
         ldx #$80
         jmp end_irq
         
_i1      cmp #S_IRQ_HELP_MAPEDIT
         bne _i2
         jsr IRQ_HELP_MAPEDIT
         ldx #$80
         jmp end_irq

_i2      cmp #S_IRQ_MAPEDIT
         bne _i3
         jsr IRQ_MAPEDIT
         ldx #$c0
         jmp end_irq

_i3      jmp error

         ;end irq - does the final things needed and reads keypress
end_irq  stx $d012
         ldx #$01
         stx $d019
;         asl $d019
         jsr $ffe4
         sta keypress

;         ldx #$80
;         stx $d012
         jmp $ea31

;------------------------------------------------------         
;IRQ for the mapeditor

IRQ_MAPEDIT
         jsr MAPIRQ
         rts

;------------------------------------------------------         
;IRQ for editor help screen         
         
IRQ_HELP_EDITOR
         ldx #HELP_EDITOR_D018
         stx $d018
         ldx #$0F
         stx $d021
         ldx #$00
         stx $d020
         stx $d015        ;hide sprites

         lda keypress
         cmp #$0D           ;RETURN
         bne _he00
         jsr Initbled
         lda #S_IRQ_BLED
         sta s_irq
_he00    rts

;------------------------------------------------------         
;IRQ for editor help screen         
         
IRQ_HELP_MAPEDIT
         ldx #HELP_MAPEDIT_D018
         stx $d018
         ldx #$0F
         stx $d021
         ldx #$00
         stx $d020
         stx $d015        ;hide sprites

         lda keypress
         cmp #$0D           ;RETURN
         bne _hm00
         jsr Initmapedit
         lda #S_IRQ_MAPEDIT
         sta s_irq
_hm00    rts

;------------------------------------------------------         
;IRQ for the editor

IRQ_BLED
         ldx #$00
         stx $d020
         ldx DD021
         stx $d021
         ldx DD022
         stx $d022
         ldx DD023
         stx $d023

         ;Some timing to handle upper part and block row so that we don't have ugly glitches
         ldx #$11
         ldy SPR1Y+1
         cpy #7
         bmi _ib_del
         ldx #$0d
_ib_del  dex
         bne *-1

         ldx #$D8
         stx $d016
DD018    ldx #$1C
         stx $d018

         +setd020 7

         +setd020 2
         jsr JOYCHECK
         +setd020 0

         +setd020 6
         jsr BITEIT
         +setd020 0

         ;Wasting a lot of CPU power here waiting from line $80 to $ff

         ldx #$ff
         cpx $d012
         bne *-3
         ;set the upper part of the screen
         ldx #$08
         stx $d016
         ldx #$15
         stx $d018
         ldx #$0B
         stx $d021

         +incd020
         jsr FIXSCREEN
         lda #BLOCKLINE_BLED
         jsr drawBlockLine
;         jsr FIXSCREEN
         +decd020

         +setd020 5
         jsr KEYCHECK
;         jmp KEYCHECK2 ;Returns to IRQ2BACK
         +setd020 0

         rts
         
;------------------------------------------
;Reset IRQ to default $ea31
;
; This clears keybuffer

NOIRQ    
         sei
         lda #$31
         ldy #$EA
         sta $0314
         sty $0315
         ldx #$81
         stx $DC0D
         ldx #$00     ;was 79
         stx $d019
         ldx #$00     ;was 01
         stx $d01A
         ldx #$00
         stx $d015
         ldx #$36
         stx $01
         
         ldx #$00
         stx keypress
         cli
         rts         
