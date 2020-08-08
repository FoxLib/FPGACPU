
; ----------------------------------------------------------------------
; SUB       Очистить экран от мусора | A,B,H,L
; ----------------------------------------------------------------------

cls:        ld      b, $00
            ld      hl, $4000
cls.L1:     ld      (hl), b
            inc     l
            jr      nz, cls.L1
            inc     h
            ld      a, h
            cp      $5B
            ret     z
            cp      $58
            jr      nz, cls.L1
            ld      b, $07              ; Заполнять цветовые атрибуты
            jr      cls.L1

; https://linux.die.net/man/1/z80asm
incbin      "../../resource/romfont48.bin"
