hello:      defb    "TinyBasi",127,"1.0",13,0
buffer:     defw    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:      call    clear

            ; Ввод строки
keyloop:    xor     a
            rst     $18                 ; Ввод символа
            cp      $08
            jr      z, bskey
            cp      13
            jr      z, entk
            cp      $20
            jr      c, keyloop          ; Не принимать спецсимволы
            ld      b, a
            ld      a, (cursor_xy)
            cp      $1f
            jr      nc, keyloop
            ld      a, b
            call    savek               ; Сохранить символ в буфере
            rst     $08
            jr      keyloop

            ; Нажатие клавиши Backspace
bskey:      ld      hl, (cursor_xy)
            ld      a, l
            and     a
            jr      z, keyloop          ; Курсор в X=0
halt
            ; Передвинуть курсор влево
            call    clrcursor
            dec     l
            ld      (cursor_xy), hl
            ld      a, ' '
            ld      b, h
            ld      c, l
            call    savek
            call    prn                 ; Очистить символ
            call    setcursor
            jr      keyloop

            ; Запись в буфер символа A
savek:      exx
            ex      af, af'
            ld      a, (cursor_xy)
            ld      b, 0
            ld      c, a
            ld      hl, buffer
            add     hl, bc              ; HL = cursor_x + buffer
            ex      af, af'
            ld      (hl), a             ; Записать символ
            ex      af, af'
            xor     a
            inc     hl
            ld      (hl), a             ; Вставить конец строки
            ex      af, af'
            exx
            ret

            ; Ввод строки
entk:       rst     $08
            jr      keyloop

; ----------------------------------------------------------------------
; Очистка экрана и приветствие
; ----------------------------------------------------------------------

clear:      xor     a
            out     ($FE), a
            ld      a, $07
            apic    api_cls
            ld      de, hello
            apic    api_print
            ret
