
; Печать строки (r2) на экране (r1)
; ----------------------------------------------------------------------
print:
        ldi     r3, $00ff
.L1:    lda     [r2]
        inc     r2
        and     r3
.L2:    jmp z,  .L4xit

; Преобразование UTF8 -> ASCII (r4, r5, r6)
; ----------------------------------------------------------------------
        sta     r5
        ldi     r4, $d0
        sub     r4
        sta     r6
        jmp z,  .L4d0        ; D0
        dec     r6
        jmp z,  .L4d1        ; D1
        lda     r5
        bra     .L4out
.L4d0:  lda     [r2]
        inc     r2
        and     r3
        ldi     r4, $10
        sub     r4
        bra     .L4out
.L4d1:  lda     [r2]
        inc     r2
        and     r3
        ldi     r4, $60
        add     r4
; ----------------------------------------------------------------------
.L4out: sta     [r1]
        inc     r1
        lda     $001F
        sta     [r1]
        inc     r1
        bra     .L1
.L4xit: ret
