; ----------------------------------------------------------------------
        ivt     reset, _irqkbd
; ----------------------------------------------------------------------
_irqkbd:

        irqenter
        keyboardirq()
        irqleave
        reti

; ----------------------------------------------------------------------
reset:  cli
        ldi     r15, $8000
        lda     $1700
        cls()

        ; Пропись текста
        ldi     r0, mesg
        ldi     r1, $f000 + 2*(80 + 2)
        print()

        ;sti
@@:     inputkbd()
        sta     [r1]
        inc     r1
        inc     r1
        bra     @b

; -----------------------------------------------
inputkbd:

        push    r0
@@:     lda     [.last]
        sta     r0
        lda     [$FFA0]
        swap
        clh
        sta     [.last]
        sub     r0
        bra z,  @b
        lda     [$FFA0]
        clh
        pop     r0
        ret
.last   dw 0
; -----------------------------------------------

        include "${inc}/screen.asm"
        include "${inc}/keyboardirq.asm"

mesg    db "Я всегда хотел сделать календарь и программу учета спичек...",0
