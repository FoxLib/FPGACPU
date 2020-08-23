rst0:   di
        ld      a, $00
        out     ($FE), a
        jp      start

include "inc.display.asm"

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:  ld      c, $07
        call    CLS

        ld      a, 'A'

        ; Расчет позиции для шрифта
        sub     a, $20
        ld      h, 0
        ld      l, a
        ld      bc, fonts
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, bc
        ex      de, hl

        ; Отрисовка
        ld      hl, $4000
        ld      b, 8
M1:     ld      a, (de)
        ld      (hl), a
        inc     de
        inc     h
        djnz    M1

        jr      $

fonts:
incbin  "font.fnt"
