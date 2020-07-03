
        ; Отслеживание нажатия клавиши десу падла
        ldi     r1, $FFA0
        ldi     r2, $FFA1
        ldi     r3, 0           ; been
        ldi     r4, $F000
@@:     lda     [r2]
        xor     r3              ; Проверка изменений
        jmp z,  @b
        lda     [r2]
        sta     r3              ; Защелка
        sta     [r4]
        inc     r4
        inc     r4
        bra     @b

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

@@:     ldi     r1, $FFA0
        ldi     r2, $F000
        lda     [r1]
        sta     [r2]
        inc     r2
        inc     r2
        inc     r1
        lda     [r1]
        sta     [r2]
        bra     @b



        ; Пропись текста
        ldi     r1, $f000 + 2*(80 + 2)
        ldi     r2, mesg
        call    print
@@:     bra     @b

; Печать строки (r2) на экране (r1)
; ----------------------------------------------------------------------
print:
        ldi     r3, $00ff
.L1:    lda     [r2]
        inc     r2
        and     r3
.L2:    jmp z,  .L4xit

; Преобразование UTF8 -> ASCCI (r4, r5, r6)
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

mesg    db "Я всегда хотел сделать календарь и программу учета спичек",0
