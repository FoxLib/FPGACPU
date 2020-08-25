
cursor_xy:      defb    0, 0            ; Текущее положение курсора
cursor_attr:    defb    0               ; Текущий цветовой атрибут

; ----------------------------------------------------------------------
; Процедура очистки экрана, в регистре A атрибут
; ----------------------------------------------------------------------

cls:    ld      hl, $4000
        ld      b, $00
        ld      c, a
        ld      (cursor_attr), a
p1m1:   ld      (hl), b
        inc     l
        jr      nz, p1m1
        inc     h
        ld      a, h
        cp      $5B
        ret     z
        cp      $58
        jr      nz, p1m1
        ld      b, c
        jr      p1m1

; ----------------------------------------------------------------------
; Печать символа A, позиция B=Y, C=X
; ----------------------------------------------------------------------

prn:    push    hl
        push    de
        push    bc

        ; Вычисление позиции символа в таблице символов
        sub     a, $20
        ld      h, 0
        ld      l, a
        add     hl, hl
        add     hl, hl
        add     hl, hl
        ld      de, fonts
        add     hl, de
        ex      de, hl

        ; Расчет позиции HL
        ld      a, c
        and     0x1F
        ld      l, a    ; L = X & 31
        ld      a, b
        and     0x07    ; Нужно ограничить 3 битами
        rrca            ; Легче дойти с [0..2] до позиции [5..7]
        rrca            ; Если вращать направо
        rrca            ; ... три раза
        or      l       ; Объединив с 0..4 уже готовыми ранее
        ld      l, a    ; Загрузить новый результат в L
        ld      a, b    ; Т.к. Y[3..5] уже на месте
        and     0x18    ; Его двигать даже не надо
        or      0x40    ; Ставим видеоадрес $4000
        ld      h, a    ; И загружаем результат

        ; Рисование
        ld      b, 8
p2m1:   ld      a, (de)
        ld      (hl), a
        inc     de
        inc     h
        djnz    p2m1

        pop     bc
        pop     de
        pop     hl
        ret

; ----------------------------------------------------------------------
; Вычисление 32*Y + X -> HL, AF затронуто
; ----------------------------------------------------------------------

attrpl: push    de
        ld      hl, (cursor_xy)
        ld      e, l
        ld      l, h
        ld      d, 0
        ld      h, 0
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl      ; 32*Y
        add     hl, de      ; HL = 32*Y + X
        ld      a, h
        add     $58
        ld      h, a
        pop     de
        ret

; ----------------------------------------------------------------------
; Ставится атрибут в позицию курсора
; ----------------------------------------------------------------------

setat:  push    af
        push    hl
        call    attrpl
        ld      a, (cursor_attr)
        ld      (hl), a
        pop     hl
        pop     af
        ret

; ----------------------------------------------------------------------
; Печать символа A в режиме телетайпа с прокруткой вверх
; ----------------------------------------------------------------------

prnt:   push    bc
        push    de
        push    hl

        ; Текущая позиция курсора
        ld      hl, (cursor_xy) ; Текущий курсор -> BC
        ld      b, h
        ld      c, l
        cp      13              ; ENTER?
        jr      z, p3m2

        call    setat           ; Установка атрибута
        call    prn             ; Печать символа

        inc     l
        ld      a, l
        cp      $20
        jr      nz, p3m1        ; Достиг правого края
p3m2:   ld      l, $00
        inc     h
        ld      a, h
        cp      $18             ; Достиг нижней границы
        jr      nz, p3m1

            ; @todo scroll up

p3m1:   ld      (cursor_xy), hl
        pop     hl
        pop     de
        pop     bc
        ret

; ----------------------------------------------------------------------
; Печать строки из DE в режиме телетайпа
; ----------------------------------------------------------------------

prns:   ld      a, (de)
        inc     de
        and     a
        ret     z
        call    prnt
        jr      prns

; ШРИФТЫ
fonts:  incbin  "font.fnt"
