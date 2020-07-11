; ----------------------------------------------------------------------
; Очистка экрана cls(word attrbyte)
; ----------------------------------------------------------------------
cls:    xor     di, di
        mov     bp, sp
        mov     ax, [bp + 2]
        mov     cx, 2000
        rep     stosw
        ret     2

; ----------------------------------------------------------------------
; Установка положения курсора
; Входное значение arg=(Y*80 + X)
; ----------------------------------------------------------------------
setcursor:

        mov     bp, sp
        mov     bx, [bp + 2]
        mov     dx, $3d4
        mov     al, $0f
        out     dx, al      ; outb(0x3D4, 0x0F)
        inc     dx
        mov     al, bl
        out     dx, al      ; outb(0x3D5, pos[7:0])
        dec     dx
        mov     al, $0e
        out     dx, al      ; outb(0x3D4, 0x0E)
        inc     dx
        mov     al, bh
        out     dx, al      ; outb(0x3D5, pos[15:8])
        ret     2
