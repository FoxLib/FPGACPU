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
            apic    api_cls

halt
            ld      de, $455d
            ld      bc, $7400
            call    uftoi

            ;ld      hl, 1234
            ;call    uitof

            ex      de, hl
            apic    api_itoa
            apic    api_print

            jr      $
