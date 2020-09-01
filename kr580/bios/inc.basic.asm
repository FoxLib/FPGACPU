hello:      defb    "TinyBasi",127,"1.0",13,0

; Переменные и буферы в памяти
buffer:     equ     $5B00       ; Исходный код (32b)
compiled:   defw    $5B20       ; Скомпилированный (32b)
variable:   defw    $5B40       ; Описатели переменных (2 x 676) 1352 байт, переменная 2 байта 26 букв
curline:    defw    0

; Цветовая палитра
CLR_LINE:   equ     3
CLR_NUMBER: equ     5
CLR_SYMB:   equ     7+$40
CLR_QUOTE:  equ     4

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
            ld      b, a                ; Сохранить A
            ld      a, (cursor_xy)      ; A = X
            cp      $1f                 ; X < 31?
            jr      nc, keyloop         ; Проверка на конец строки
            ld      a, b                ; Восстановить A
            call    savek               ; Сохранить символ в буфере
            rst     $08                 ; Напечатать символ
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
; Нормализация строки, поиск номера, подкрашивание
; ----------------------------------------------------------------------
; РЕГИСТРЫ
; A -символ
; B-режим, C-Цвет
; DE-временный
; HL-указатель на строку
; ----------------------------------------------------------------------

entk:       ; Перевести X=0
            xor     a
            ld      h, a
            ld      l, a
            ld      (curline), hl       ; Текущий номер строки
            ld      (cursor_xy), a      ; X=0 Установка курсора

            ; Перепечать и разобрать на лету
            ld      hl, buffer          ; HL=буфер
            ld      bc, $0007           ; B=Режим, C=цвет

entkl:      ; Получение следующего символа
            ld      a, (hl)
            and     a
            jr      z, entkint          ; Перейти к интерпретатору
            ld      d, a                ; Сохранить символ в D
            ld      (csym), a           ; Дополнительное сохранение
            ld      c, 7                ; Цвет строки белый
            ld      e, 1                ; Перерисовать 1 символ
            ld      a, b                ; Тест режима 0 или 1 (B)
            and     a
            jr      nz, sel01           ; Если B>0, то режим 1

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; РЕЖИМ-0: Номер строки или команда
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            ; Лидирующие пробелы пропускать
            ld      a, d
            cp      ' '
            jr      z, nextcls

            ; Проверка, что это число
            cp      '0'
            jr      c, sel01
            cp      '9'+1
            jr      nc, sel01

            ; Если это число: это номер строки
            ld      c, CLR_LINE
            push    hl
            call    atoi                ; Преобразовать в число
            ld      (curline), de
            pop     de
            xor     a
            sbc     hl, de              ; Количество символов
            dec     hl
            ex      de, hl
            ld      b, 1                ; Переход в режим 1
nextcls:    call    nextcl              ; Пропечатать E символов (или 1)
            jr      entkl

; ----------------------------------------------------------------------
; РЕЖИМ-1: Проверка остальных символов
; ----------------------------------------------------------------------

sel01:      ld      b, 1                ; Переход в режим 1

            ; a-z
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
            ld      c, CLR_SYMB          ; символ в диапазоне A-Z
            jr      nextcls

            ; 0-9
sel03:      cp      '0'
            jr      c, sel04
            cp      '9'+1
            jr      nc, sel04
sel03a:     ld      c, CLR_NUMBER
            jr      nextcls

            ; Обработка '-', '.' и "..."
sel04:      cp      '-'
            jr      z,sel03a            ; Минус обычно относится к числам
            cp      '.'
            jr      z,sel03a
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
            ld      c, CLR_QUOTE
            jr      nextcls
sel04ue:    dec     e                   ; Неожиданное завершение
            jr      sel04e

            ; Другие символы
sel05:      jr      nextcls

; Переход к новой строке
; ----------------------------------------------------------------------
entkint:    ld      a, 13
            rst     $08
            ld      a, 7
            ld      (cursor_attr), a
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
