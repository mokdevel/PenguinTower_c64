;----------------------------------------------
;Initialize game on first time you start

initgame lda #$00
         sta $d011
         lda #$ff
         sta nuts+0
         sta nuts+1
         lda #H_NULL        ;player does not exist by default
         sta spr_happen+0
         sta spr_happen+1

         ;Credits are only given for two player game
         ldx #$00
         lda plram
         cmp #%00000011
         bne *+4
         ldx #CREDITS_AM
         stx credits
         ldx #STARTLEVEL
         stx level
         stx level_next
    
         lda plram
         and #%00000001
         beq _ig00
         ldy #$00
         lda #PLR_INIT_START
         jsr initplr
         
_ig00    lda plram
         and #%00000010
         beq _ig01
         ldy #$01
         lda #PLR_INIT_START
         jsr initplr
_ig01         
         rts

;----------------------------------------------
;Initialize the next level we are to play. We'll
;scan for eggs, draw it etc...

initlevel ldx #$00
         stx $d011
il1      lda alaosa,x
         sta SCOREROW,x
         lda #$00
         sta SCOREROWD8,x
         inx
         cpx #$28
         bne il1

         ldy #MUZ_BONUS
         ldx bonus
         cpx #NO_BONUS
         bne inl3
         ;ldy #MUZ_GAME
         lda sat        ;play a 'random' music
         and #%11
         tay
         lda gamemusic,y
         tay
         
inl3     jsr Music_Init
         ldx bonus
         cpx #NO_BONUS
         beq inl        ;if bonus=NO_BONUS then play normal level
         lda #NO_BONUS
         sta bonus
         ldy bonl,x
         lda bonh,x
         sec
         sbc #BONUSFIX  ;move the bonus level pointer to right place
         jmp inl2

inl      ldx level_next
         stx level
         ;ldx level
         ldy lvll,x
         lda lvlh,x
         sec
         sbc #LEVELFIX  ;move the level pointer to right place
            
         ;unpack the level
inl2     sty $fb        ;data_address low
         sta $fc        ;data_address high
         lda #<buf      ;destination_address low
         ldy #>buf      ;destination_address low  
         jsr depacker
         lda gamemap+$15  ;The block under the player start position (1,1) is considered as floor
         sta floor

         ;A debug section to set various things
!ifdef DEBUG {  
;         lda #BLOCK_BONUSLVL
;         lda #BLOCK_FIRE_ICE
         lda #BLOCK_LVLJUMP1
         sta gamemap+20+4+1
         lda #BLOCK_LVLJUMP3
         sta gamemap+20+4+2
         lda #BLOCK_YQUERY
         sta gamemap+20+4+3
         lda #BLOCK_YQUERY
         sta gamemap+20+4+4
         lda #BLOCK_YQUERY
         sta gamemap+20+4+5
         lda #BLOCK_WQUERY
         sta gamemap+20+4+6
         lda #BLOCK_ICECUBE
         lda #BLOCK_YQUERY
         sta gamemap+20+4+7
         lda #BLOCK_LIGHTNING
         sta gamemap+20+4+8
         lda #BLOCK_LVLJUMP3
         sta gamemap+20+4+9
         lda #BLOCK_BONUSLVL
         sta gamemap+20+4+10
}
         
         jsr plotmap
         jsr plotmapcol

         ;clear bomb values
         ldx #$00
iniloop2 lda #BOMBNULL
         sta bombti,x
         lda #BOMB_OWNER_NONE
         sta bombused,x
         inx
         cpx #$10
         bne iniloop2

         ;clear sprite values
         ldy #$00
_npp5    lda #H_NULL
         sta spr_happen,y
         lda #$00
         sta spr_happcou,y
         lda #NULL_COORD
         sta spr_scrbls,y
         sta spr_scrbld,y
         iny
         cpy #$08
         bne _npp5

         ldx #$00
iniloop3 lda #$ff
         sta explosion_xy,x
         sta explosion_size,x
         inx
         cpx #$40
         bne iniloop3

         ;reset some values
         lda #GAMESTATE_PLAYON
         sta gamestate+1

         ldy #$00
         sty $d020
         sty temp1
         sty temp2
         sty temp3
         sty munal              ;reset the egg counter
         sty eol_ctr            
         sty fawhat+1
         sty sprFAy+1
         sty wdwait+1
         sty ctr_h_freeze

         ldy #$00
         lda plram              ;init players
         and #%00000001
         beq _npp1         
         ldy #$00
         lda bombmax,y
         sta bombamou,y
         lda #PLR_INIT_LEVEL
         jsr initplr
         
_npp1    lda plram
         and #%00000010
         beq _npp2         
         ldy #$01
         lda bombmax,y
         sta bombamou,y
         lda #PLR_INIT_LEVEL
         jsr initplr

