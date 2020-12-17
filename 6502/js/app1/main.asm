.org        $3000
            ldx #$ff
            txs                 ; Установка вершины стека
            lda #$17
            jsr CLS

            lda #$00            ; Печать Hello World
            jsr PRN

FIN
            jmp FIN


; ----------------------------------------------------------------------
; ПЕЧАТЬ СТРОКИ НОМЕР (ACC) В РЕЖИМЕ ТЕЛЕТАЙПА
; Строка выбирается из набора STRINGS
; ----------------------------------------------------------------------

PRN
            asl a           ; w0 = 2*A
            sta <$00
            lda #$00
            rol a
            sta <$01
            lda #<STRINGS   ; w0 = STRINGS + 2*A, CF=0
            adc <$00
            sta <$00
            lda #>STRINGS
            adc <$01
            sta <$01
            ldy #$00        ; Копирование указателя на строку
            lda ($00),y     ; $00 -> $02
            sta <$02
            iny
            lda ($00),y
            sta <$03
            ldy #$00
            lda CURSORL     ; ADDR = 0x2000 | CURSOR
            sta <$00
            lda CURSORH
            ora #$20
            sta <$01
PRN3                        ; Пропечатать строку
            lda ($02),y     ; Прочесть следующий символ
            beq PRN1
            sta ($00),y     ; Символ
            iny
            lda CURSORC
            sta ($00),y     ; Цвет
            inc <$00
            bne PRN3
            inc <$01
            jmp PRN3
PRN1
            lda <$00
            sta CURSORL
            lda <$02
            and #$DF        ; Удалить 20h
            sta CURSORH
            rts

; ----------------------------------------------------------------------
; ОЧИСТКА ЭКРАНА В ОПРЕДЕЛЕННЫЙ ЦВЕТ (ACC)
; Изменяются A, Y [00-01]
; На выходе  A=$30, Y=$00
; ----------------------------------------------------------------------

CLS
            sta CURSORC         ; Сохранить цвет
            ldy #$00
            sty <$00
            lda #$20
            sta <$01            ; Загрузить DI=$2000 в 00h
CLS1                            ; DO
            lda #$00
            sta ($00),y         ; [DI++] = 0
            iny
            lda CURSORC         ; Загрузить цвет
            sta ($00),y         ; [DI++] = [02h]
            iny
            bne CLS1            ; LOOP WHILE DI != 0
            inc <$01            ; DI += 100h
            lda <$01
            cmp #$30            ; LOOP WHILE DI != 0x3000
            bne CLS1
            sty CURSORL
            sty CURSORH         ; H:L=0
            rts

; ----------------------------------------------------------------------
; ОБЪЯВЛЕНИЕ ДАННЫХ В ПАМЯТИ ДЛЯ ПРОЦЕДУР
; ----------------------------------------------------------------------

CURSORL
.byte       0x00        ; +0 x
CURSORH
.byte       0x00        ; +1 y
CURSORC
.byte       0x00        ; +2 color

; Объявление строк
; ----------------------------------------------------------------------
STRINGS
.leshort    S0

S0
.tas        'Hello Worldart!'
