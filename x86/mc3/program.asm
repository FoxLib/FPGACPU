
        org     $8000

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

