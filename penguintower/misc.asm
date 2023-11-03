;---------------------------------------------------
;GENERAL FUNCTIONS

;---------------------------------------------------
;This will generate a pseudo random number. To be called once a frame.

do_random
         inc sat        ;pseudo randomizing routine
         inc sat        ;pseudo randomizing routine
         inc sat        ;pseudo randomizing routine         
         lda sat 
         adc $D41B
         beq doEor
         asl
         beq noEor      ;if the input was $80, skip the EOR
         bcc noEor
doEor    eor #$1d
noEor    sta sat
         rts

;---------------------------------------------------
;Handle generic counters. To be called once a frame.

do_counters
         jsr do_random

         lda esf        ;generate a value that switches between 0 and 1
         and #%00000001
         eor #%00000001
         sta esf

         ldx eff        ;generate a value that switches between 0 and 1, 2, 3
         inx
         txa
         and #%00000011
         sta eff
         rts

;---------------------------------------------------
;put sprite Y

PutYSpr  sta $d001
         sta $d003
         sta $d005
         sta $d007
         sta $d009
         sta $d00b
         sta $d00d
         sta $d00f
         rts

;---------------------------------------------------
;Put wide sprites beside each other
;
;IN: A = start X. Left side of screen is $18

PutXSprWide
         sta $d000
         clc
         adc #$30
         sta $d002
         clc
         adc #$30
         sta $d004
         clc
         adc #$30
         sta $d006
         clc
         adc #$30
         sta $d008
         clc
         adc #$30
         sta $d00a
         clc
         adc #$30
         sta $d00c
         rts

;---------------------------------------------------
;put sprite color

PutSprCol stx $d027
         stx $d028
         stx $d029
         stx $d02a
         stx $d02b
         stx $d02c
         stx $d02d
         stx $d02e
         rts

;---------------------------------------------------
;reset sprite attributes

resetSpr 
         lda #$00
         sta $d010
         sta $d015
         sta $d017
         sta $d01b
         sta $d01c
         sta $d01d
         rts

;---------------------------------------------------
;Kill interupt

noirq_f  sei
         ldx #$2f
         cpx $d012
         bne *-3
         ;ldx #$80
         ;stx $0291
         ldx #$00
         stx $d011
         stx $d020
         stx $d021
         stx $d015
         jsr $fda3
         lda #$31
         ldy #$ea
         sta $0314
         sty $0315
         ldx #$79
         stx $d019
         ldx #$f0
         stx $d01a
         ldx #$c7
         stx $d012
         cli
         rts

;----------------------------------------------
;Clear screen
;
;Fills screen with char $00 and color memory with (A)
;in: A = fillcolor

clrscreen ldx #$00
         sta _cs1+1
_cs0     lda #$00
         sta SCR04+$00,x
         sta SCR04+$0100,x
         sta SCR04+$0200,x
         sta SCR04+$0300,x
_cs1     lda #$00
         sta SCRD8+$00,x
         sta SCRD8+$0100,x
         sta SCRD8+$0200,x
         sta SCRD8+$0300,x
         inx
         bne _cs0
         rts

;----------------------------------------------
;Hex to BCD
;in : A hex number ($10 = 16)
;out: X bcd high   (  1)
;     Y bcd low    (  6)
;     A bcd number ( 16)

HexToBcd 
         ldx #$00
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
         clc
         adc #$30
         sta htbNumb+0
         iny
yk0      lda #$00
         clc
         adc #$30
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

;---------------------------------------------------
;--- music functions
;---------------------------------------------------

!ifdef NOMUSIC {
Music_Init  rts

Music_Play  +incd020
            ldx #$f0
_pm         dex
            bne _pm
            +decd020
            rts
}

!ifdef NOMUSIC {

Music_NoMusic_InitRandomization
         ;When music is not playing, we need to have some randomization.

         ;Initialize SID for random number generation
         lda #$FF  ; maximum frequency value
         sta $D40E ; voice 3 frequency low byte
         sta $D40F ; voice 3 frequency high byte
         lda #$80  ; noise waveform, gate bit off
         sta $D412 ; voice 3 control register
         rts
}

;---------------------------------------------------

