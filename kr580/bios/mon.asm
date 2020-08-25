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
include "inc.spi.asm"

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:
        ld      a, $07
        call    cls
        call    sdinit

        ld      hl, 0x0000
        ld      de, 0x0002
        ld      bc, 0x4000
        call    spiread

        ld      d, 0
        ld      e, a
        call    itoa
        call    print

        jr      $

; ---------------------------------------------
