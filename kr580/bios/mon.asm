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
include "inc.stdio.asm"

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:
        ld      a, $07
        call    cls

        ld      de, 12345
        call    pintb
        call    prns
        jr      $

; ---------------------------------------------
