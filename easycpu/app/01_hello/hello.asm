; ----------------------------------------------------------------------
        ivt     reset, _irqkbd
; ----------------------------------------------------------------------
_irqkbd:
brk
        irqenter
        keyboardirq()
        irqleave
        reti

; ----------------------------------------------------------------------
reset:  sti
        lda     $1700
        cls()

; ----------------------------------------------------------------------
brk
        ; Пропись текста
        ldi     r1, $f000 + 2*(80 + 2)
        ldi     r2, mesg
        print()
        stop

;; -------------------------------
        ldi     r1, $F000
        ldi     r3, $00FF
@@:     lda     [$FFA3]         ; Mouse Counter
        and     r3
        xor     r2
        bra z,  @b
        lda     [$FFA2]         ; Mouse Data
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

        include "${inc}/screen.asm"
        include "${inc}/keyboardirq.asm"

mesg    db "Я всегда хотел сделать календарь и программу учета спичек...",0