!ifndef NOMUSIC {
;--- init musics

sq       = $e4a0
Music_Init ldx #$08
         stx $d404
         stx $d40b
         stx $d412
         ldx #$00
         stx $d030
         stx $d418
         ldx #$e0
         cpx $d012
         bne *-3
         ldx #$d0
         cpx $d012
         bne *-3
         ldx #$c0
         cpx $d012
         bne *-3
         ldx #$0f
         stx musicvolume
         ldx #$35
         stx $01
         ldx #$5f
         stx sq
         jsr $e400
         ldx #$37
         stx $01
         rts

;--- play music routine 1
Music_Play 
         +incd020
         ldx #$35
         stx $01
         lda sq
         and #$f0
         ora musicvolume
         sta sq
         jsr $e403
         ldx #$37
         stx $01
         ldx #$00
         stx $d030
         +decd020
         rts
}

;---------------------------------------
;Randomize levels
;This will randomize the levels to keep the
;playability. The more you use randomize, the
;more they are randomized.
;
;- create a seed
;- create a randomized list of numbers 1-99 to rbuf
;- using this list pick levels from current
;  order and save them as new list
;

ord      = $0400
rbuf     = $0500

randomizelvl sei
         lda #$00
         sta $d011
         jsr clrscreen

         ldx #$00
re0      lda #$00
         sta ord,x
         txa
         sta rbuf,x
         sta rbuf+(LASTLEVEL-1),x       ;99
         sta rbuf+(LASTLEVEL-1)*2,x      ;198
         inx
         cpx #99
         bne re0

         ;get a seed
         ldx sat
         cpx $d012
         bne *-3

         ;create a randomized order of 1-99
         ldy #$00
ag       sty ptr0
         txa       
         clc
         adc $d012
         tax

agg      ldy #$00
         lda rbuf,x          ;get a suggestion for level
newcmp0  cmp ord,y             ;is this place free
         beq secnd
         iny
         cpy ptr0
         bne newcmp0
         sta ord,y
         inc $d020
         iny
         cpy #99
         bne ag

         ldx #$00
re1      lda lord,x
         sta $0600,x
         lda lord+LASTLEVEL,x
         sta $0700,x
         inx
         bne re1

         ldx #$00
re2      ldy ord,x
         lda $0600,y
         sta lord,x
         lda $0700,y
         sta lord+LASTLEVEL,x
         inx
         cpx #99
         bne re2

         ;set IRQ to init main screen and just wait it to happen
         lda #MAIN_INIT_JSR
         sta irqjump_idx

         cli
         lda #$1c
         sta $d011
         jmp *

secnd    inx
         jmp agg
         
ptr0     !byte 0

;---------------------------------------
;Load levels from disk
;
; This is needed for the case when compilation is not able to 
; fit everything in memory.
;
; NOTE: This does not load the files pt64-pack-ptrs, pt64-bonus-ptrs, pt64-bonus-levels

!ifdef LEVELS_LOAD {

LoadLevelFromDisk         
         lda #(LevelFilename_end-LevelFilename)
         ldx #<LevelFilename
         ldy #>LevelFilename
         jsr LOAD_init_byte
         
         lda #<LEVELS        ;Where to load
         sta $02
         lda #>LEVELS         
         sta $03

         lda #$00            ;Amount of bytes to load, or left to 0 to load to end of file
         sta $04
         lda #$00
         sta $05

         jsr LOAD_file_byte
         rts

LevelFilename !pet "pt64-pack-levels"
LevelFilename_end
         
}
;---------------------------------------
;Code to be removed
;
; This is used for debugging various weird

!ifdef TOBEREMOVED {
ToBeRemoved

         ;Check that there is no overflow on bomb tables.
         ldx #$00
_tbr0    ldy exp_check,x
         cpy #$dc
         bne _tbr_bug
         inx
         cpx #$10
         bne _tbr0
         rts
         
         ;Repaint the bombs
         ldx #$00
_tbr1    lda bombti,x
         cmp #BOMBNULL
         beq _tbr2
         
         ldy bombxy,x
         lda blo01,y
         sta $06
         sta $08
         lda bhi01,y
         sta $07
         clc
         adc #$d4
         sta $09
         ldy #$00
         lda #$01
         sta ($06),y
         lda #$00
         sta ($08),y
         
_tbr2         
         inx
         cpx #$10
         bne _tbr1         
         rts
         
_tbr_bug
          inc $d020
          jmp *-3
         
}

