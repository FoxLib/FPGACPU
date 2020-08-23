
        ld      sp, $FFFE
        call    CLS

CLS:    ld      hl, $4000
        ld      b, $00
L1:     ld      (hl), b
        inc     l
        jp      nz, L1
        inc     h
        ld      a, h
        cp      $5B
        ret     z
        cp      $58
        jp      nz, L1
        ld      b, $38
        jp      L1
