
        ld      a, 2
        out     ($fe), a
        ld      c, $38 + $07
        call    CLS
        jr      $

; Процедура очистки экрана, в регистре C атрибут
CLS:    ld      hl, $4000
        ld      b, $00
L1:     ld      (hl), b
        inc     l
        jr      nz, L1
        inc     h
        ld      a, h
        cp      $5B
        ret     z
        cp      $58
        jr      nz, L1
        ld      b, c
        jr      L1
