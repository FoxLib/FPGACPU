; RST #00   Сброс
            di
            ld      a, $00
            out     ($FE), a
            jp      start

; RST #08   Печать символа A в режиме телетайпа
            push    af
            call    prnc
            pop     af
            ret
reg_a:      defb    0, 0

; RST #10   Управление вводом-выводом, рисование
            ld      (reg_hl), hl
            jp      rst10
reg_hl:     defw    0

; ----------------------------------------------------------------------
; Модули ядра
; ----------------------------------------------------------------------

            include "inc.display.asm"
            include "inc.math.asm"
            include "inc.stdio.asm"
            include "inc.spi.asm"

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:
            ld      a, $0f
            rst     $10
            defb    2               ; CLS

            ld      hl, $0110
            rst     $10
            defb    1               ; SetCursor

            ld      a, 0x83
            rst     $08             ; Print


            jr      $

m:  defb "Meow", 0
