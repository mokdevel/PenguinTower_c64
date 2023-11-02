;------------------------------------
;
;DEFINES you can use
; DEF_FILEIO_BYTE   : Compile only the per byte load and save routines
; DEF_FILEIO_FFD5   : Compile only the basic kernel load (ffd5) and save routines

;If neither is defined, enable both
!ifndef DEF_FILEIO_BYTE {
  !ifndef DEF_FILEIO_KERNAL {
    DEF_FILEIO_BYTE
    DEF_FILEIO_KERNAL
  }
}

;------------------------------------
;Open file and prepare saving
;
; IN: A=Filename length
;     X=<Filename
;     Y=>Filename
;
; Filename  !pet "@0:filename"
; See: https://c64os.com/post/c64kernalrom
; See: https://www.c64-wiki.com/wiki/OPEN
;
; lda #$xx          ;filename length
; ldx #<Filename
; ldy #>Filename
; jsr SAVE_init_byte/LOAD_init_byte/LOAD_init_ffd5

FILENUMBER = 8

!ifdef DEF_FILEIO_BYTE {
SAVE_init_byte
         jsr $ffbd          ;set the filename
         
         lda #FILENUMBER    ;filenumber
         ldx $ba            ;last used device
         bne *+4
         ldx #$08           ;default device number
         ldy #$01           ;save
         jsr $ffba          ;setlfs

         jsr $ffc0          ;open a logical file
         bcs INIT_error_byte
         
         ldx #FILENUMBER    ;filenumber
         jsr $ffc9          ;open channel for output
         bcs INIT_error_byte
         rts

LOAD_init_byte
         jsr $ffbd          ;set the filename

         lda #FILENUMBER    ;filenumber
         ldx $ba            ;last used device
         bne *+4
         ldx #$08           ;default device number
         ldy #$08           ;disk drive
         jsr $ffba          ;setlfs
         
         jsr $ffc0          ;open a logical file
         bcs INIT_error_byte

         ldx #FILENUMBER    ;filenumber
         jsr $ffc6          ;open channel for input
         bcs INIT_error_byte
         rts
         
;------------------------------------
;Init error handler
;
; Accu has the BASIC error code

INIT_error_byte
         inc $d020
         ;lda #$ff
         rts
         
;------------------------------------
;Load file byte per byte
;
; IN: ($02)=memory start address 
;     ($04)=amount of bytes to load
;     X=0 - file does not have start address, read from start of file
;     X=1 - file has start address, skip it by dummy reading them
;
; lda #<memory_start        ;Where to load
; sta $02
; lda #>memory_start         
; sta $03
;
; lda #<length              ;Amount of bytes to load, or left to 0 to load to end of file
; sta $04
; lda #>length
; sta $05
;
; ldx #$00 or #$01
; jsr LOAD_file_byte
;
;See: https://codebase64.org/doku.php?id=base:writing_a_file_byte-by-byte

LOAD_file_byte
         lda $01
         sta _lf_01+1

         lda $02
         clc
         adc $04
         sta $04
         lda $03
         adc $05
         sta $05

         ;Read load address as we don't need it
         cpx #$00
         beq _lf00
         jsr $ffcf
         jsr $ffcf 
_lf00    jsr $ffb7          ; call READST (read status byte)
         bne _lf_error      ; read error
         jsr $ffcf          ;Read byte from output channel
         sei
         ldx #$30           ;Make RAM at $A000 visible. This probably gives some issues on load
         stx $01
         ldy #$00
         sta ($02),y
         ldx #$37           ;Make ROM at $A000 visible.
         stx $01
         cli 
         inc $02
         bne *+4
         inc $03

         lda $03
         cmp $05
         bne _lf00
         lda $02
         cmp $04
         bne _lf00
         
_lf_ok   lda #$00           ;success
_lf_nok  pha
         lda #$37           ;Make ROM at $A000 visible.
         sta $01
         jsr FILE_close
_lf_01   lda #$00           ;SMC!!!!
         sta $01
         pla
         rts

_lf_error ;error
         cmp #$40           ;end of file
         beq _lf_ok
         jmp _lf_nok        ;Failure error code is returned in A

;------------------------------------
;Save file
;
; IN: ($02)=memory start address 
;     ($04)=memory end address 
;     X=0 - do not store start address to file
;     X=1 - store start address to file
;
; lda #<memory_start        ;From where to save
; sta $02
; lda #>memory_start         
; sta $03
;
; lda #<memory_end          ;To where to save
; sta $04
; lda #>memory_end
; sta $05
;
; ldx #$00 or #$01
; jsr SAVE_file
;
;See: https://codebase64.org/doku.php?id=base:writing_a_file_byte-by-byte

SAVE_file_byte 
         cpx #$00
         beq _sf00
         
         lda $02            ;Store start address
         jsr $ffd2          ;Write byte to output channel
;         sta $ae
         lda $03
         jsr $ffd2          ;Write byte to output channel         
;         sta $af

_sf00    jsr $ffb7          ; call READST (read status byte)
         bne _sf_error      ; write error         
         ldy #$00

         sei
         lda $01           ;Make RAM at $A000 visible.
         and #%11111000
         sta $01
         lda ($02),y
         pha
         lda $01           ;Make ROM at $A000 visible.
         ora #%00000111
         sta $01
         cli
         pla
         jsr $ffd2          ;Write byte to output channel

         inc $02
         bne *+4
         inc $03

         lda $03
         cmp $05
         bne _sf00
         lda $02
         cmp $04
         bne _sf00
         jsr FILE_close
         lda #$00           ;Success
         rts
         
_sf_error ;error
         jsr FILE_close
         lda #$ff           ;Failure
         rts
}

