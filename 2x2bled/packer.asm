;---------------------------------------
;LevelPACKer routine
;(c)copyright 1995 Scapegoat/Topaz Beerline
;
;Modified by d'Arc to fit Penguin Tower
;Version: 2023-02-16
;---------------------------------------
;
; lda #<packfrom ;Set pointer to Source.Memory
; ldy #>packfrom
; sta $02
; sty $03
;
; lda #<packto  ;Set pointer to Target.Memory
; ldy #>packto
; sta $04
; sty $05
;
; ldx #how_many_levels_to_pack  ;max 100!
; jsr dopack

ENDCHAR = $ff
REPEAT_CTRL = $fe
LASTLEVEL = 1
PACK_LENGTH = $f3   ;how many bytes to pack. A penguin level is 20*12 blocks and 3 colors -> 243 -> $f3

dopack  stx levelcount
        lda $03
        sta levelpage
        lda #$00    
        sta levelno
        
        lda $01           ;store $01
        pha
;        lda #$36
;        sta $01
        
packnextlevel
        lda #$00    
        sta endflag
        sta $02           ;level starts always in the begining of a page
        lda levelno
        clc
        adc levelpage
        sta $03
        
;        ldy #$00
;        lda ($02),y
;        cmp #$ff
;        beq donepacking   
        ldy levelno       
        lda $04   
        sta lvldata_lo,y       
        lda $05   
        sta lvldata_hi,y       
        inc levelno
        jsr main
        ldy levelno
        cpy levelcount
        bne packnextlevel
            
        ;donepacking            
;        lda #$37          ;restore $01
;        sta $01
        pla
        sta $01        
        rts
            
main           
        lda #$ff    
        sta $fd   
        lda #$00    
        sta $fe   
        lda endflag       
        cmp #$00    
        beq main2
        ldy #$00    
        lda #ENDCHAR
        jsr store_byte    ;sta ($04),y           
        jsr _add04       
        rts
;        jmp packnextlevel       
            
main2            
        lda $02   
        ldy $03   
        sta $f8   
        sty $f9   
        ldy #$00    
        jsr load_byte_02 ;lda ($02),y   
        sta $fd   
_ed10            
        inc $fe   
        iny 
        jsr load_byte_02 ;lda ($02),y   
        cmp $fd   
        bne diffchars
        cpy #$03    
        bne _ed10   
        inc $fe   
        jsr ruma02r       
        jsr ruma02r       
        jsr ruma02r       
        jsr ruma02r       
        ldy #$00    
loo2           
        jsr inc_color
        jsr load_byte_02 ;lda ($02),y   
        cmp $fd   
        bne repeoff   
        inc $fe   
        jsr ruma02r       
        jmp loo2        
repeoff            
        ldy #$00
        lda $fe   
        jsr store       
        lda $fd   
        jsr store       
        jmp main        

store   jsr store_byte
        jmp _add04       
            
store_byte
        sei
        pha
        pha
        lda $01
        and #%11111000
        sta $01
        pla
        sta ($04),y
        lda $01
        ora #%00000111
        sta $01
        pla
        cli
        rts

load_byte_02
        sei
        lda $01
        and #%11111000
        sta $01
        lda ($02),y
        pha
        lda $01
        ora #%00000111
        sta $01
        pla
        cli
        rts

load_byte_f8
        sei
        lda $01
        and #%11111000
        sta $01
        lda ($f8),y
        pha
        lda $01
        ora #%00000111
        sta $01
        pla
        cli
        rts

inc_color 
        inc $d020       
        rts
            
diffchars            
        lda $f8   
        ldy $f9   
        sta $02   
        sty $03   
        ldy #$00    
        sty $fe
        jsr load_byte_02 ;lda ($02),y   
        sta $fd   
        inc $fe   
        jsr ruma02d       
            
setcolo jsr inc_color
        ldy #$00    
        jsr load_byte_02 ;lda ($02),y   
        cmp $fd   
        bne _ed03   
_ed02            
        iny 
        jsr load_byte_02 ;lda ($02),y   
        cmp $fd   
        beq _ed02   
        cpy #$03    
        bcs _ed01   
        ldy #$00    
        jsr load_byte_02 ;lda ($02),y   
_ed03            
        sta $fd   
        inc $fe   
        jsr ruma02d       
        jmp setcolo       
            
_ed01           
        lda $02   
        sec 
        sbc #$01    
        sta $02   
        lda $03   
        sbc #$00    
        sta $03   
        dec $fe   
            
exitdiff           
        ldy #$00    
        lda #REPEAT_CTRL
        jsr store       
        lda $fe   
        jsr store       
        ldx $fe   
        ldy #$00    
_ed00            
        jsr load_byte_f8  ;lda ($f8),y   
        jsr store       
        inc $f8   
        bne *+4   
        inc $f9   
        dex 
        bne _ed00   
        jmp main        
            
ruma02r            
        jsr _add02       
        lda $02
        cmp #PACK_LENGTH
        bne ruma02x   
        pla 
        pla 
        lda #$01    
        sta endflag       
        jmp repeoff       
ruma02x            
        rts 
ruma02d            
        jsr _add02
        lda $02
        cmp #PACK_LENGTH
        bne ruma02x
        pla 
        pla 
        lda #$01    
        sta endflag       
        jmp exitdiff        
            
_add02
        inc $02   
        bne *+4   
        inc $03   
        rts 
            
_add04            
        inc $04   
        bne *+4   
        inc $05   
        rts 
      
endflag     !byte 00
levelno     !byte 00
levelcount  !byte 00
levelpage   !byte 00  ;the start page for the levels ($100 per page)
    !align 255,0
lvldata_lo  !fill $80,0   ;keep this aligned to page
lvldata_hi  !fill $80,0             
            
            
            
            
            
            
            
            
            