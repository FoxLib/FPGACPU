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

; RST #18   Чтение символа с клавиатуры
            jp      getch
cursor_old: defw    $5800           ; Старая позиция курсора
cursor_attr:defb    0               ; Текущий цветовой атрибут
keyb_spec:  defb    0               ; Нажатые клавиши shift/ctrl/alt
            defb    0

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

            ld      de, murk
            apic    api_print

ml:         rst     $18
            rst     $08
            jr      ml

murk:       defb    "TinyBasi",127,"1.0",13,0
; буфер defw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; буфер 32 байта
