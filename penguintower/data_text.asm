;---------------------------------------
;The texts for main screen

;'@' = 0 which is to be added to the end of each line
TEXTWRAP  = $fd          ;End of text -> wrap text
TEXTEOP   = $fe          ;End of page
TEXTNOGFX = $ff

         ;Init text.
         ;A=the text to show
InitText sta wtext
         asl
         tax
         lda textstrt+0,x
         sta textptrnew+0
         lda textstrt+1,x
         sta textptrnew+1
         lda #$01
         sta wfn+1
         rts

textstrt !word info,scoretxt,help
wtext    !byte 0        ;what text we're showing

              ;0123456789012345
info    ;!byte TEXTNOGFX
        !byte TEXTEOP
        !byte BLOCK_LIGHTNING
        !scr " @"
        !scr "penguin tower @"
        !scr " @"
        !scr "problemchild @"
        !scr " productions @"
        !scr "   1994-2023 @"
        !scr "                v7.3 @"
        !byte TEXTEOP
        !byte BLOCK_WHEART
        !scr "programming @"
        !scr "% jani hirvo @"
        !scr "audial art @"
        !scr "% side-b @"
        !scr "visual art @"
        !scr "% jani hirvo @"
        !byte TEXTEOP
        !byte TEXTWRAP
        !byte TEXTNOGFX
        !scr "pick player @"
        !scr "random levels @"
        !scr "info page @"
        !scr "help on game @"
        !scr "view scores @"
        !scr "save scores @"
        !scr "start game @"
        !byte TEXTEOP
             ;0123456789012345
scoretxt !byte TEXTNOGFX
        !scr "  high scores @"
        !scr "---------------@"
sco00   !scr "0012000 00 darc@"
sco01   !scr "0011000 00 darc@"
sco02   !scr "0010000 00 darc@"
sco03   !scr "0009000 00 darc@"
sco04   !scr "0008000 00 darc@"
        !byte TEXTEOP
        !byte TEXTNOGFX
sco05   !scr "0007000 00 darc@"
sco06   !scr "0006000 00 darc@"
sco07   !scr "0005000 00 darc@"
sco08   !scr "0004000 00 darc@"
sco09   !scr "0003000 00 darc@"
sco10   !scr "0002000 00 darc@"
sco11   !scr "0001000 00 darc@"
        !byte TEXTEOP
        !byte TEXTNOGFX
        !scr "    team level @"
        !scr "---------------@"
sco20   !scr "[[[[[[[ 12 darc@" ;NOTE: "[" is FAKE_SPACE
sco21   !scr "[[[[[[[ 11 darc@"
sco22   !scr "[[[[[[[ 10 darc@"
sco23   !scr "[[[[[[[ 09 darc@"
sco24   !scr "[[[[[[[ 08 darc@"
        !byte TEXTEOP
        !byte TEXTNOGFX
sco25   !scr "[[[[[[[ 07 darc@"
sco26   !scr "[[[[[[[ 06 darc@"
sco27   !scr "[[[[[[[ 05 darc@"
sco28   !scr "[[[[[[[ 04 darc@"
sco29   !scr "[[[[[[[ 03 darc@"
sco30   !scr "[[[[[[[ 02 darc@"
sco31   !scr "[[[[[[[ 01 darc@"
        !byte TEXTEOP   ;TEXTWRAP
scoretxt_end        
help    !byte BLOCK_BOMB
        !scr "% bomb @"
        !scr "------------- @"
        !scr "increases your @"
        !scr "bomb amount. @"
        !byte TEXTEOP
        !byte BLOCK_LIGHTNING
        !scr "% lightning @"
        !scr "------------- @"
        !scr "increases your @"
        !scr "bomb power. @"
        !byte TEXTEOP
        !byte BLOCK_WHEART
        !scr "% white heart @"
        !scr "------------- @"
        !scr "extra life. @"
        !byte TEXTEOP
        !byte BLOCK_YHEART
        !scr "% yellow heart @"
        !scr "------------- @"
        !scr "makes you @"
        !scr "invulnerable @"
        !scr "for a while.@"
        !byte TEXTEOP
        !byte BLOCK_CLOCK
        !scr "% clock @"
        !scr "------------- @"
        !scr "evil penguins @"
        !scr "freeze for a @"
        !scr "while. @"
        !byte TEXTEOP
        !byte BLOCK_WPILL
        !scr "% white pill @"
        !scr "------------- @"
        !scr "you become a @"
        !scr "penguin eater @"
        !scr "for a while. @"
        !byte TEXTEOP
        !byte BLOCK_BPILL
        !scr "% blue pill @"
        !scr "------------- @"
        !scr "you become a @"
        !scr "doublespeed @"
        !scr "penguin eater @"
        !scr "for a while. @"
        !byte TEXTEOP
        !byte BLOCK_WQUERY
        !scr "% white query @"
        !scr "------------- @"
        !scr "gives you an @"
        !scr "effect which @"
        !scr "can be good or @"
        !scr "bad.@"
        !byte TEXTEOP
        !byte BLOCK_YQUERY
        !scr "% yellow query @"
        !scr "------------- @"
        !scr "gives you a @"
        !scr "bad effect @"
        !scr "beware! @"
        !byte TEXTEOP
        !byte BLOCK_LVLJUMP1
        !scr "% level jump @"
        !scr "------------- @"
        !scr "teleports to @"
        !scr "the nextlevel. @"
        !byte TEXTEOP
        !byte BLOCK_LVLJUMP3
        !scr "% level jump @"
        !scr "------------- @"
        !scr "teleports you @"
        !scr "three levels @"
        !scr "forward. @"
        !byte TEXTEOP
        !byte BLOCK_BONUSLVL
        !scr "% bonus level @"
        !scr "------------- @"
        !scr "teleports you @"
        !scr "to a secret @"
        !scr "bonus level. @"
        !byte TEXTEOP
        !byte TEXTWRAP

score_ptr
         !word sco00
         !word sco01
         !word sco02
         !word sco03
         !word sco04
         !word sco05
         !word sco06
         !word sco07
         !word sco08
         !word sco09
         !word sco10
         !word sco11

score_ptr_team   
         !word sco20
         !word sco21
         !word sco22
         !word sco23
         !word sco24
         !word sco25
         !word sco26
         !word sco27
         !word sco28
         !word sco29
         !word sco30
         !word sco31

SCORE_COUNT = 12

;---------------------------------------
;The texts for hall of fame screen

hoftext  !scr "the hall of fame@"
         !scr "----------------@"
         !scr "enter your name@"
scoline  !scr "00"
         !byte 31
scotemp  !scr "0000000 " ;the score
scolvl   !scr "00 "      ;the level
sconame  !scr "     @"   ;must be five spaces and @

hofline  !byte 0         ;which line is the score line
