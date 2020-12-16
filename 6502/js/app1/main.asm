.org        $3000

            lda #$41
            sta $2000
            lda #$07
            sta $2001
L2
            jmp L2

; Список меток LittleEndian
.leshort    L1

; Метка
L1
.tas        'Hello, World!'
