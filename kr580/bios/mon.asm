rst0:   di
        ld      a, $00
        out     ($FE), a
        jp      start

; Печать символа A в режиме телетайпа
rst8:   push    af
        call    prnt
        pop     af
        ret
        defb    0, 0

include "inc.display.asm"
include "inc.math.asm"

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:

        ld      de, $8000
        ld      bc, 15
        ;call    div16u

; ---------------------------------------------

        ld      de, pi
        ld      hl, $4000

L1:     ld      a, (de)
        ld      (hl), a
        inc     de
        inc     l
        jr      nz, L1
        inc     h
        ld      a, h
        cp      $5b
        jr      nz, L1

        jr      $

pi:
        incbin  "pi2.bin"

fonts:
        incbin  "font.fnt"
