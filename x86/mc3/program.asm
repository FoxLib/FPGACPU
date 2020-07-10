
        org     $8000

        jb      @f
        push    bx
        pop     sp
        dec     sp
        inc     ax
@@:
        cmp     ax, bx
        xor     ax, bx
        or      ax, dx

