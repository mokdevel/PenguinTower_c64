;-------------------------------------------------
;DEFINES

;RELEASE        ;Disables all defines when doing a release
CHEAT
TOBEREMOVED

;---------------------------------------------------
;Do-not-remove defines

DEF_FILEIO_BYTE ;Enable load/save routines

;---------------------------------------------------
;Development time defines

!ifndef RELEASE {
DEBUG           ;Enable various debug things
STARTWITHRUN    ;Code starts from $0801 messing the few first blocks of graphics. 
NOMUSIC         ;Does not compile nor play music.
;GOMAIN          ;Go to mainmenu and skip intro
;GOGAME          ;Starts the game immediately§. To be used only during development.
;GOHOF          ;Starts game but goes to halloffame via gameover immediately
;GOENDTRO        ;Goes to endtro. This overrides GOGAME
;NOSCORELOAD     ;Don't load highscores
CHEAT           ;Allow T to advance to next level, U +10 levels, E kills all players...

;--- Level data load defines ---
;LEVELS_LOAD     ;Load levels from disk instead of compilation. Quite untested.
LEVELS_LIMITED  ;Compilation just loads some of the levels to fit under $d000.
;LEVELS_NONE     ;Do not compile level data. Used when level data is not needed for faster loading.
;ONLYLASTLEVEL   ;Used when working on the last level
}

;---------------------------------------------------
;Include files

!source "ptglobal.asm"
!source "..\common\macro.asm"

;===================================================
;MEMORY MAP

;USED                                           ;0340-037f - next level sprite
;EMPTY                                          ;0380-03ff - empty
;SCR04                                          ;0400-07ff - main screen
!ifndef STARTWITHRUN {
    *= GAMEBMPDATA                              ;0800 17ff - block graphics - can't be moved. Skip 10: start addr (2) + 8 BLED specific bytes 
    !bin    "bindata\gamegfx86.prg",,10                 
  } else {
    START_SKIP=$10
    *= GAMEBMPDATA+START_SKIP                   ;0800 17ff - block graphics - can't be moved
    !bin    "bindata\gamegfx86.prg",((BLOCKANIMDATA-GAMEBMPDATA)-START_SKIP),(10+START_SKIP)
}
        *= BLOCKANIMDATA
!bin    "bindata\blocanim78.prg",($a0*8),10             ;1800 1cff - block animation graphics
        *= DATASECTION_2
!source "data_game.asm"                         ;1d00 1fff - generic data
;
!fill $80                                       ;2000 207f - used for plasmafont - can't be moved
!media  "plasdata.charsetproject",char,16,1     ;2080 2087 - used for plasmafont char - can't be moved
;EMPTY                                          ;2088 20bf - empty
        *= SPRITEGFX
!media  "sprites.spriteproject",sprite,0,69     ;20c0 31ff - sprites
;
        *= ANIMPLASMADATA                       ;must be on aligned to page
!media  "plasdata.charsetproject",char,0,16     ;3200 327f - nextlevel animation plasms graphics
;
         *= DATASECTION_1                   
!source "data.asm"                              ;3280 .... - generic data
         
        lord = *                                ;.... .... - normal level pack pointers
!ifndef ONLYLASTLEVEL {
 !bin    "bindata\pt64-pack-ptrs.prg",,2
} else {
 !bin    "bindata\pt64-pack-last_ptrs.prg",,2
}
        bonl = *                                ;.... .... - bonus level pack pointers
!bin    "bindata\pt64-bonus-ptrs.prg",,2         
;EMPTY                                          ;.... 37ff - empty
        *= FONTBMPDATA
!media  "fontbmp.charsetproject",char,0,96      ;3800 3aff - font bitmap data - can't be moved
!source "data_font.asm"                         ;3b00 3bff - font block data
        *= PENGUINLOGO
!media  "penglogo.charscreen",charset,0,88      ;3c00 3ebf - penguin tower logo charset - can't be moved
!media  "penglogo.charscreen",char,0,0,40,8     ;3ec0 3fff - penguin tower logo charscreen
;
         *= DATASECTION_3                       ;must be on aligned to page
!source "data_misc.asm"                         ;4000 .... - generic data
;EMPTY                                          ;.... 44ff - empty
;USED                                           ;4500 .... - main code area .. up to level data
        *= BONUSLEVELS
!bin    "bindata\pt64-bonus-levels.prg",,2              ;9000 .... - bonus level data
;
        *= LEVELS
!ifndef LEVELS_NONE {       
  !ifndef LEVELS_LOAD {
    !ifdef LEVELS_LIMITED {                     ;9c00 .... - level data up to max $cfff 
      !ifndef ONLYLASTLEVEL {
        !bin    "bindata\pt64-pack-levels.prg",($d000-LEVELS),2
      } else {
        !bin    "bindata\pt64-pack-last.prg",($9fff-LEVELS),2
      }
    } else {
      !ifndef ONLYLASTLEVEL {
        !bin    "bindata\pt64-pack-levels.prg",,2       ;9c00 .... - level data - full for release
      } else {
        !bin    "bindata\pt64-pack-last.prg",,2
      }
    }
  }      
}

