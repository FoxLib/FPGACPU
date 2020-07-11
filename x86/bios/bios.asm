
        org     0x8000
        macro   brk { xchg bx, bx }

        brk
@@:     in      al, $64
        test    al, 1
        je      @b
    brk
        jmp     @b
