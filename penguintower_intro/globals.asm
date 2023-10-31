
A_TEXT   = $0b00
SPRITE_PATTERN = $ff

;-------------------

cptr     = $00       ;$d800

g0       = $3000     ;$5800
g1       = g0+$0400  ;$d800
pic      = g0+$0800

off      = 374
c0       = $d800+off
c1       = $5c00+off
d1       = $6000+(off*8)

;The Penguin Tower image
GFX_2_CLR   = $8000
GFX_2_SCR   = GFX_2_CLR+$400
GFX_2_BMP   = $a000 ;GFX_2_CLR+$800
GFX_2_dd00  = %11111101
GFX_2_d018  = (($0400/$400)<<4 + ($2000/$0400))

;The Penguin Tower+Parrots image
GFX_3_CLR   = $c000
GFX_3_SCR   = GFX_3_CLR+$400
GFX_3_BMP   = $e000 ;GFX_2_CLR+$800
GFX_3_dd00  = %11111100
GFX_3_d018  = (($0400/$400)<<4 + ($2000/$0400))
;GFX_3_d018  = $7c

;The frame
GFX_RAAMI_CLR = $5800
GFX_RAAMI_SCR = GFX_RAAMI_CLR+$400
GFX_RAAMI_BMP = GFX_RAAMI_CLR+$800
GFX_RAAMI_dd00  = %11111110
GFX_RAAMI_d018  = $7c

;cd       = col2;//$1200
ll       = 12

tscr     = (18*40)+$0400