;Common data

keypress !byte 0

RETURN   !byte 0          ;flip-flop for bled
MRETURN  !byte 0          ;flip-flop for mapedit
UpdateMapscreen !byte 0   ;A request to update map screen. If !=0 the screen will update.

BCOPYTEMP !byte 0,0,0,0,0,0,0,0

COLORS   !byte 0,0,0,0
MARKCOLOR !byte $00
TEMP     !byte $00

;Mapeditor data

MAPX     !byte 0
MAPY     !byte 0

TEMP1    !byte 0
TEMP2    !byte 0
TEMP3    !byte 0

RowCount !byte 0
Numchars        !scr "0123456789abcdef"
NumcharsReverse !byte $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$81,$82,$83,$84,$85,$86

LevelNum !byte 0    ;the number of level we're editing
BlockNum !byte 0    ;the active block

X20      = MAP/$0100
KER20LO  !byte $00,$14,$28,$3C
         !byte $50,$64,$78,$8C
         !byte $A0,$B4,$C8,$DC
         !byte $F0,$04,$18,$2C
         !byte $40,$54,$68,$7C

KER20HI  !byte X20+0,X20+0,X20+0,X20+0
         !byte X20+0,X20+0,X20+0,X20+0
         !byte X20+0,X20+0,X20+0,X20+0
         !byte X20+0,X20+1,X20+1,X20+1
         !byte X20+1,X20+1,X20+1,X20+1

;---DATAS---

SPRY     !byte $38,$40
         !byte $48,$50,$58,$60,$68,$70
         !byte $78,$80,$88,$90,$98,$A0
         !byte $A8,$B0,$B8,$C0,$C8,$d0
         !byte $D8,$E0,$E8,$F0,$F8,$00

SPRX     !byte $20,$28
         !byte $30,$38,$40,$48,$50,$58
         !byte $60,$68,$70,$78,$80,$88
         !byte $90,$98,$A0,$A8,$B0,$B8
         !byte $C0,$C8,$d0,$D8,$E0,$E8
         !byte $F0,$F8,$00,$08,$10,$18
         !byte $20,$28,$30,$38,$40,$48
         !byte $50,$58

SCRYLOPLC !byte $00,$28,$50,$78,$A0
          !byte $C8,$F0,$18,$40,$68
          !byte $90,$B8,$E0,$08,$30
          !byte $58,$80,$A8,$d0,$F8
          !byte $20,$48,$70,$98,$C0

;--------------------------------------------
;For use with C/V
COPYTEMP !byte 0,0,0,0,0,0,0,0    ;single char copy

;For use with C=+C/C=+V
COPYTEMP_BLOCK_CHARS
         !byte 0,0,0,0             ;blocks
COPYTEMP_BLOCK_COLORS
         !byte 0,0,0,0             ;colors
COPYTEMP_BLOCK_CHARDATA            ;total of 4 char data
         !byte 0,0,0,0,0,0,0,0
         !byte 0,0,0,0,0,0,0,0
         !byte 0,0,0,0,0,0,0,0
         !byte 0,0,0,0,0,0,0,0