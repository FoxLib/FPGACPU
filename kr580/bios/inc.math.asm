; ----------------------------------------------------------------------
; Деление DE на BC (16 bit)
; DE-результат | HL-остаток
; ----------------------------------------------------------------------

div16u:     push    af
            push    de
            exx
            pop     hl
            exx
            ld      hl, $0000
            ld      d, h
            ld      e, l
            ld      a, 16
div16ul:    push    af
            exx
            add     hl, hl
            exx
            adc     hl, hl
            sla     e                   ; Сдвиг DE (результата)
            rl      d
            inc     e                   ; Выставить 1 по умолчанию
            xor     a
            sbc     hl, bc
            jr      nc, div16us         ; HL < BC ? Если нет, пропуск
            add     hl, bc              ; Восстановить HL
            dec     e                   ; Убрать 1 -> 0
div16us:    pop     af
            dec     a
            jr      nz, div16ul
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