!ifdef DEF_FILEIO_KERNAL {

;------------------------------------
;Set filename and prepare for file access
;
; IN: A=Filename length
;     X=<Filename
;     Y=>Filename
;
; Filename  !pet "@0:filename"
; See: https://c64os.com/post/c64kernalrom
; See: https://www.c64-wiki.com/wiki/OPEN
;
; lda #$xx          ;filename length
; ldx #<Filename
; ldy #>Filename
; jsr SAVE_init_kernal/LOAD_init_kernal

LOAD_init_kernal
         jsr $ffbd          ;set the filename

         lda #FILENUMBER    ;filenumber
         ldx $ba            ;last used device
         bne *+4
         ldx #$08           ;default device number
         ldy #$00           ;$00 means: load to new address
         jsr $ffba          ;setlfs
         rts
         
SAVE_init_kernal
         jsr $ffbd          ;set the filename

         lda #FILENUMBER    ;filenumber
         ldx $ba            ;last used device
         bne *+4
         ldx #$08           ;default device number
         ldy #$01
         jsr $ffba          ;setlfs
         rts

;------------------------------------
;Load file usimg $ffd5 kernal function
;
; ldx #<memory_start        ;Where to load
; ldy #>memory_start         
;
; OUT: if carry set, an error has happened. Accu has the BASIC error code

LOAD_kernal
         lda #$00           ;load to memory (not verify)
         jsr $ffd5
         rts

;------------------------------------
;Load file usimg $ffd8 kernal function
;
; ldx #<memory_start        ;From where to save
; ldy #>memory_start         
; stx $fb
; stx $fc
;
; ldx #<memory_end          ;To where to save
; ldy #>memory_end
;
; OUT: if carry set, an error has happened. Accu has the BASIC error code
         
SAVE_kernal
         lda #$fb       ;This is the zero page used for memory_start
         jsr $ffd8      ;SAVE      
         rts   
}

;------------------------------------
;Close open file and stop
;
;$ffb7 READST values:
; Bit  Bit Value Serial Devices
; 0    1         Time out (Write)
; 1    2         Time out (Read)
; 6    64        EOI (End or Identify)
; 7    128       Device not present

status_ffb7 !byte 0

FILE_close
_fc00    jsr $ffb7          ;TBD: In a case where READST never returns 0, this could end up in a forever loop
         sta status_ffb7
         and #%01000000     ;EndOfFile or similar ($40=EndOfFile, $42=...)
         bne _fc01
         lda status_ffb7
         and #%10000000     ;Device not present
         bne _fc01
         lda status_ffb7
         cmp #$00
         bne _fc00
         
_fc01    lda #FILENUMBER    ;filenumber
         jsr $ffc3          ;close
         
         ;jsr $ffe7          ;Close all files and set standard input/output to keyboard/CRT
         jsr $ffcc          ;Restore default I/O channels
         lda status_ffb7    ;Return the original error code
         rts