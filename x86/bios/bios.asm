
        org     0x8000
        include "inc/macro.asm"

        ; Инициализация
        xor     ax, ax
        xor     sp, sp
        mov     ds, ax
        mov     ss, ax
        mov     ax, $b800
        mov     es, ax

        invoke  cls, $0740
        invoke  setcursor, 0
        ;brk
@@:     call    getch

        jmp     @b

        include "inc/stdio.asm"
        include "inc/keyboard.asm"
