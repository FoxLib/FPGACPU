hello:      defb    "TinyBasi",127,"1.0",13,0

; Переменные и буферы в памяти
buffer:     equ     $5B00       ; Исходный код (32b)
compiled:   defw    $5B20       ; Скомпилированный (32b)
variable:   defw    $5B40       ; Описатели переменных (2 x 676) 1352 байт, переменная 2 байта 26 букв
curline:    defw    0

teststr:    defb    "1234",0

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:      call    clear

            ; Ввод строки для ее интерпретации
keyloop:    xor     a
            rst     $18                 ; Ввод символа в ожидающем режиме
            cp      $08
            jr      z, bskey            ; BACKSPACE
            cp      $0D
            jr      z, entk             ; ENTER
            cp      $20
            jr      c, keyloop          ; Не принимать спецсимволы
            ld      b, a
            ld      a, (cursor_xy)
            cp      $1f
            jr      nc, keyloop         ; Проверка на конец строки
            ld      a, b
            call    savek               ; Сохранить символ в буфере
            rst     $08
            jr      keyloop

            ; Нажатие клавиши Backspace
bskey:      ld      hl, (cursor_xy)
            ld      a, l
            and     a
            jr      z, keyloop          ; Курсор в X=0

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

; ----------------------------------------------------------------------
; Интерпретация строки
; B=0 Прием номера строки
; B=1 Прием дополнительных аргументов
; ----------------------------------------------------------------------

entk:       ; Перевести X=0
            xor     a
            ld      (cursor_xy), a
            ld      h, a
            ld      l, a
            ld      (curline), hl           ; Текущий номер строки

            ; Перепечать и разобрать на лету
            ld      hl, buffer
            ld      bc, $0007               ; B-Режим, C-цвет

entkl:      ; Получение следующего символа
            ld      a, (hl)
            and     a
            jr      z, entk1

            ld      c, 7                    ; Цвет строки белый
            ld      d, a                    ; Сохранить символ в D
            ld      (csym), a               ; Дополнительно
            ld      e, 1                    ; Перерисовать 1 символ

            ; Решение о выдаче цвета
            ld      a, b
            and     a
            jr      nz, sel01

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; РЕЖИМ-0: Номер строки или команда
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            ; Это пробел, пропуск
            ld      a, d
            cp      ' '
            jr      z, nextcls

            ; Проверка, что это число
            cp      '0'
            jr      c, sel01
            cp      '9'+1
            jr      nc, sel01

            ; Если это число: это номер строки
            ld      c, 7 + $40          ; Ярко-белый цвет для номеров
            push    hl
            call    atoi                ; Преобразовать в число
            ld      (curline), de
            pop     de
            xor     a
            sbc     hl, de              ; Количество символов
            dec     hl
            ex      de, hl
            ld      b, 1                ; Переход в режим 1

            ; Пропечатать E символов (или 1)
nextcls:    call    nextcl
            jr      entkl

; ----------------------------------------------------------------------
; Проверка остальных символов
; ----------------------------------------------------------------------
sel01:      ; a-z
            ld      a, (csym)
            cp      'a'
            jr      c, sel02
            cp      'z'+1
            jr      nc, sel02
            add     'A'-'a'             ; Символ поднять
            ld      (hl), a             ; И обновить его в буфере

            ; A-Z
sel02:      cp      'A'
            jr      c, sel03
            cp      'Z'+1
            jr      nc, sel03
            ld      c, 3                ; символ в диапазоне A-Z
            jr      nextcls

            ; 0-9
sel03:      cp      '0'
            jr      c, sel04
            cp      '9'+1
            jr      nc, sel04
sel03a:     ld      c, 5
            jr      nextcls

            ; Обработка минуса и "..."
sel04:      cp      '-'
            jr      z,sel03a            ; Минус обычно относится к числам
            cp      '"'
            jr      nz, sel05

            ; Найти окончание
            push    hl                  ; Сохранить позицию
sel04m:     inc     e
            inc     hl
            ld      a, (hl)
            and     a
            jr      z, sel04ue          ; Досрочный выход
            cp      '"'
            jr      nz, sel04m
sel04e:     pop     hl
            ld      c, 4
            jr      nextcls
sel04ue:    dec     e                   ; Неожиданное завершение
            jr      sel04e

            ; Другие символы
sel05:      jr      nextcls

; Переход к новой строке
; ----------------------------------------------------------------------
entk1:      ld      a, 13
            rst     $08
            jp      keyloop

; ----------------------------------------------------------------------
; Печать E символов цветом C
; ----------------------------------------------------------------------

nextcl:     ; Выставить цвет
            push    bc
            push    af
            ld      a, c
            ld      (cursor_attr), a
            call    setat
            pop     af

            ; Печать символа
            ld      a, (hl)
            inc     hl
            ld      bc, (cursor_xy)
            call    prn
            inc     bc
            ld      (cursor_xy), bc
            pop     bc

            ; К следующему символу
            dec     e
            jr      nz, nextcl
            ret

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
