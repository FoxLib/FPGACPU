; RST #00   Сброс
            di
            xor     a
            out     ($FE), a
            jp      start
reg_a:      defb    0

; RST #08   Печать символа A в режиме телетайпа
            push    af
            call    prnc
            pop     af
            ret
cursor_xy:  defw    0

; RST #10   Управление вводом-выводом, рисование
            ld      (reg_hl), hl
            jp      rst10
reg_hl:     defw    0

; ----------------------------------------------------------------------
; Модули ядра
; ----------------------------------------------------------------------

            include "defines.asm"
            include "inc.rst10.asm"
            include "inc.display.asm"
            include "inc.math.asm"
            include "inc.stdio.asm"
            include "inc.spi.asm"

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:      ld      sp, $8000
            ld      a, $07
            rst     $10
            defb    api_cls

M1:
            ld      de, m
            call    print
            jr      M1

m:  defb "Kitecatis ", 0

