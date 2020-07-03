
        ; Выдача сообщения на дисплей
        ldi     r1, $f000
        ldi     r2, mesg
        call    print
@@:     bra     @b

        include "print.asm"
mesg    db "NotStonks:Русския Симбалы Тожэ Паддэржывайутся",0