;EMPTY                                      ;.... e3ff - empty

!ifndef NOMUSIC {
        *= $e400
!bin    "bindata\e4fe_muz.bin",,2                   ;e400 fecf - music
}
;===================================================


;---------------------------------------------------
;start jump vectors

!ifdef STARTWITHRUN {
         *= $0801
         !basic
         jmp $4500
}

         *= $4500               ;sys 17664
         
         ldx #$36
         stx $01
         ldx #$80               
         stx $0291              ;disable shift
         ldx #$00
         stx $c6                ;clear key buffer

!ifdef LEVELS_LOAD {
_ll0     inc $d020
         jsr $ffe4
         cmp #$20             ;press space to load
         bne _ll0
         jsr LoadLevelFromDisk
         bne *
}

!ifndef NOSCORELOAD {
         jsr Load_YesNo
}

!ifdef NOMUSIC {
         jsr Music_NoMusic_InitRandomization
}

!ifdef GOMAIN {
         lda #MAIN_INIT_JSR
         sta irqjump_idx
}

!ifdef GOGAME {
         jsr initgame
         lda #GAME_SCR_INIT_JSR
         sta irqjump_idx
}

!ifdef GOENDTRO {
         lda #ENDTRO_INIT_JSR
         sta irqjump_idx
}
         jmp RealStart

;---------------------------------------------------
;The main irq routine. A simple state machine which chooses the irq etc to use.

RealStart 
         sei
         lda #$7f             ; switch off interrupt signals from CIA-1
         sta $dc0d
         and $D011            ; clear most significant bit of VIC's raster register
         sta $D011

         lda $DC0D            ; acknowledge pending interrupts from CIA-1
         lda $DD0D            ; acknowledge pending interrupts from CIA-2                 

         lda #$f0
         sta $d012

         lda #<RealIrq
         ldy #>RealIrq
         sta $0314
         sty $0315

         ldx #DD00_VALUE
         stx $dd00

         ldx #$01             ; enable raster interrupt signals from VIC
         stx $d01a
         
         lda #$36             ;Make RAM at $A000 visible.
         sta $01
         
         cli
         jmp *

;---------------------------------------------------
;Different IRQ states

MAIN_INIT_JSR     = $00
MAIN_IRQ_JSR      = $01
GAME_INIT_JSR     = $02
GAME_SCR_INIT_JSR = $03
GAME_IRQ_JSR      = $04
FADEGAMESCR_JSR   = $05

INITPLASMA_JSR    = $20
PLASMAON_JSR      = $21
PLASMAIRQ_JSR     = $22
PLASMAOFF_JSR     = $23

GFADEON_JSR       = $31
INITHOFAME_JSR    = $32
HOFAMEIRQ_JSR     = $33

ENDTRO_INIT_JSR   = $40
ENDTRO_IRQ_JSR    = $41

INTRO_INIT_JSR    = $42
INTRO_IRQ_JSR     = $43

irqjump_idx !byte INTRO_INIT_JSR;MAIN_INIT_JSR

;---------------------------------------------------
RealIrq  
         ldy #$1b
         sty $d011

         lda irqjump_idx
         
         ;play game - to be the first check so that we don't spend additional cycles
         cmp #GAME_IRQ_JSR
         bne ri0
          jsr gameirq
          cmp #GAMESTATE_PLAYON
          beq ri8a
          pha
          jsr initfadeon
          pla
          ldx #GFADEON_JSR
          cmp #GAMESTATE_WELLDONE
          beq ria8b
          ldx #INITHOFAME_JSR
ria8b     stx irqjump_idx
ri8a     lda #$f1
         sta $d012
         jmp ri_end

         ;initialize main
ri0      cmp #MAIN_INIT_JSR
         bne ri1
          sei
          jsr initmainscreen
          lda #MAIN_IRQ_JSR
          sta irqjump_idx
          lda #$57;f8
          sta $d012
          cli
         jmp ri_end

         ;show main
ri1      cmp #MAIN_IRQ_JSR
         bne ri2
          jsr mainirq
         lda #$57
         sta $d012
         jmp ri_end

         ;init plasma
ri2      cmp #INITPLASMA_JSR
         bne ri3
          jsr initplasma
          jsr initfadeoff
          lda #PLASMAOFF_JSR
          sta irqjump_idx
         lda #$f8
         sta $d012
         jmp ri_end

         ;show plasma
ri3      cmp #PLASMAOFF_JSR
         bne ri4
          jsr anplas
          jsr dofadeoff           ;A=0 if done
          cmp #$00
          bne ri3a
          jsr initfadeon
          lda #PLASMAIRQ_JSR
          sta irqjump_idx
ri3a     lda #$f8
         sta $d012
         jmp ri_end

         ;show getready
ri4      cmp #PLASMAIRQ_JSR
         bne ri5
          jsr plasmairq          ;A=0 if done
          bne ri4a
          lda #PLASMAON_JSR
          sta irqjump_idx
ri4a     lda #$f8
         sta $d012
         jmp ri_end

         ;remove plasma
