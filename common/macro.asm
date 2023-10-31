

        !macro incd020 {          
          !ifdef DEBUG {
            inc $d020
          }
        }
        !macro decd020 {          
          !ifdef DEBUG {
            dec $d020
          }
        }

        !macro setd020 col {          
          !ifdef DEBUG {            
            pha
            lda #col
            sta $d020
            pla
          }
        }