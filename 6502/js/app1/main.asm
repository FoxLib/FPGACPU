
            lda <L1     ; Нижний байт L1
            lda >L1     ; Старший байт L1
            lda #$12    ; Immediate
            lda <$22    ; ZeroPage
            sta $1234   ; Absolute

; Список меток LittleEndian
.leshort    L1

; Метка
L1
.tas        'Hello, World!'
