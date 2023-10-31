

;@      = End of line
;/      = End of page. After this, the page is printed
;#,$xx  = Show image with number xx
;$ff    = End the text show

IMG_VILLAGE_SUMMER  = $00
IMG_SNOWHILL        = $01
IMG_KING            = $02
IMG_VILLAGE_WINTER  = $03
IMG_CAVES           = $04
IMG_PENGUIN         = $05
IMG_PARROTS         = $06
IMG_TOWER           = $07
IMG_FLAKES          = $08

text_story
    !scr " the parrots lived@"
    !scr " happily in their@"
    !scr "  little village./"
    !scr "#",IMG_VILLAGE_SUMMER
    !scr " @"
    !scr " life was wonderful.@"
    !scr " /"
    !scr "a year ago something@"
    !scr " white dropped from@"
    !scr "     the sky./"
    !scr "#",IMG_FLAKES
    !scr " white flakes which@"
    !scr "had never been seen@"
    !scr " in the parrotland./"
    !scr "it didn't taste@"
    !scr "anything.@"
    !scr "       ...why worry?/"
    !scr "but there came more@"
    !scr " and more of these@"
    !scr "   white flakes./"
    !scr " the air where the@"
    !scr " parrots had lived@"
    !scr " was suddenly cold/"
    !scr "#",IMG_VILLAGE_WINTER    
    !scr "  no one could go@"
    !scr "  out from their@"
    !scr "  houses to play./"
    !scr "   their crop of@"
    !scr "  birdseed froze.@"
    !scr "/"
    !scr " and more snow fell@"
    !scr "    from the sky.@"
    !scr "/"
    !scr "#",IMG_SNOWHILL
    !scr "  soon you could@"
    !scr "see high snow hills@"
    !scr "    everywhere./"
    !scr "    after a while @"
    !scr "  strangers came to@"
    !scr "    the village./"
    !scr "#",IMG_PENGUIN
    !scr "they were something@"
    !scr " never seen calling@"
    !scr "   themselves as/"
    !scr "@"
    !scr "    the penguins@"
    !scr "/"
    !scr "they spoke with the@"
    !scr "     parrotking.@"
    !scr "/"
    !scr "#",IMG_KING
    !scr " with the coldwand@"
    !scr "they wanted to turn@"
    !scr "/"
    !scr "  the world into a @"
    !scr "   large snowball.@"
    !scr "/"
    !scr "  the parrots were@"
    !scr " ordered to move to@"
    !scr "the warm steam caves/"
    !scr "#",IMG_CAVES
    !scr "@"
    !scr "they had to obey...@"
    !scr "/"
    !scr "during the trip they@"
    !scr "  saw a huge tower.@"
    !scr "/"
    !scr "#",IMG_TOWER
    !scr "@"
    !scr " the penguin tower@"
    !scr "/"
    !scr "they knew that the@"
    !scr "coldwand was there.@"
    !scr "       ...somewhere/"
    !scr "the king chose two@"
    !scr " brave parrots to@"
    !scr "  enter the tower./"
    !scr "#",IMG_PARROTS
    !scr "   the two were@"
    !scr "@"
    !scr " dinsdale and ruby/"
    !scr " carrying bombs and@"
    !scr " wearing coldsuits@"
    !scr "/"
text_lastpage
    !scr "#",IMG_TOWER
    !scr "     they enter@"
    !scr "@"
    !scr " the penguin tower/"
    !scr "  are they able to@"
    !scr " reach the highest@"
    !scr "       floor?"
    !scr "/"
    !scr "   are they able@"
    !scr "    to destroy@"
    !scr "   the coldwand?/"
    !byte $ff

;-

plottext
         ldx dd021_1
         stx $d021

         ldx text+0
         stx $fb
         ldx text+1
         stx $fc

         ldy #$00
ptl0     lda ($fb),y
         cmp #"#"
         bne *+5
         jmp itsa
         cmp #"/"
         beq doplot
         cmp #$ff
         beq getaway
         sta tbuf,y
         iny
         jmp ptl0
getaway
         ldx #STATE_FADEOFF2
         stx state
         rts
         
doplot   sta tbuf,y

         ldy #$00
         ldx #$00
         jsr ptx
         iny
         ldx #$50
         jsr ptx
         iny
         ldx #$a0
         jsr ptx

         iny
         tya
         clc
         adc text+0
         sta text+0
         lda text+1
         adc #$00
         sta text+1

         inc state
         rts

ptx      lda tbuf,y
         ;cmp #"@"
         bne _ptx0
         rts
_ptx0    cmp #"/"
         bne *+3
         rts
         sta tscr+$00,x
         clc
         adc #$40
         sta tscr+$01,x
         clc
         adc #$40
         sta tscr+$28,x
         clc
         adc #$40
         sta tscr+$29,x
         inx
         inx
         iny
         jmp ptx

itsa     ldy #$01
         lda ($fb),y
         sta imgnum
         lda #STATE_FADEOFF
         sta state
         lda text+0
         clc
         adc #2
         sta text+0
         lda text+1
         adc #$00
         sta text+1

         rts
