
        org     $8000

        sub     [$0001], word $12FF

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

