
        org     $8000

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

