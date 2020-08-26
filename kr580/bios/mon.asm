rst00:  di
        ld      a, $00
        out     ($FE), a
        jp      start

; Печать символа A в режиме телетайпа
rst08:  push    af
        call    prnc
        pop     af
        ret
        defb    0, 0

; rst10 ввод-вывод, курсор, рисование
; rst18 дисковая подсистема

include "inc.display.asm"
include "inc.math.asm"
include "inc.stdio.asm"
include "inc.spi.asm"

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:
            ld      a, $07 + $08
            call    cls

            jr      $

; ---------------------------------------------
