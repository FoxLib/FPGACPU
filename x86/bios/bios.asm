
        org     0x8000
        macro   brk { xchg bx, bx }

        brk
        jmp     $
