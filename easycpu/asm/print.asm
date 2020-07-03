print:  ; r1 - куда, r2 - откуда
        ldi     r0, 0
        ldi     r3, $FF
.L1:    lda     [r2]
        inc     r2
        and     r3
.L2:    jmp z,  .L3
        sta     [r1]
        inc     r1
        lda     $0017
        sta     [r1]
        inc     r1
        bra     .L1
.L3:    ret
