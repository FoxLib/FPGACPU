
; ----------------------------------------------------------------------
; Вычисление выражения HL
; DE-результат выражения
; ----------------------------------------------------------------------

; Уровень 1: Минус, плюс и логические операции
; ----------------------------------------------------------------------
expr_init:  ld      de, 0
expr:       call    expr1           ; Левая часть
expr_n:     ld      a, (hl)
            cp      '+'
            jr      z, e_plus
            cp      '-'
            jr      z, e_minus
            cp      '|'
            ;jr     z, e_or
            cp      '&'
            ;jr     z, e_and
            cp      '^'
            ;jr     z, e_xor
            ret                     ; Завершение разбора

; Операция сложения
e_plus:     inc     hl
            push    de
            call    expr1           ; Вычисление правой части
            pop     bc
            ex      de, hl
            add     hl, bc
            ex      de, hl          ; DE = left + right
            jr      expr_n          ; К следующей части

; Операция вычитания
e_minus:    inc     hl
            push    de
            call    expr1           ; DE -> BC, DE - 2-й операнд
            pop     bc
            push    hl
            push    bc
            pop     hl              ; HL=BC
            xor     a
            sbc     hl, de
            ex      de, hl
            pop     hl              ; DE=BC-DE
            jr      expr_n

; Уровень 2: Умножение, деление, модуль
; ----------------------------------------------------------------------

expr1:      call    expr2           ; Левая часть
expr1_n:    ld      a, (hl)
            cp      '*'
            jr      z, e1_mul
            cp      '/'
            jr      z, e1_div
            cp      '%'
            jr      z, e1_mod
            ret                     ; Операторы не обнаружены

; Деление с получением целого
e1_div:     call    e1_divmod
            push    hl
            call    div16u
            pop     hl
            jr      expr1_n

; Деление и получение модуля
e1_mod:     call    e1_divmod
            push    hl
            call    div16u
            ex      de, hl
            pop     hl
            jr      expr1_n

; Умножение
e1_mul:     inc     hl
            push    de
            call    expr2           ; DE-умножатор
            pop     bc
            push    hl
            call    mul16u          ; DE = DE*BC
            pop     hl
            jr      expr1_n

; Общая процедура для деления и модуля
e1_divmod:  inc     hl
            push    de
            call    expr2
            push    de
            pop     bc
            pop     de              ; SWAP BC, DE
            ret

; Уровень 3
; ----------------------------------------------------------------------

expr2:      call    spaces          ; Убрать лидирующие пробелы
            ld      a, (hl)
            inc     hl
            cp      '('
            jr      nz, expr2_1     ; Это открытая скобка?
            call    expr            ; Если скобка открыта, выполнить
            ld      a, (hl)
            cp      ')'
            jr      nz, expr_eprt   ; Ошибка завершения скобок!
            inc     hl
            jr      spaces          ; Удалить пробелы и выйти с 3-уровня

            ; Проверка на VAR|DIGIT
expr2_1:    cp      '-'
            jr      z, expr2_1m     ; Отрицательное число
            cp      'A'
            jr      c, expr2_1n     ; Не принадлежит A..Z
            cp      'Z'+1
            jr      c, expr2_1v     ; Принадлежит A..Z
expr2_1n:   cp      '0'
            jr      c, expr2_1u     ; Неизвестно что это
            cp      '9'+1
            jr      nc, expr2_1u
            dec     hl
            call    atoi            ; Это число --> DE
            jr      spaces          ; Убрать пробелы и выйти из процедуры

expr2_1v:   ; @TODO поиск переменной
            halt
            jr      spaces

            ; Это отрицательное число
expr2_1m:   ld      de, 0
            dec     hl
            ret

            ; Ошибка выражения, выход с нулем
expr2_1u:   halt

; Пропуск пробелов во входящей строке
spaces:     ld      a, (hl)
            cp      ' '
            ret     nz
            inc     hl
            jr      spaces

; ----------------------------------------------------------------------
expr_eprt:  halt

expr_error: ; ОШИБКА ВЫРАЖЕНИЯ
            halt
            jr      $
