; ----------------------------------------------------------------------
        ivt     reset, _irqkbd
; ----------------------------------------------------------------------
_irqkbd:

        irqenter
        keyboardirq()
        irqleave
        reti

; ----------------------------------------------------------------------
reset:  sti
        lda     $1700
        cls()
brk
        ; Пропись текста
        ldi     r0, mesg
        ldi     r1, $f000 + 2*(80 + 2)
        print()

@@:     getch()
        sta     [r1]
        inc     r1
        inc     r1
        bra     @b

        include "${inc}/screen.asm"
        include "${inc}/keyboardirq.asm"

mesg    db "Я всегда хотел сделать календарь и программу учета спичек...",0
