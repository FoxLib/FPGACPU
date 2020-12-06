.text
.global _start

_start:

    mov     r0, #0xb8000
    mov     r1, #0
L1:
    //; for (i = 0xb8000; i < 0xc0000; i++) mem[i] = i
    strb    r1, [r0, r1]
    add     r1, #1
    cmp     r1, #0xc0000
    bne     L1
L2:
    b       L2

