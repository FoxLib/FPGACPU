; ----------------------------------------------------------------------
; Список запросов к RST #10
;
;   rst     $10
;   defb    <номер функции>
; ----------------------------------------------------------------------

api_getcursor:      equ $00 ; Чтение положения курсора в HL
api_setcursor:      equ $01 ; Установка курсора из HL
api_cls:            equ $02 ; Очистка экрана в цвет A
api_print:          equ $03 ; Печать строки DE
api_itoa:           equ $04 ; Конвертация числа DE -> DE
api_read:           equ $05 ; Чтение сектора HL:DE -> BC
api_write:          equ $06 ; Запись сектора из BC в HL:DE
api_div16u:         equ $07 ; Деление, DE=DE / BC, HL=DE % BC
api_setattr:        equ $08 ; Установка текущего атрибута A
api_scrollup:       equ $09 ; Перемотка наверх

; ----------------------------------------------------------------------
pusha:      macro           ; Сохранение регистров
            push    hl
            push    de
            push    bc
            endm
popa:       macro           ; Восстановление регистров
            pop     bc
            pop     de
            pop     hl
            endm
apic:       macro   arg     ; Вызов API-функции
            rst     $10
            defb    arg
            endm
; ----------------------------------------------------------------------
commands:   defb    5,"PRINT"       ; 0
            ; defw  CMD_PRINT
            defb    5,"INPUT"
            ; defw  CMD_INPUT
            defb    3,"FOR"
            ; defw  CMD_FOR
            defb    4,"NEXT"
            ; defw  CMD_NEXT


