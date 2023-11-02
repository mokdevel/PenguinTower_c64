;------------------------------------
;Load/save routines

;Load gfx/map
;
;OUT: A=0 - no errors
;     A=$ff - error

;------------------------------------
;Loads graphics from disc with kernal function $ffd5

gfx_Load jsr NOIRQ

         ;set the load filename
         lda #FILENAME_LEN
         ldx #<FILENAME
         ldy #>FILENAME
         jsr LOAD_init_byte
         beq *+5                ;no error
         jmp fileErrorHandler
         
         ldx #<FDAT_SAVE_START  ;ALKU
         ldy #>FDAT_SAVE_START
         stx $02
         sty $03

         lda #$00               ;Load the full file
         sta $04
         lda #$00
         sta $05
         
         jsr LOAD_file_byte
         beq *+5                ;no error
         jmp fileErrorHandler
         rts

;------------------------------------
;Loads graphics from disc with kernal function $ffd5

gfx_Load_ffd5 
         jsr NOIRQ

         lda #FILENAME_LEN
         ldx #<FILENAME
         ldy #>FILENAME
         jsr LOAD_init_kernal
         
         ;Level is loaded to MAP and moved to right place
         ldx #<FDAT_SAVE_START
         ldy #>FDAT_SAVE_START
         jsr LOAD_kernal
         bcs _lg_error 
         clc
_lg_error     
         rts

;------------------------------------
;Save gfx

gfx_Save jsr NOIRQ

         ;set the save filename
         lda #FILENAME_SAVE_LEN
         ldx #<FILENAME_SAVE
         ldy #>FILENAME_SAVE
         jsr SAVE_init_byte
         
         ldx #<FDAT_SAVE_START  ;ALKU
         ldy #>FDAT_SAVE_START
         stx $02
         sty $03
         
         ldx #<FDAT_SAVE_END    ;LOPPU
         ldy #>FDAT_SAVE_END
         stx $04
         sty $05

         ldx #$01
         jsr SAVE_file_byte
         beq *+5                ;no error
         jmp fileErrorHandler
         rts

gfx_Save_ffd8
         jsr NOIRQ

         ;set the save filename
         lda #FILENAME_SAVE_LEN
         ldx #<FILENAME_SAVE
         ldy #>FILENAME_SAVE
         jsr SAVE_init_kernal

         ldx #<FDAT_SAVE_START       ;ALKU
         ldy #>FDAT_SAVE_START
         stx $FB
         sty $FC
         lda #$FB
         ldx #<FDAT_SAVE_END
         ldy #>FDAT_SAVE_END
         jsr $ffd8      ;SAVE
         bcs _s_error
         lda #$00
         rts

;------------------------------------
;Loads one level file from disc

level_Load 
         jsr NOIRQ

         lda #FILENAME_LEN
         ldx #<FILENAME
         ldy #>FILENAME
         jsr LOAD_init_byte
         beq *+5                ;no error
         jmp fileErrorHandler
         jsr LoadLevelFile
         beq *+5                ;no error
         jmp fileErrorHandler
         rts

LoadLevelFile
         ;load address is set as ($YYXX)
         ;By default we load to LEVEL01 address. The data needs to be moved to MAP.
         ldx #<MAP_LEVELS
         lda #>MAP_LEVELS
         clc
         adc LevelNum
         stx $02
         sta $03
;         ldx #<MAP_SIZE
;         lda #>MAP_SIZE
         ldx #$00             ;Filesize set to $0000 to load to the end of file
         lda #$00
         stx $04
         sta $05
         jsr LOAD_file_byte   ;error handling is handled outside LoadLevelFile
         rts

;------------------------------------
;Loads one level file from disc with kernal function $ffd5

level_Load_ffd5
         jsr NOIRQ

         lda #FILENAME_LEN
         ldx #<FILENAME
         ldy #>FILENAME
         jsr LOAD_init_kernal
         jsr LoadLevelFile_ffd5
         rts

LoadLevelFile_ffd5
         ;Level is loaded to MAP and moved to right place
         ldx #<MAP
         ldy #>MAP
         jsr LOAD_kernal
         bcs _llf_error 
         jsr mapStore
         clc
_llf_error     
         rts

;------------------------------------
;Save map
;
; returns: A=0 for success, A=$ff for error

level_Save_ffd8
         jsr NOIRQ
         jsr mapStore

         ;set the save filename
         lda #FILENAME_SAVE_LEN
         ldx #<FILENAME_SAVE
         ldy #>FILENAME_SAVE
         jsr SAVE_init_kernal

         ldx #<MAP        ;Save from
         ldy #>MAP
         stx $fb
         sty $fc
         ldx #<(MAP+$ff)  ;Save to
         ldy #>(MAP+$ff)
         jsr SAVE_kernal
         bcs _s_error
         lda #$00
         rts

