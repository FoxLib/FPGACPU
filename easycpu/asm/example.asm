
        r1 = 0xf000
        r2 = mesg
        if r1 <> r2: norm
        print  (r1, r2)
        lda     $1234
        clh
        sti
        cli
norm:   print()         ; Выдача сообщения на дисплей
@@:     bra     @b

        include "print.asm"
mesg    db "NotStonks: Русския Симбалы Тожэ Паддэржывайутся",0
