;-------------------------------------------------
;intro interrupt

INTRO_RUN  = 0
INTRO_STOP = 1

IntroIrq 
         jsr setgamescreen

         jsr Music_Play

         +setd020 5
         ldx intro_ctr
         cpx #$20
         bcs _ii03
         jsr LastLevel_paintwand
_ii03    inc intro_ctr

         +setd020 7
         lda egg_wipe_st
         cmp #INTRO_STATE_EGG
         beq _ii04
         cmp #INTRO_STATE_WIPE
         beq _ii05         
         lda #INTRO_STOP          ;INTRO_STATE_END
         rts
         
_ii04    jsr Intro_AddRandom_Egg
         jmp _ii06
         
_ii05    jsr Intro_AddRandom_Wipe
         jsr Intro_AddRandom_Wipe
         jsr Intro_AddRandom_Wipe
         jsr Intro_AddRandom_Wipe
         jsr Intro_AddRandom_Wipe
         jsr Intro_AddRandom_Wipe

_ii06    inc egg_wipe_ctr
         lda egg_wipe_ctr
         bne _ii07
         inc egg_wipe_st
_ii07
         +setd020 0

         +setd020 6
         jsr animate_block
         +setd020 0
         
         ldx $d012              ;wait for $d012 to be atleast on line $6c
         cpx #$6c
         bcc *-5
         jsr Music_Play

         ;either fire pressed
         lda $dc00
         eor $dc01
         and #%00010000         ;fire pressed
         beq _ii00              ;no
         lda #INTRO_STOP
         rts
_ii00    lda #INTRO_RUN         ;return 0 stay in intro
         rts                    

intro_ctr     !byte 00    ;Counter increaseed by one per frame
egg_wipe_ctr  !byte 00
egg_wipe_st   !byte INTRO_STATE_EGG

INTRO_STATE_EGG   = 0
INTRO_STATE_WIPE  = 1
INTRO_STATE_END   = 2

;-------------------------------------------------
;intro init

IntroInit  
         ldx #$00
         stx $d021
         stx $d020
         stx $d011
         jsr resetSpr
         ldx #D018_FONT
         stx $d018

         ldy #MUZ_PLASMA
         jsr Music_Init

         lda #$00
         jsr clrscreen

         ;Print last level
         ldx #LASTLEVEL-1
         ldy lvll,x
         lda lvlh,x
         sec
         sbc #LEVELFIX  ;move the level pointer to right place
            
         ;unpack the level
         sty $fb        ;data_address low
         sta $fc        ;data_address high
         lda #<buf      ;destination_address low
         ldy #>buf      ;destination_address low  
         jsr depacker
         jsr plotmap
         jsr plotmapcol
         lda #$00
         sta floor
         
         ;Clear unnecessary blocks from last level
         ldx #$00
_ii08    lda gamemap,x
         cmp #$c6         ;This is the first wand block
         bcs _ii09
         jsr paint
_ii09    inx
         cpx #LEVELSIZE
         bne _ii08
         
         ldx #LEVEL_X*3+08
         jsr paint
         ldx #LEVEL_X*3+11
         jsr paint
         ldx #LEVEL_X*6+08
         jsr paint
         ldx #LEVEL_X*6+11
         jsr paint
         
         lda #$00
         sta SCRD8+(40*06)+18
         sta SCRD8+(40*06)+21
         sta SCRD8+(40*08)+16
         sta SCRD8+(40*08)+23
         sta SCRD8+(40*11)+16
         sta SCRD8+(40*11)+23
         sta SCRD8+(40*13)+18
         sta SCRD8+(40*13)+21
         sta SCRD8+(40*14)+18
         sta SCRD8+(40*14)+21
         sta SCRD8+(40*15)+18
         sta SCRD8+(40*15)+21
         sta SCRD8+(40*16)+18
         sta SCRD8+(40*16)+21
         sta SCRD8+(40*17)+18
         sta SCRD8+(40*17)+21
         sta SCRD8+(40*18)+18
         sta SCRD8+(40*18)+21
         sta SCRD8+(40*19)+18
         sta SCRD8+(40*19)+21
         rts
         
;----------------------------------------------
;Adds a random eggs on map

Intro_AddRandom_Egg
          lda sat
_are1     cmp #LEVELSIZE
          bcc _are0
          clc
          adc #LEVELSIZE
          jmp _are1 
          rts
_are0     tax
          lda gamemap,x
          cmp floor
          bne _are2
          lda #BLOCK_EGG_W
          sta gamemap,x
          tay
          jsr oneblock
_are2     jsr do_random
          rts

;----------------------------------------------
;Wipes the map

Intro_AddRandom_Wipe
          lda sat
_arw1     cmp #LEVELSIZE
          bcc _arw0
          clc
          adc #LEVELSIZE
          jmp _arw1 
          rts
_arw0     tax
          lda gamemap,x
          cmp floor
          beq _arw2
          cmp #BLOCK_EGG_W
          beq _arw2
          rts
          
_arw2     lda #BLOCK_EMPTY
          sta gamemap,x
          tay
          jsr oneblock
          jsr do_random
          rts

