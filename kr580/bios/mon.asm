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

            ; Перерисовать панели
            ld      hl, $8283
            ld      d,  $80
            call    bar

            ld      b, 44
M3:         ld      a, $81
            rst     $08
            ld      a, (cursor_xy)
            add     a, 14
            ld      (cursor_xy), a
            ld      a, $81
            rst     $08
            djnz    M3

            ld      hl, $8485
            ld      d,  $80
            call    bar
            jr      $
; ---
bar:        push    bc
            ld      c, 2
M2:         ld      a, h ; 0x82
            rst     $08
            ld      b, 14
            ld      a, d ; 0x80
M1:         rst     $08
            djnz    M1
            ld      a, l ; 0x83
            rst     $08
            dec     c
            jr      nz, M2
            pop     bc
            ret

; ---------------------------------------------
