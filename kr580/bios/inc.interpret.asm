testing:    defb " 10 PRINT",0

; ----------------------------------------------------------------------
; Модуль интерпретатора строк из HL
; Разбор и встраивание новой строки в программу
; Запуск строки, исполнение
; ----------------------------------------------------------------------

interpret:  ; Сначала отсеять пробелы и цифры вначале
ipl:        ld      a, (hl)
            inc     hl
            cp      ' '
            jr      z, ipl      ; Пробел
            cp      '0'
            jr      c, ips      ; Если A < '0' Продолжить
            cp      '9'+1
            jr      c, ipl      ; Если A = 0..9 Пропуск

            ; Найти команды из набора `commands`
ips:        dec     hl
            ld      de, commands

halt

ipnx:       ; Искать следуюшую команду
            ld      a, (de)
            and     a
            jr      z, next_1   ; Команда не была найдена?
            ld      b, a        ; B=длина команды
            push    hl
            push    de
            inc     de          ; Перейти к тексту команды
ipcp:       ld      a, (de)
            ld      c, a
            ld      a, (hl)
            and     a
            jr      z, ipn      ; Конец строки
            inc     hl
            inc     de
            cp      c
            jr      nz, ipn
            djnz    ipcp

            ; Команда подошла, проверить, что команда закончена
            ld      a, (hl)
            cp      'A'
            jr      c, ipcmok
            cp      'Z'+1
            jr      nc, ipcmok

            ; Команда не подошла
ipn:        pop     de
            call    ipnexde
            pop     hl
            jr      ipnx

            ; Вычислить адрес команды и вызвать
ipcmok:     pop     de
            pop     hl
            call    ipnexde
            dec     de
            dec     de              ; DE -= 2
            ld      a, (de)
            ld      c, a
            inc     de
            ld      a, (de)
            ld      d, a
            ld      e, c            ; DE-процедура
            ex      de, hl
            jp      (hl)            ; DE-указатель на аргументы
            ret

            ; Вычисление следующей табличной команды DE -> DE
ipnexde:    ld      a, (de)
            add     3
            ld      h, 0
            ld      l, a            ; HL = HL + size + 3
            add     hl, de
            ex      de, hl
            ret

; ----------------------------------------------------------------------
; Найти выражение VAR = EXPR
; ----------------------------------------------------------------------

next_1:     jr      $
