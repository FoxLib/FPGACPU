
        org     0x8000
        macro   brk { xchg bx, bx }

        ; Очистить экран
        mov     ax, $b800
        mov     es, ax
        xor     di, di
        mov     ax, $1700
        mov     cx, 2000
        rep     stosw

@@:     in      al, $64
        test    al, 1
        je      @b
        in      al, $60
    brk
        jmp     @b