ri5      cmp #PLASMAON_JSR
         bne ri6
          jsr anplas
          jsr dofadeon           ;A=0 if done
          cmp #$00
          bne ri5a
          lda #GAME_SCR_INIT_JSR
          sta irqjump_idx
ri5a     lda #$f8
         sta $d012
         jmp ri_end

         ;init gamescreen
ri6      cmp #GAME_SCR_INIT_JSR
         bne ri7
          jsr initfadeoff
          jsr initlevel
          lda #FADEGAMESCR_JSR
          sta irqjump_idx
         lda #$f1
         sta $d012
         jmp ri_end

         ;fade game screen in
ri7      cmp #FADEGAMESCR_JSR
         bne ri9
          jsr fixlowerline
          jsr waitrasterlines
          jsr setgamescreen
          jsr fixscreen
          jsr dofadeoff
          cmp #$00
          bne ri7a
          lda #%00000011
          sta $d015
          lda #GAME_IRQ_JSR
          sta irqjump_idx
ri7a     lda #$f0                 ;one line earlier than in game to compensate code run above
         sta $d012
         jmp ri_end

         ;init game the first time
ri9      cmp #GAME_INIT_JSR
         bne ri10
          jsr initgame
          lda #INITPLASMA_JSR
          sta irqjump_idx
         lda #$f8
         sta $d012
         jmp ri_end

         ;fade game screen away
ri10     cmp #GFADEON_JSR
         bne ri11
          jsr fixlowerline
          jsr setgamescreen
          jsr waitrasterlines
          jsr fixscreen
          jsr dofadeon           ;A=0 if done
          cmp #$00
          bne ri10a
          
          lda #INITPLASMA_JSR    ;let's go to next level and init plasma effect
          ldx level              ;unless it was last level (or higher after +3)
          cpx #LASTLEVEL        
          bcc ri10b
          lda #ENDTRO_INIT_JSR    ;go to endtro
ri10b     sta irqjump_idx
ri10a    lda #$f0               ;one line earlier than in game to compensate code run above
         sta $d012
         jmp ri_end

ri11     cmp #INITHOFAME_JSR
         bne ri12
          ;sei
          lda #HOFAMEIRQ_JSR    ;By default we will run HallOfFame. Init may change this to main screen.
          sta irqjump_idx
          jsr InitHallOfFame
          lda #$f1
          sta $d012
          ;cli
         jmp ri_end

ri12     cmp #HOFAMEIRQ_JSR
         bne ri13
          jsr halloffameirq
         lda #$e0
         sta $d012
         jsr do_counters
         ldx #$01
         stx $d019

         ;read keyboard         
         jsr $ffe4
         sta hof_keypress
         jmp $ea31              ;to read keyboards

ri13     cmp #ENDTRO_INIT_JSR
         bne ri14
          sei
          jsr EndtroInit
          lda #ENDTRO_IRQ_JSR
          sta irqjump_idx          
          lda #$f1
          sta $d012
          cli
         jmp ri_end
         
ri14     cmp #ENDTRO_IRQ_JSR
         bne ri15
          jsr EndtroIrq
          cmp #$00
          beq ri14b
          ldx #INITHOFAME_JSR
          stx irqjump_idx          
ri14b    lda #$fc
         sta $d012
         jmp ri_end

ri15     cmp #INTRO_INIT_JSR
         bne ri16
          sei
          jsr IntroInit
          lda #INTRO_IRQ_JSR
          sta irqjump_idx
          lda #$00
          sta $d012
          cli
         jmp ri_end

ri16     cmp #INTRO_IRQ_JSR
         bne ri17
          jsr IntroIrq
          cmp #INTRO_RUN
          beq ri16b
          ldx #MAIN_INIT_JSR
          stx irqjump_idx          
ri16b    lda #$00
         sta $d012
         jmp ri_end
         
ri17     ;We should never reach this line

ri_end   jsr do_counters
         ldx #$01
         stx $d019
         jmp $ea81

;---------------------------------------
;The section for mainmenu
!source "mainmenu.asm"
;---------------------------------------
;The section for hall of fame 
!source "halloffame.asm"
;---------------------------------------
;The section for main gameloop
!source "gameloop.asm"
!source "gameinit.asm"
!source "gamemisc.asm"
!source "gamebomb.asm"
!source "lastlevel.asm"
;---------------------------------------
;The section for graphic functions
!source "gfx.asm"
!source "gfx_animate.asm"
!source "spr_anim.asm"              ;Spritehandler
;---------------------------------------
;The section for next level
!source "plasma.asm"
;---------------------------------------
;The section for general functions
!source "misc.asm"            
!source "load_yn.asm"               ;The section for initial yes/no question on start
!source "depacker.asm"              ;The section for depacker
!source "..\common\fileio.asm"
;---------------------------------------
;The section for endtro
!source "endtro.asm"            
;---------------------------------------
;The section for various texts and text routines
!source "text.asm"
!source "data_text.asm"
;---------------------------------------
;The section for endtro
!source "intro.asm"            

;EMPTY memory until LEVELS .. The level data is loaded in the beginning of this file.
