        ldi     r1, 12345
        ldi     r2, 10
        ldi     r5, $f008
@@:     call    divmod      ; Деление числа r1 на r2
        add     r3, '0'
        sta     [r5]
        dec     r5
        dec     r5
        and     r1, r1
        bra nz, @b
        stop

        include "${inc}/divmod.asm"
