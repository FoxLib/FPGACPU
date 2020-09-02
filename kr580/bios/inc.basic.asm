hello:      defb    "TinyBasi",127,"1.0",13,0

; Переменные и буферы в памяти
buffer:     equ     $5B00       ; Исходный код (32b)
compiled:   defw    $5B20       ; Скомпилированный (32b)
variable:   defw    $5B40       ; Описатели переменных (2 x 676) 1352 байт, переменная 2 байта 26 букв
curline:    defw    0           ; Номер строки (0..65535)

; ----------------------------------------------------------------------
; Старт операционной системы
; ----------------------------------------------------------------------

start:      call    clear
terml:      xor     a                   ; Ввод строки для ее интерпретации
            rst     $18                 ; Ввод символа в ожидающем режиме
            cp      $08
            jr      z, bskey            ; BACKSPACE
            cp      $0D
            jr      z, entk             ; ENTER
            cp      $20
            jr      c, terml            ; Не принимать спецсимволы
            ld      b, a                ; Сохранить A -> B
            ld      a, (cursor_xy)      ; A = X
            cp      $1f                 ; X < 31?
            jr      nc, terml           ; Проверка на конец строки
            ld      a, b                ; Восстановить A <- B
            call    savek               ; Сохранить символ в буфере
            rst     $08                 ; Напечатать символ
            jr      terml

            ; Нажатие клавиши Backspace
bskey:      ld      hl, (cursor_xy)
            ld      a, l
            and     a
            jr      z, terml            ; Курсор в X=0? Ничего не делать

            ; Передвинуть курсор влево
            call    clrcursor           ; Убрать курсор
            dec     l
            ld      (cursor_xy), hl     ; Записать новое положение
            ld      a, ' '
            ld      b, h                ; B=Y
            ld      c, l                ; C=X
            call    savek               ; Сохранить SPC в буфере
            call    prn                 ; Очистить символ
            call    setcursor           ; Установка курсора в (BC)
            jr      terml

            ; Запись в буфер символа A по координатам курсора
savek:      exx
            ex      af, af'
            ld      a, (cursor_xy)
            ld      b, 0
            ld      c, a
            ld      hl, buffer
            add     hl, bc              ; HL = cursor_x + buffer
            ex      af, af'
            ld      (hl), a             ; Записать символ A
            ex      af, af'
            xor     a
            inc     hl
            ld      (hl), a             ; Обновить конец строки (Zero)
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

entk:       xor     a                   ; A=HL=0
            ld      h, a
            ld      l, a
            ld      (curline), hl       ; Номер строки
            ld      (cursor_xy), a      ; X=0 Установка курсора

            ; Подготовить к разбору
            ld      hl, buffer          ; HL=буфер
            ld      bc, $0007           ; B=Режим, C=цвет

            ; Получение следующего символа
entkl:      ld      a, (hl)
            and     a
            jr      z, entkint          ; Перейти к интерпретатору
            ld      d, a                ; Сохранить символ в D
            ld      c, CLR_DFLT         ; Цвет строки белый
            ld      e, 1                ; Перерисовать 1 символ
            ld      a, b                ; Тест режима 0 или 1 (B)
            and     a
            ld      a, d                ; Восстановить символ A
            jr      nz, sel01           ; Если B>0, то режим 1

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; РЕЖИМ-0: Номер строки или команда
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            ; Лидирующие пробелы пропускать
            cp      ' '
            jr      z, nextcls

            ; Проверка, что это число
            cp      '0'
            jr      c, sel01
            cp      '9'+1
            jr      nc, sel01           ; Если не число, то РЕЖИМ-1

            ; Парсинг номера строки
            push    hl
            call    atoi                ; Преобразовать в число
            ld      (curline), de
            pop     de
            xor     a
            sbc     hl, de              ; Количество символов (E)
            dec     hl
            ex      de, hl              ; Вернуть HL к началу
            ld      bc, $0100+CLR_LINE  ; Переход в режим 1 + цвет

            ; Пропечатать E символов из позиции HL
nextcls:    call    nextcl
            jr      entkl

; ----------------------------------------------------------------------
; РЕЖИМ-1: Проверка остальных символов
; ----------------------------------------------------------------------

sel01:      ld      b, 1                ; Переход в режим 1

            ; a-z
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
            ld      c, CLR_SYMB          ; Символ в диапазоне A-Z
            jr      nextcls

            ; 0-9
sel03:      cp      '0'
            jr      c, sel04
            cp      '9'+1
            jr      nc, sel04
sel03a:     ld      c, CLR_NUMBER
            jr      nextcls

            ; Обработка '-+.' и "..."
sel04:      cp      '-'
            jr      z, sel03a            ; +/-/. обычно относится к числам
            cp      '+'
            jr      z, sel03a
            cp      '.'
            jr      z, sel03a

            ; Кавычки "..."
            cp      '"'
            jr      nz, nextcls         ; Завершить определение

            ; Найти окончание кавычек (или не найти)
            push    hl                  ; Сохранить позицию
sel04m:     inc     hl
            ld      a, (hl)
            and     a                   ; Проверка на конец строки
            jr      z, sel04e           ; Досрочный выход
            inc     e                   ; Кол-во подкрашиваемых символов++
            cp      '"'
            jr      nz, sel04m          ; Еще не достигли закрытия?
sel04e:     pop     hl                  ; Если да, восстановить HL
            ld      c, CLR_QUOTE        ; Установить цвет
            jr      nextcls             ; И в E будет кол-во символов

; Переход к новой строке
; ----------------------------------------------------------------------
entkint:    ld      a, 13
            rst     $08
            ld      a, 7
            ld      (cursor_attr), a
            jp      terml

; ----------------------------------------------------------------------
; Печать E символов цветом C
; ----------------------------------------------------------------------

nextcl:     ; Выставить цвет (C)
            push    bc
            push    af
            ld      a, c
            ld      (cursor_attr), a
            call    setat
            pop     af

            ; Печать символа (аналог lodsb)
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
            ld      a, CLR_DFLT
            apic    api_cls
            ld      de, hello
            apic    api_print
            ret