_npp2    jsr scanmuna
         jsr oneblock_fire_init
         rts

;----------------------------------------------
;Initialize player
; IN: A = PLR_INIT_LEVEL - do not reset bombamount and size, use after level change
;     A = PLR_INIT_START - the game is started the first time, or credits used
;     A = PLR_INIT_DEATH - the game is started after normal death
;     Y = sprite (player)
;
;NOTE: Original Y is returned

initplr  cmp #PLR_INIT_LEVEL
         beq _ipn0
         cmp #PLR_INIT_DEATH
         beq _ipn1
         
         ;PLR_INIT_START
         lda #NUTS_AM
         sta nuts,y
         lda #$00
         sta score+0,y
         sta score+2,y
         sta score+4,y
         lda #EXTRALIFEK
         sta exlf,y         
_ipn1    lda #PLR_BOMB_SIZE_DEF
         sta bombsize,y
         lda #PLR_BOMB_AMOUNT_DEF
         sta bombamou,y
         sta bombmax,y

_ipn0    ldx nuts,y
         bpl *+3
         rts

         lda spr_startxl,y
         sta spr_xl,y
         lda spr_startxh,y
         sta spr_xh,y
         lda spr_startyl,y
         sta spr_yl,y
         ;store the block to both source and destination
         lda spr_startbl,y
         sta spr_scrbls,y
         sta spr_scrbld,y

         lda #H_SHIELD
         sta spr_happen,y
         lda #HAPPEN_TIME
         sta spr_happcou,y
         lda #PLR_SPEED_DEF
         sta spr_speed,y

         rts

;----------------------------------------------
;Initialize player death
; IN: Y = sprite (player)
;
;NOTE: Original Y is returned

initplr_death
         lda #H_DYING
         sta spr_happen,y
         lda #DEATHANIMLEN*8-1  ;see _asdeath
         sta spr_happcou,y
         lda #$00
         sta spr_fire,y
         
         ;clear bombs from the bomb list so that we don't give back bombs that are not yours.
         sty _pd_smc+1
         ldx #$00
_pd00    lda bombused,x
_pd_smc  cmp #$00               ;SMC
         bne _pd01
         lda #BOMB_OWNER_NONE   ;Set the bomb to an unknown player
         sta bombused,x
_pd01    inx
         cpx #$10
         bne _pd00
         
         rts

;----------------------------------------------
;Initialize penguin
; IN: X = penguin block position
;     Y = sprite (penguin)

initmon
         ;From the block number, we need to find the sprite coordinates. 
         ;The division is a simple iterative reduction until we have less than 20 blocks which is the amount for X blocks.
         
         lda gamemap,x  ;Store the egg color. Needed for speed definition
         sta _im_smc+1
         
         txa
         ;store the block to both source and destination
         sta spr_scrbls,y
         sta spr_scrbld,y
         
         ldx #$00       ;The amount of rows
_im00    inx
         sec
         sbc #20        ;there are 20 blocks per row
         cmp #20
         bcs _im00
         pha            ;store X position
         txa
         rol            ;multiply Y position with 16
         rol
         rol
         rol            
         sta spr_yl,y
         tya
         tax            ;move sprite index to X
         lda #$00
         sta spr_xh,x
         pla            ;restore X position
         sta spr_xl,x
         
         rol spr_xl,x   ;multiply X position with 16
         rol spr_xh,x
         rol spr_xl,x
         rol spr_xh,x
         rol spr_xl,x
         rol spr_xh,x
         rol spr_xl,x
         rol spr_xh,x
         
         ;set penguin alive with a birth delay before moving. 
         lda #DEF_MON_BIRTHDELAY
         sta spr_movecou,y
         lda #$00
         sta spr_joy,y
         
;         jmp _im_setspd
         
         lda #EGG_W_SPD
_im_smc  ldx #$00
         cpx #BLOCK_EGG_Y
         bne _im01
          lda #EGG_Y_SPD
          jmp _im_setspd
_im01    cpx #BLOCK_EGG_B
         bne _im_setspd
          lda #EGG_B_SPD         
_im_setspd 
          sta spr_speed,y
         rts

;----------------------------------------------
;Initialize penguin death
; IN: X = sprite (penguin)
;
;NOTE: Original X is returned

initmon_death
         lda spr_happen,x       ;if we're already dying, don't rekill
         cmp #H_DYING
         beq _id00

         lda #H_DYING
         sta spr_happen,x
         lda #DEATHANIMLEN*8-1  ;see _asdeath
         sta spr_happcou,x
         lda #JOY_NONE
         sta spr_joy,x
_id00    rts