_s_error ; Accumulator contains BASIC error code
         ; most likely errors:
         ; A = $05 (DEVICE NOT PRESENT)
         ; A = $04 (FILE NOT FOUND)
         ; A = $1D (LOAD ERROR)
         ; A = $00 (BREAK, RUN/STOP has been pressed during loading)
         lda #$ff
         rts
         
;------------------------
;Error handler

fileErrorHandler

         ; Accumulator contains BASIC error code
         ; most likely errors:
         ; A = $05 (DEVICE NOT PRESENT)
         ; A = $04 (FILE NOT FOUND)
         ; A = $1D (LOAD ERROR)
         ; A = $00 (BREAK, RUN/STOP has been pressed during loading)
         
         pha          ;store error
         
         ldx #$36
         stx $01

         lda #$0b
         jsr clearScreen
         
         jsr $E566        ;cursor to 0,0
         
         ldx #$0f
         lda #<text_fileerror
         ldy #>text_fileerror
         jsr print

         pla
         jsr print_number_hex
         
         jsr $ffe4
         beq *-3
         
         lda #$ff     ;load failure
         rts         

text_fileerror !pet "file error: $",0

;------------------------------------
;Load all levels named 'LEVEL##    .2M+' in order.

text_mload1 !pet "batch loading levels."
            !pet $d, "red is failure.",0
            ;!pet $d, "...............", 0

level_LoadAll
         jsr NOIRQ
         
         ;clear stack
         ldx #14          ;Read 14 values from stack as we came to this routine 'ugly'
_mlb4    pla
         dex
         bne _mlb4
         
         jsr clearScreen
         jsr setDefaultScreen
         
         jsr $E566        ;cursor to 0,0

         ldx #$0b           ;set cursor color
         lda #<text_mload1
         ldy #>text_mload1
         jsr print

         ;We're loading maps. 
         lda #LOADSAVE_MAPEDIT_LOAD
         sta LoadSave
         
         ;set cursor position
         ldx #03
         ldy #00
         jsr set_cursor

         ldx #00
         stx LevelNum

_mlb1    lda LevelNum
         jsr autofillLevelname

!ifdef DEBUG {         
         ldy #$00
_mlb0    lda FILENAME,y
         sta $0400+$50,y
         iny
         cpy #FILENAME_LEN
         bne _mlb0
}         
         ;jsr initFilenameAndDevice
         ;jsr MLOAD2
         lda #FILENAME_LEN
         ldx #<FILENAME
         ldy #>FILENAME
         jsr LOAD_init_kernal
         jsr LoadLevelFile_ffd5
         bcs _mlb3

         lda #$01       ;no error - set color white
         jmp _mlb2
_mlb3    lda #$02       ;load error - set color red
         
;         jsr LOAD_init
;         jsr LoadLevelFile
;         tay
;         lda #$01       ;no error - set color white
;         cpy #$00
;         beq _mlb2
;         lda #$02       ;load error - set color red
         
         ;Draw some progressbar
_mlb2    jsr set_color

         ;delay .. this is needed as otherwise multiload will fail
         lda #$80
         cmp $d012
         bne *-3

         lda LevelNum
         jsr print_number
         lda #"("
         jsr print_char
         lda #"$"
         jsr print_char
         lda LevelNum
         clc
         adc #>MAP_LEVELS
         jsr print_number_hex
         lda #$00
         jsr print_number_hex
         lda #")"
         jsr print_char
         lda #","
         jsr print_char

         ;delay .. this is needed as otherwise multiload will fail
         lda #$80
         cmp $d012
         bne *-3

         inc LevelNum
         lda LevelNum
         cmp #100
         bne _mlb1

         ;return to editor to level 00
         ldx #$00
         stx LevelNum
         jsr levelRelocate
         
         jmp _in_end

;------------------------------------
;Shows the file directory

FileDirectory_Show
         jsr NOIRQ

         ldx #10            ;Read 10 values from stack as we came to this routine 'ugly'
_dir01   pla
         dex
         bne _dir01

         lda #$37           ;we need basic for printing
         sta $01

         jsr clearScreen
         jsr setDefaultScreen
         
         jsr DIR_show

         lda s_irq
         cmp #S_IRQ_BLED
         bne _dir00
         jsr Initbled         
         jmp START

_dir00   jsr Initmapedit
         jmp START 