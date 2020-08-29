; ----------------------------------------------------------------------
; Деление DE на BC (16 bit)
; DE: результат
; HL: остаток
; ----------------------------------------------------------------------

; Параметры
div16c:         defb    0                   ; Счетчик битов
div16t:         defb    0, 0                ; Временное сохранение
div16r:         defb    0, 0                ; Результат 16 бит

; Процедура
div16u:     push    af
            push    bc

            ; Обнулить результат
            ld      a, 16
            ld      hl, $0000
            ld      (div16r), hl
            ld      (div16c), a

            ; Инвертировать BC = -BC
            xor     a
            sub     c
            ld      c, a
            ld      a, 0
            sbc     a, b
            ld      b, a

            ; Сдвиг результата (16 бит)
d16u1:      push    hl
            ld      hl, (div16r)
            add     hl, hl
            inc     hl
            ld      (div16r), hl
            pop     hl

            ; Сдвиг HL:DE (32 бита)
            xor     a
            ex      de, hl
            add     hl, hl
            ex      de, hl
            adc     a, a
            add     hl, hl
            add     l
            ld      l, a

            ; Попробовать вычесть
            ld      (div16t), hl    ; Сохранить в случае если HL меньше BC
            add     hl, bc
            jr      c, d16u2        ; HL >= BC

            ; Вычесть BC из HL не получилось
            ld      hl, (div16r)
            dec     hl              ; Убрать единицу в бите 0 результата
            ld      (div16r), hl
            ld      hl, (div16t)    ; Вернуть назад HL

            ; Повторить 16 раз
d16u2:      ld      a, (div16c)
            dec     a
            ld      (div16c), a
            jr      nz, d16u1

            ; Загружаем результаты
            ex      de, hl
            ld      hl, (div16r)    ; На самом деле тут DE=результат
            ex      de, hl          ; А HL остается остатком от деления

            pop     bc
            pop     af
            ret

; ----------------------------------------------------------------------
; Перевод int HL -> float HL:DE
; ----------------------------------------------------------------------
itof_sign:  defb    0

itof:       ; Проверка на HL=0 (особый случай)
            ld      a, h
            or      l
            jr      z, itofz

            xor     a
            ld      (itof_sign), a

            ; Если знак положительный, продолжить
            ld      a, h
            and     $80
            jr      z, itofns

            ; Сделать число HL позитивным
            xor     a
            ex      de, hl
            ld      h, a
            ld      l, a
            sbc     hl, de
            ld      a, $80
            ld      (itof_sign), a

            ; Выполнить нормализацию
itofns:     push    bc
            ld      de, $0000
            ld      bc, $007f

            ; Заполнение мантиссы
itofl:      srl     h
            rr      l
            rr      d
            rr      e
            rr      b           ; d:e:b мантисса
            inc     c           ; Увеличение порядка
            ld      a, h
            or      l
            jr      nz, itofl

itofe:      ; Компоновка числа
            ld      a, d
            and     $7f         ; Срезать скрытый бит
            ld      l, a
            ld      d, e
            ld      e, b
            xor     a
            srl     c
            rra
            or      l           ; Поместить младший бит экспоненты в 8-й бит L
            ld      l, a
            ld      h, c

            ; Установка знака
            ld      a, (itof_sign)
            or      h
            ld      h, a
            pop     bc
            ret
itofz:      ret
