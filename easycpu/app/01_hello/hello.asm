
        ldi     r15, 0

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
        bra nz, @b

        ; Пропись текста
        ldi     r1, $f000 + 2*(80 + 2)
        ldi     r2, mesg
        call    print
        
        ;
;; -------------------------------        
@@:     ldi     r1, $1
        lda     [$FFA8]
        and     r1
        bra  z, @b
        
        lda     $01F4
        sta     [$FFA5]
        ldi     r1, $F000
        ldi     r3, $00FF
     
@@:     lda     [$FFA3]
        and     r3
        xor     r2
        bra z,  @b
        lda     [$FFA2]
        sta     [r1]
        inc     r1
        inc     r1
        lda     [$FFA3]
        and     r3
        sta     r2
        bra     @b
;; -------------------------------

        ; Отслеживание нажатия клавиши десу падла
        ldi     r1, $FFA2       ; FFA0
        ldi     r2, $FFA3       ; FFA1
        ldi     r3, 0           ; been
        ldi     r4, $F000
@@:     lda     [r2]
        xor     r3              ; Проверка изменений
        bra z,  @b
        mov     r3, [r2]
        mov     [r4], [r1]
        inc     r4
        inc     r4
        bra     @b

        include "print.asm"

mesg    db "Я всегда хотел сделать календарь и программу учета спичек...",0
