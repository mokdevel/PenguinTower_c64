
;
;FREE:  $c0

!ifndef LASTSCREEN {
        *= GFX_RAAMI_CLR
!media   "gfx_raami.graphicscreen",color 
;
        *= GFX_RAAMI_SCR
!media   "gfx_raami.graphicscreen",screen
;
        *= GFX_RAAMI_BMP
!media   "gfx_raami.graphicscreen",bitmap
;
  !ifndef LASTSCREEN_SKIP {
        *= GFX_3_CLR
  !media   "pt+parr.graphicscreen",color 
  ;
        *= GFX_3_SCR
  !media   "pt+parr.graphicscreen",screen
  ;
        *= GFX_3_BMP
  !media   "pt+parr.graphicscreen",bitmap
  ;
  }

}

        *= GFX_2_CLR
!media   "gfx_ptower_big.graphicscreen",color 
;
        *= GFX_2_SCR
!media   "gfx_ptower_big.graphicscreen",screen
;
        *= GFX_2_BMP
!media   "gfx_ptower_big.graphicscreen",bitmap
;

;-------------------------------------------------
;Special case when working on the last level

!ifdef LASTSCREEN {
        *= GFX_RAAMI_CLR
!media   "pt+parr.graphicscreen",color 
        *= GFX_RAAMI_SCR
!media   "pt+parr.graphicscreen",screen
        *= GFX_RAAMI_BMP
!media   "pt+parr.graphicscreen",bitmap

GFX_3_CLR = GFX_RAAMI_CLR
GFX_3_SCR = GFX_RAAMI_SCR
GFX_3_BMP = GFX_RAAMI_BMP
GFX_3_dd00 = GFX_RAAMI_dd00
}

