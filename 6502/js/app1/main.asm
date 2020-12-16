.org        $3000

; -------------------------------- очистка экрана
            ldy #$00
            sty <$00
            lda #$20
            sta <$01
L3
            lda #$41
            sta ($00),y
            iny
            lda #$17
            sta ($00),y
            iny
            bne L3
            inc <$01
            lda <$01
            cmp #$30
            bne L3
L2
            jmp L2

; Список меток LittleEndian
.leshort    L1

; Метка
L1
.tas        'Hello, World!'
