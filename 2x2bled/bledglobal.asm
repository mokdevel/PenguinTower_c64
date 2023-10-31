;---------------------------
;Macro definitions
; DEBUG   ;Can be used to disable incd020-macro below

;---------------------------
HELP_EDITOR = $2400
HELP_MAPEDIT= $2800
BLEDSPRITES = $2e00
BTEMP       = $2f00       ;ISO TEMP ALUE
FDAT        = $3000       ;CHARDATA (FONT) ADDY
FDAT_SAVE_START = FDAT-8
FDAT_SAVE_END   = FDAT+$1000
BLEDSCREEN  = $4000
CODE_2      = $4400       ;
MAP         = $4800
MAP_SIZE    = $100
MAP_LEVELS  = MAP + MAP_SIZE

PACKFROM = MAP_LEVELS
PACKTO   = MAP_LEVELS+100*MAP_SIZE

;---------------------------

BDAT0    = FDAT+$0800  ;BLOCKDATA
BDAT1    = FDAT+$0900  ; 01
BDAT2    = FDAT+$0A00  ; 23
BDAT3    = FDAT+$0B00
BCOL0    = BDAT0+$0400 ;BLOCKCOLORS
BCOL1    = BDAT0+$0500 ; 01
BCOL2    = BDAT0+$0600 ; 23
BCOL3    = BDAT0+$0700

BIT_THROUGH         = %00010000
BIT_EXPLODE         = %00100000
BIT_THROUGH_EXPLODE = %00110000
BIT_SPECIAL         = %01000000
BIT_KILL            = %10000000

;---------------------------
HELP_EDITOR_D018  = $95
HELP_MAPEDIT_D018 = $a5
INFO_MAPEDIT_D018 = $15            ;The screen to show color details etc.

MAPCOLOR_D021 = MAP+$f0
MAPCOLOR_D022 = MAP+$f1
MAPCOLOR_D023 = MAP+$f2

SCR04    = $0400       ;BLOCK ON SCREEN
SCRD8    = SCR04+$D400 ;COLORS ON SCREEN
DD021    = $2FFD       ;VARIT
DD022    = $2FFE
DD023    = $2FFF
SPRITE   = $2E80
FPLC     = $06D0          ;FONT SCREENI
FD8PLC   = FPLC+$D400
BPLC     = $0590          ;Block line in bled
BD8PLC   = BPLC+$D400
BMPLC    = $0798          ;Block line in mapedit
BMD8PLC  = BMPLC+$D400
IPLC     = BMPLC-$28
ID8PLC   = IPLC+$D400

BLOCKLINE_BLED = 0
BLOCKLINE_MAPEDIT = 1

LOADSAVE_BLED_LOAD      = 0 ;Get the bled load filename
LOADSAVE_BLED_SAVE      = 1 ;Get the bled save filename
LOADSAVE_MAPEDIT_LOAD   = 2 ;Get the mapedit load filename
LOADSAVE_MAPEDIT_SAVE   = 3 ;Get the mapedit save filename