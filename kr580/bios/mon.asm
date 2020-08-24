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
        call    CPAD

        ; Отрисовка
        ld      hl, $4000
        ld      b, 8
M1:     ld      a, (de)
        ld      (hl), a
        inc     de
        inc     h
        djnz    M1


M2:     ld      hl, $4020
        ld      a, $ff
        in      a, ($fe)
        ld      (hl), a
        inc     h
        ld      a, $0f
        in      a, ($ff)
        ld      (hl), a
        jr      M2

fonts:
incbin  "font.fnt"
