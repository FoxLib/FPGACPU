
cls:    ; Очистка экрана
        ldi     r0, 0
        ldi     r1, $f000
        ldi     r2, 2000
@@:     lda     $1700
        sta     [r1]
        inc     r1
        swap
        sta     [r1]
        inc     r1
        dec     r2
        jmp nz, @b

        ; Пропись текста
        ldi     r1, $f000 + 2*(80 + 2)
        ldi     r2, mesg
        call    print

        ; Отслеживание нажатия клавиши десу падла
        ldi     r1, $FFA0
        ldi     r2, $FFA1
        ldi     r5, $FFA2
        ldi     r3, 0           ; been
        ldi     r4, $F000
@@:     lda     [r2]
        xor     r3              ; Проверка изменений
        jmp z,  @b
        lda     [r2]
        sta     r3              ; mov r3, [r2]
        lda     [r1]
        sta     [r4]            ; mov [r4], [r1]
        sta     [r5]
        inc     r4
        inc     r4
        bra     @b

        include "print.asm"

mesg    db "Я всегда хотел сделать календарь и программу учета спичек...",0
