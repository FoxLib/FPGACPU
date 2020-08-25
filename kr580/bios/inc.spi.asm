; ОШИБКИ SD
; =========
;
;   #1 Нет ответа от команды
;   #2 От команды не получен BSY=0
;   #3 Неправильный ответ от IDLE инициализации
;
; ТИП КАРТЫ
; =========
;
;   #0 Неизвестный
;   #1 SDv1
;   #2 SDv2
;   #3 SDHC

sd_type:    defb    0               ; Тип карты

; ----------------------------------------------------------------------
; Отослать команду A на SPI и ожидать пока устройство не закончит работу
; ----------------------------------------------------------------------

spicmd:     push    af
            out     ($f1), a        ; Установка номера команды
            xor     a
            out     ($f2), a        ; 0
            inc     a
            out     ($f2), a        ; 1
            xor     a
            out     ($f2), a        ; 0
S7:         in      a, ($f1)        ; spi status байт
            and     $01
            jr      nz, S7          ; Ожидание разблокировки
            pop     af
            ret

; ----------------------------------------------------------------------
; Прием/чтение данных из SPI в/из регистр(а) A
; ----------------------------------------------------------------------

spiget:     ld      a, $ff
            out     ($f0), a        ; spi_data = FF
            ld      a, 1            ; CMDGET
            call    spicmd          ; Отослать и принять данные
            in      a, ($f0)
            ret

spiput:     push    af
            out     ($f0), a        ; Выставить данные
            ld      a, 1
            call    spicmd          ; Отослать команду
            pop     af
            ret

; ----------------------------------------------------------------------
; Отсылка команды A с аргументом  [HL:DE] (32 битное число)
; Если A==0, то ответ команды валидный, и тогда в B будет ответ
;      A<>0, то будет код ошибки
; ----------------------------------------------------------------------

spicommand_cmd:     defb 0
spicommand_arg:     defb 0, 0, 0, 0

spicommand:

            ; Сохранить аргумент и команду
            ld      (spicommand_cmd), a
            ld      (spicommand_arg+2), hl
            ld      h, d
            ld      l, e
            ld      (spicommand_arg), hl
            ex      af, af'

            ; CE=0 Включить чип
            ld      a, 2
            call    spicmd

            ; Принимать байты, пока не будет 0xFF
            ld      de, 4096
S1:         call    spiget
            cp      $ff
            jr      z, S2
            dec     de
            ld      a, d
            or      e
            jr      nz, S1
            ld      a, 1        ; Ошибка #1
            ret

S2:         ; Отсылка команды к SD
            ex      af, af'
            or      $40
            call    spiput

            ; Отослать 32-х битный аргумент (BigEndian)
            ld      hl, spicommand_arg+3
            ld      b, 4
S3:         ld      a, (hl)
            dec     hl
            call    spiput
            djnz    S3

            ; Вычислить и отправить CRC
            ld      a, (spicommand_cmd)
            ld      b, 0x95     ; CRC
            cp      $00         ; SD_CMD0
            jr      z, S4
            ld      b, 0x87     ; SD_CMD8 (и другие)
S4:         ld      a, b
            call    spiput

            ; Ждать снятия флага BSY
            ld      de, 255
            ld      b, 0
S5:         call    spiget
            ld      b, a
            and     $80
            jr      z, S6       ; Ответ пришел BSY=0
            dec     de
            ld      a, d
            or      e
            jr      nz, S5
            ld      a, 2        ; Error #2 Не дождались ответа
S6:         ret                 ; Если ответ валидный, A=0

; Вспомогательная команда ACMD(cmd, arg)
spiacmd:    push    af
            push    de
            push    hl
            ld      de, $0000
            ld      h, d
            ld      l, e
            ld      a, 55       ; SD_CMD55
            call    spicommand
            pop     hl
            pop     de
            pop     af
            call    spicommand  ; Запрошенная команда
            ret

; ----------------------------------------------------------------------
; Инициализация устройства SD, определить тип карты, включить в работу
; ----------------------------------------------------------------------

sdinit:
            ; Включение устройства
            xor     a
            ld      (sd_type), a
            call    spicmd

            ; Тест на возможность войти в IDLE (CMD0, ARG=0)
            ld      a,  0
            ld      hl, 0
            ld      de, 0
            call    spicommand
            and     a
            jp      nz, _siend          ; Статус должен быть 0
            ld      a, b
            cp      $01
            jp      nz, _sierr2         ; Ответ должен быть 1

            ; Определить тип карты (SD1)
            ld      a,  8
            ld      hl, 0x0000
            ld      de, 0x01AA
            call    spicommand
            and     a
            jr      nz, _siend          ; Статус должен быть 0

            ; Тест на тип карты SD1
            ld      hl, $0000           ; Для аргумента ACMD
            ld      a, 1
            ld      (sd_type), a        ; Отметить что это SD1
            ld      a, b
            and     $04                 ; & R1_ILLEGAL_COMMAND
            jr      nz, S8              ; Если есть этот бит, то это SD1

            ; Это SD2? Проверить последний байт, чтобы убедиться
            call    spiget
            call    spiget
            call    spiget
            call    spiget
            cp      $AA                 ; Должен быть $AA
            jr      nz, _sierr2         ; Если нет, то ошибка #3
            ld      a, 2
            ld      (sd_type), a        ; Все верно, ставим SD2
            ld      hl, $4000           ; Только для SD2

            ; Отсылать команду 0x29
S8:         ld      bc, 4096
S9:         push    bc
            push    hl
            ld      a, 0x29             ; SD_CMD41
            ld      de, 0
            call    spiacmd
            ld      e, b                ; Временно записать B => E
            pop     hl
            pop     bc
            and     a
            jr      nz, _siend          ; Возникла ошибка?
            ld      a, e
            and     a                   ; Проверка на R1_READY_STATE
            jr      z, S10              ; Если A=0, успешно
            dec     bc
            ld      a, b
            or      c
            jr      nz, S9              ; Повторять несколько раз
            jr      _sierr2             ; Если достигли максимума

S10:        ; Проверка наличия SDHC
            ld      a, (sd_type)
            cp      $2                  ; Если это не SD2, пропуск
            jr      nz, S11

            ; Проверка наличия байта в ответе CMD58 (должно быть 0)
            ld      de, $0000
            ld      h, d
            ld      l, e
            ld      a, 58
            call    spicommand
            and     a
            jr      nz, _siend          ; Если статус не 0, ошибка
            ld      a, b
            and     a
            jr      nz, _sierr2         ; Должен быть 0

            ; Прочесть ответ от карты и определить тип (SDHC если есть)
            call    spiget
            and     $c0
            cp      $c0
            jr      nz, _sierr2         ; Старшие 2 бита не получены!
            call    spiget              ; Удалить остатки
            call    spiget
            call    spiget
            ld      a, 3            ; Это SDHC
            ld      (sd_type), a
S11:        xor     a
            jr      _siend          ; Все ОК
_sierr2:    ld      a, 3
_siend:     ; Выход с ошибкой или без. Отключить чип.
            push    af
            ld      a, 3
            call    spicmd
            pop     af
            ret
