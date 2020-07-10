
        org     $8000

        mov     [$1234], bx
        push    ss
        pop     es
        cmc
        clc
        stc
        sti
        cli
        std
        cld
@@:
        nop
        xchg    ax, dx
        mov     dx, $55FF
        jb      @f
        push    bx
        pop     sp
        dec     sp
        inc     ax
@@:
        cmp     ax, bx
        xor     ax, bx
        or      ax, dx

