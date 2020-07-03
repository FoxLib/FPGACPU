
        ; Выдача сообщения на дисплей
        ldi     r0, 0
        ldi     r1, $f000
        lda     [loc1]
        sta     r2
L1:     lda     [r2]
        inc     r2
        add     r0
L2:     bra     L2
        sta     [r1]
        inc     r1
        lda     $0017
        sta     [r1]
        inc     r1
        bra     L1

mesg    db "NotStonks",0
loc1    dw mesg
