
; ----------------------------------------------------------------------
; Деление DE на BC
; HL: результат
; DE: остаток
; ----------------------------------------------------------------------

; Параметры
div16c:         defb    0                   ; Счетчик битов
div16t:         defb    0, 0                ; Временное сохранение
div16r:         defb    0, 0                ; Результат 16 бит

; Процедура
div16u: push    af
        push    bc

        ; Обнулить результат
        ld      hl, $0000
        ld      (div16r), hl
        ld      a, 16
        ld      (div16c), a

        ; Инвертировать BC = -BC
        xor     a
        sub     c
        ld      c, a
        ld      a, 0
        sbc     a, b
        ld      b, a

        ; Сдвиг результата (16 бит)
p5m8:   push    hl
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
        jr      c, p5m7         ; HL >= BC

        ; Вычесть не получилось
        ld      hl, (div16r)
        dec     hl              ; Убрать единицу в бите 0 результата
        ld      (div16r), hl
        ld      hl, (div16t)    ; Вернуть назад HL

        ; Повторить 16 раз
p5m7:   ld      a, (div16c)
        dec     a
        ld      (div16c), a
        jr      nz, p5m8

        ; Загружаем результаты
        ex      de, hl
        ld      hl, (div16r)

        pop     bc
        pop     af
        ret

; ----------------------------------------------------------------------
; Деление 24 битных чисел
; ----------------------------------------------------------------------

; Параметры
d1m1:           defb    0, 0, 0,   0, 0, 0    ; Делимое
d1m2:           defb    0, 0, 0               ; Делитель или число
d1m3:           defb    0, 0, 0               ; Результат

; Процедура
div24u:

        ; Очистить результат d1m3
        xor     a
        ld      hl, d1m3
        ld      (hl), a
        inc     hl
        ld      (hl), a
        inc     hl
        ld      (hl), a

        ; Вычисление 24 битов
        ld      b, 24
p5m5:   push    bc
        ld      b, 6                ; Сдвиг делимого на 1 влево
        ld      hl, d1m1
        call    mul2
        ld      b, 3                ; Сдвинуть результат
        ld      hl, d1m3
        call    mul2
        inc     (hl)
        ld      b, 3                ; Рассчитать разность
        ld      de, d1m1+3
        ld      hl, d1m2
        call    subtr
        jr      nc, p5m4            ; Оставить бит
        ld      b, 3
        call    addst               ; Вернуть назад
        ld      hl, d1m3
        dec     (hl)                ; Обнулить бит
p5m4:   pop     bc
        djnz    p5m5
        ret

; ----------------------------------------------------------------------
; Умножить число (HL) на 2, B=кол-во байт
; ----------------------------------------------------------------------

mul2:   xor     a               ; CF=0
        push    hl
p5m1:   ld      a, (hl)
        rla
        ld      (hl), a
        inc     hl
        djnz    p5m1
        pop     hl
        ret

; ----------------------------------------------------------------------
; Вычесть число (DE) - (HL) => (DE), B=кол-во байт
; Сложить число (DE) + (HL) => (DE), B=кол-во байт
; Carry Flag имеет значение на выходе
; ----------------------------------------------------------------------

; ВЫЧЕСТЬ
subtr:  xor     a
        push    de
        push    hl
p5m2:   ld      a, (de)
        sbc     a, (hl)
        ld      (de), a
        inc     hl
        inc     de
        djnz    p5m2
        jr      p5m6            ; Экономия 1 байта o_O

; СЛОЖИТЬ
addst:  xor     a
        push    de
        push    hl
p5m3:   ld      a, (de)
        adc     a, (hl)
        ld      (de), a
        inc     hl
        inc     de
        djnz    p5m3
p5m6:   pop     hl
        pop     de
        ret

; ----------------------------------------------------------------------
; Сделать число (HL) отрицательным, B=3 кол-во байт
; ----------------------------------------------------------------------

negate: ld      c, 1       ; C=1 перенос
p4m1:   ld      a, (hl)
        cpl
        add     c
        ld      (hl), a
        inc     hl
        ld      c, 0
        jr      nc, $+3
        inc     c
        djnz    p4m1
        ret
