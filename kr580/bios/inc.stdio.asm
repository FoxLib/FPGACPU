; ----------------------------------------------------------------------
; Пропечатка в буфер integer 16 битного
; Вход:  DE-входящие данные
; Выход: DE-указатель на полученную строку
; ----------------------------------------------------------------------

; Переменные
itoa_dt:    defb 6,5,5,3,5,0

; Процедура
itoa:       push    bc
            push    hl
            ld      hl, itoa_dt+4       ; Последний символ
            ld      bc, 10
L1:         push    hl
            call    div16u              ; Разделить число на 10
            ld      a, l                ; Записать остаток в A
            add     a, '0'
            pop     hl
            ld      (hl), a             ; Запись числа '0'..'9' ASCII
            dec     hl
            ld      a, d
            or      e
            jr      nz, L1              ; Повторять пока не будет 0
            inc     hl                  ; Восстановить указатель
            ex      de, hl              ; Поместить HL -> DE
            pop     hl
            pop     bc
            ret

; ----------------------------------------------------------------------
; Чтение нажатия символа с ожиданием и выдача его в A
; ----------------------------------------------------------------------
getch:      push    bc
            in      a, ($ff)
            ld      b, a
getchl:     in      a, ($ff)        ; Ждать переключения клавиши
            cp      b
            jr      z, getchl
            ld      b, a
            in      a, ($fe)        ; Полученный символ
            ; .. обработка shift
            cp      $80
            jr      nc, getchl      ; Отпущенная клавиша не интересует
            ; ...
            pop     bc
            ret
