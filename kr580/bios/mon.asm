rst0:   di
        ld      a, $00
        out     ($FE), a
        jp      start

; Печать символа A в режиме телетайпа
rst8:   push    af
        call    prnc
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

        ; ... копирнуть ...
        ld      de, 12345
        exx
        ld      de, 65535
        exx

        call    pintb
        call    prns

        exx
        call    pintb
        call    prns

        jr      $

; ---------------------------------------------
