
tbuf     !fill $80

vertcol  !byte $06,$06,$0e,$0e,$03,$03,$03,$01
         !byte $01,$01,$03,$03,$03,$0e,$0e,$0e

bacol    !byte $00,$00,$0b,$0b,$0c,$0c,$0f,$0f
         !byte $0d,$0d,$01,$01,$0d,$0d,$03,$03
         !byte $0e,$0e,$06,$06,$06,$06,$06,$06
         !byte $06,$06,$06,$06,$06,$06,$06,$06
         !byte $06,$06,$06,$06,$06,$06

bacol1   !byte $00,$00,$0b,$0b,$0c,$0c,$0f,$0f
         !byte $0d,$0d,$01,$01,$0d,$0d,$03,$03
         !byte $0e,$0e,$06,$06,$06,$0e,$0e,$03
         !byte $03,$0d,$0d,$01,$01,$0d,$0d,$0f
         !byte $0f,$0c,$0c,$0b,$0b,$00

vipecol
         !byte $06,$06,$06,$06
         !byte $0e,$03,$0d,$01

         !byte $0e,$0e,$0e,$0e
         !byte $0e,$03,$0d,$0d

!ifndef GOLASTPAGE {
text     !word text_story
} ELSE {
text    !word text_lastpage
}
d3fff    !byte 0
d7fff    !byte 0

        !align 255,0  ;Tables below needs to be aligned to page
col2h   !fill $80     ;The same as col2, but with upper bytes.
        !align 255,0  ;Tables below needs to be aligne to page
col2    !byte $00,$00,$00,$00,$00,$00,$00,$00
        !byte $00,$00,$00,$0B,$0C,$0F,$0D,$01
        !byte $00,$00,$00,$00,$00,$09,$08,$02
        !byte $00,$00,$00,$00,$00,$06,$0E,$03 
        !byte $00,$00,$00,$00,$06,$02,$08,$04 
        !byte $00,$00,$00,$00,$00,$0B,$0C,$05 
        !byte $00,$00,$00,$00,$00,$00,$00,$06 
        !byte $00,$00,$00,$00,$0B,$0C,$0F,$07 
        !byte $00,$00,$00,$00,$00,$09,$02,$08 
        !byte $00,$00,$00,$00,$00,$00,$00,$09 
        !byte $00,$00,$00,$00,$09,$02,$08,$0A 
        !byte $00,$00,$00,$00,$00,$00,$00,$0B 
        !byte $00,$00,$00,$00,$00,$00,$0B,$0C 
        !byte $00,$00,$00,$00,$0B,$0C,$0F,$0D 
        !byte $00,$00,$00,$00,$00,$06,$0B,$0E 
        !byte $00,$00,$00,$00,$00,$0B,$0C,$0F

bcol     !byte 0,0,0,0,0,0,0,0,0,0
         !byte 0,0,0,0,0,0,0,0,0,8
         !byte 8,8,8,8,8,8,8,8,8,8
         !byte 8,8,8,0,0,0,0,0,0,0

bcolctr  !byte 0    ;bg color fade counter
vertctr  !byte 0    ;vertical bar fade counter
waitctr  !byte 0    ;wait counter between texts

;---------------------------------------

picoff   !word (40*0)+(0*ll)
         !word (40*0)+(1*ll)
         !word (40*0)+(2*ll)
         !word (40*9)+(0*ll)
         !word (40*9)+(1*ll)
         !word (40*9)+(2*ll)
         !word (40*17)+(0*ll)
         !word (40*17)+(1*ll)
         !word (40*17)+(2*ll)

dataoff  !word ($0140*0)+(0*ll*8)
         !word ($0140*0)+(1*ll*8)
         !word ($0140*0)+(2*ll*8)
         !word ($0140*9)+(0*ll*8)
         !word ($0140*9)+(1*ll*8)
         !word ($0140*9)+(2*ll*8)
         !word ($0140*17)+(0*ll*8)
         !word ($0140*17)+(1*ll*8)
         !word ($0140*17)+(2*ll*8)
