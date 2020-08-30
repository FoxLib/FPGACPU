; ----------------------------------------------------------------------
; Деление DE на BC (16 bit)
; DE: результат
; HL: остаток
; ----------------------------------------------------------------------

; Параметры
div16c:     defb    0                   ; Счетчик битов
div16t:     defb    0, 0                ; Временное сохранение
div16r:     defb    0, 0                ; Результат 16 бит

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
; Перевод unsigned int HL -> float DE:BC
; ----------------------------------------------------------------------

uitof:      ld      a, h
            or      l
            jr      z, uitofz   ; Проверка на ноль
            push    hl
            ld      de, $7e00
            ld      bc, $0000
uitofl:     srl     h           ; Заполнение мантиссы
            rr      l
            rr      e
            rr      b
            rr      c           ; e:b:с мантисса
            inc     d           ; Увеличение порядка
            ld      a, h
            or      l
            jr      nz, uitofl
            ld      a, e        ; Компоновка экспоненты
            and     $7f         ; Срезать скрытый бит
            srl     d           ; Сдвинуть направо
            jr      nc, $+4     ; CF=0, E[7]=0
            or      $80         ; CF=1, E[7]=1
            ld      e, a
            pop     hl
            ret
uitofz:     ld      d, a        ; Обнуление float
            ld      e, a
            ld      b, a
            ld      c, a
            ret

; ----------------------------------------------------------------------
; DE:BC (float) -> HL (uint) Беззнаковый
; В DE:BC остается дробная часть
; ----------------------------------------------------------------------

uftoi:      ld      hl, $0000   ; Первоначальный вид
            ld      a, e
            sla     a
            rl      d           ; D-экспонента
            ld      a, e
            or      $80         ; Восстановить скрытый бит
            ld      e, a
uftoil:     ld      a, d
            cp      $7f
            ret     c           ; Это значение меньше 1, HL=0
            sla     c
            rl      b
            rl      e
            rl      l
            rl      h
            dec     d
            jr      uftoil      ; Повторять пока e >= $7F

; ----------------------------------------------------------------------
; Преобразовать число HL в негативное (HL=-HL), AF=0
; ----------------------------------------------------------------------

negate:     push    de
            ex      de, hl
            xor     a
            ld      h, a
            ld      l, a
            sbc     hl, de
            pop     de
            ret
