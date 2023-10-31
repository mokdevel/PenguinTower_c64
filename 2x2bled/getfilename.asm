;---------------------------
;Get filename for 2x2bled
;
; IN: X=LOADSAVE_* - See bledglobal for definitions

LoadSave  !byte 0
CursorPos !byte 0

GETNAME  stx LoadSave
         txa
         
         ;clear stack
         ldx #18          ;Mapedit: Read 18 values from stack as we came to this routine 'ugly'
         cmp #LOADSAVE_MAPEDIT_LOAD
         bcs _gn06
         ldx #16          ;Bled: Read 16 values from stack as we came to this routine 'ugly'
_gn06    pla
         dex
         bne _gn06

         sei
         lda #<IRQ_GETNAME
         ldy #>IRQ_GETNAME
         sta $0314
         sty $0315
         ldx #$7F
         stx $DC0D
         ldx #$01
         stx $d01A
         
         lda #$0b
         jsr clearScreen
         jsr setDefaultScreen
         ldx #$1B
         stx $d011

         ;Prepare the filename 
         lda LoadSave
         cmp #LOADSAVE_MAPEDIT_LOAD
         beq _gn08                    ;_gn10 - let's autofill the level name for load too
         cmp #LOADSAVE_MAPEDIT_SAVE
         beq _gn08
         
         ;Move the gfx default filename
         ldy #$00
_gn09    lda NAME_GFX_DEF,y
         sta FILENAME,y
         iny
         cpy #FILENAME_LEN
         bne _gn09
         ldx #$00               ;Cursorpos to be 0
         jmp _gn07
         
_gn08    ;autofill levelname
         lda LevelNum
         jsr autofillLevelname
         ldx #$07                 ;Cursorpos to be 7 as level## is 7 chars
         jmp _gn07
         
_gn07    stx CursorPos          ;move cursor to right position
         
         ;Print default text to screen
         jsr $E566        ;cursor to 0,0
         
         ldx #$0f
         lda #<text_filename
         ldy #>text_filename
         jsr print
         
         ;reset keypress
         lda #$00
         sta keypress
         
         lda #$80
         sta $d012
         
         cli
         jmp *
         
text_filename !pet "filename:", 0
text_filename_end

                           ;0123456789012345
NAME_GFX_DEF          !pet "            .2b+"
NAME_DEF_LEVEL        !pet "level       .2m+"
NAME_DEF_LEVEL_OFFSET = 5

FILENAME_SCR_PTR  = $0400 + (text_filename_end-text_filename) ;Screen address where the filename is written
FILENAME_DEBUGLINE = FILENAME_SCR_PTR+$50-3

FILENAME_SAVE !pet "@0:"              ;Add "@0:" to filename to overwrite - bytes: $40,$30,$3A
FILENAME      !pet "0123456789012345" ;16 chars
FILENAME_END
              !pet ",P,W"
FILENAME_SAVE_END
FILENAME_LEN        = FILENAME_END-FILENAME
FILENAME_SAVE_LEN   = FILENAME_SAVE_END-FILENAME_SAVE

;---------------------------

IRQ_GETNAME  
         lda keypress   
         cmp #$00
         bne _in01
         jmp _in_print
_in01    ;check for DEL
         cmp #$14           ;DEL
         bne _in05
         
         ;Handle DEL
         ldx CursorPos
         dex
         bmi _in03
         stx CursorPos
         lda #$20           ;print spaces when deleting
_in02    sta FILENAME,x
         inx
         cpx #$0c
         bne _in02
         
_in03    jmp _in_print
         
_in05    ;check for RET
         cmp #$0D           ;RETURN
         bne _in_keyh_ANY
         ldx CursorPos
         bne _in_keyh_RET   ;Avoids empty filenames and just returns

         ;jmp here to go to the right editor and initialize the IRQ properly
_in_end  lda LoadSave
         cmp #LOADSAVE_MAPEDIT_LOAD
         bcs _in30
         ;init bled
         jsr Initbled
         lda #S_IRQ_BLED
         sta s_irq
         jmp START
_in30    ;init mapedit
         jsr Initmapedit
         lda #S_IRQ_MAPEDIT
         sta s_irq
         jmp START

         ;Handle RET
_in_keyh_RET         
         ldx LoadSave
         cpx #LOADSAVE_BLED_LOAD
         bne _in12
         jsr gfx_Load_ffd5
         jmp _in_end         
_in12    cpx #LOADSAVE_BLED_SAVE
         bne _in13
         ;jsr gfx_Save
         jsr gfx_Save_ffd8
         jmp _in_end
_in13    cpx #LOADSAVE_MAPEDIT_LOAD
         bne _in14
         jsr level_Load_ffd5
         jsr levelRelocate
         jmp _in_end
_in14    cpx #LOADSAVE_MAPEDIT_SAVE
         bne _in15
         jsr level_Save_ffd8
         jmp _in_end
_in15    jmp error
         
         ;Handle keys
_in_keyh_ANY
         ldx CursorPos
         sta FILENAME,x     ;print PETSCII
         ;move cursor
         ldx CursorPos
         cpx #$0B
         beq *+6
         inx
         stx CursorPos
         
         ;Print information to screen
_in_print 
         ;print cursor
         ldx CursorPos
         lda #$63
         sta FILENAME_SCR_PTR+$28,x        ;print a cursor on second line
         lda #$01
         sta FILENAME_SCR_PTR+$28+$d400,x  ;print a cursor color
         lda #$20
         sta FILENAME_SCR_PTR+$27,x        ;clear cursor left and right
         sta FILENAME_SCR_PTR+$29,x
         
         ;Print filename
         ldx #$00
_in11    lda FILENAME,x
         cmp #$40
         bcc _in00
         sec
         sbc #$40
_in00    sta FILENAME_SCR_PTR,x             ;print screencodes
         lda #$01
         sta FILENAME_SCR_PTR + $d400,x
         inx
         cpx #(FILENAME_END - FILENAME)
         bne _in11

!ifdef DEBUG {
         ;DEBUG information
         ldx #$00
_in16    lda FILENAME_SAVE,x
         sta FILENAME_DEBUGLINE,x
         lda #$0c
         sta FILENAME_DEBUGLINE + $d400,x         
         inx
         cpx #(FILENAME_SAVE_END - FILENAME_SAVE)
         bne _in16
}         
         ldx #$01
         stx $d019
         jsr $ffe4
         sta keypress 
;         beq _in16
;         nop
;_in16        
         lda #$80
         sta $d012
         jmp $EA31

;-----------------------------
;autofillLevelname
;
; Autofill the levelname to FILENAME to include the current level number. 
;
; IN: A = Levelnumber to autofill

autofillLevelname
         ;convert to BCD
         jsr hexToBcd         
         pha
         lsr
         lsr
         lsr
         lsr
         tay
         lda Numchars,y
         sta NAME_DEF_LEVEL+NAME_DEF_LEVEL_OFFSET+0
         pla
         and #%1111
         tay
         lda Numchars,y
         sta NAME_DEF_LEVEL+NAME_DEF_LEVEL_OFFSET+1
         
         ;Move the fixed name to be FILENAME
         ldx #$00
_afll0   lda NAME_DEF_LEVEL,x
         sta FILENAME,x
         inx
         cpx #FILENAME_LEN
         bne _afll0
         
         rts