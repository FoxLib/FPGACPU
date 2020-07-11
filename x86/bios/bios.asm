
        org     0x8000
        macro   brk { xchg bx, bx }

        ; Инициализация
        xor     ax, ax
        xor     sp, sp
        mov     ds, ax
        mov     ss, ax

        ; Очистить экран
        mov     ax, $b800
        mov     es, ax
        xor     di, di
        mov     ax, $1700
        mov     cx, 2000
        rep     stosw
brk
@@:     call    getch

        jmp     @b

        include "inc/keyboard.asm"
