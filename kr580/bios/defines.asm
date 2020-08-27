; ----------------------------------------------------------------------
; Список запросов к RST #10
;
;   rst     $10
;   defb    <номер функции>
; ----------------------------------------------------------------------

api_getcursor:      equ 0
api_setcursor:      equ 1
api_cls:            equ 2
api_print:          equ 3
api_itoa:           equ 4
api_read:           equ 5
api_write:          equ 6
api_div16u:         equ 7
