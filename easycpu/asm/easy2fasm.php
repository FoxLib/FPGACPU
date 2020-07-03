<?php

include "functions.php";

$filename = isset($argv[1]) ? $argv[1] : '';
$rows = load_stream($filename);

foreach ($rows as $id => $row) {

    $row = iconv("utf8", "cp866", $row);

    if (preg_match('~ldi\s+r(\d+),(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_LDI '.$c[1].','.$c[2], $row);
    } else if (preg_match('~(lda|sta)\s+\[r(\d+)\]~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).'_MEM '.$c[2], $row);
    } else if (preg_match('~(lda|sta)\s+r(\d+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).'_REG '.$c[2], $row);
    } else if (preg_match('~(add|sub|and|xor|ora|inc|dec)\s+r(\d+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).'_REG '.$c[2], $row);
    } else if (preg_match('~jmp\s+(nc|c|nz|z),(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_JMP_'.strtoupper($c[1]).' '.$c[2], $row);
    } else if (preg_match('~(jmp|call)\s+(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).' '.$c[2], $row);
    } else if (preg_match('~bra\s+(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_BRA '.$c[1], $row);
    } else if (preg_match('~(lda|sta)\s+\[(.+)\]~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).'_IMMEM '.$c[2], $row);
    } else if (preg_match('~lda\s+(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_LDA_I16 '.$c[1], $row);
    } else if (preg_match($pat = '~\b(shr|swap|ret|brk)\b~i', $row)) {
        $row = preg_replace_callback($pat, function($e) { return 'INS_' . strtoupper($e[1]); }, $row);
    }

    $rows[$id] = $row;
}

// echo "include 'macro.asm'\n" . join("\n", $rows);
echo macroasm() . "\n" . join("\n", $rows);

function load_stream($filename) {

    $fp = fopen($f = $filename ?: "php://stdin", "r");
    $rows = [];
    while (!feof($fp)) {
        $row = rtrim(fgets($fp));
        if (ltrim($row)) $rows[] = $row;
    }
    fclose($fp);
    return $rows;
}

function macroasm() {

return "macro INS_LDI _r, _d {
    db _r
    dw _d
}
macro INS_LDA_I16 _d {
    db 0x13
    dw _d
}
macro INS_LDA_IMMEM _d {
    db 0x10
    dw _d
}
macro INS_STA_IMMEM _d {
    db 0x11
    dw _d
}
macro INS_BRA _a {
    db 0x80
    db (_a - 1) - $
}
macro INS_JMP _a {
    db 0x81
    dw _a
}
macro INS_CALL _a {
    db 0x15
    dw _a
}
macro INS_JMP_NC _a {
    db 0x82
    dw _a
}
macro INS_JMP_C _a {
    db 0x83
    dw _a
}
macro INS_JMP_NZ _a {
    db 0x84
    dw _a
}
macro INS_JMP_Z _a {
    db 0x85
    dw _a
}
macro INS_LDA_MEM _r { db 0x20 + _r }
macro INS_STA_MEM _r { db 0x30 + _r }
macro INS_LDA_REG _r { db 0x40 + _r }
macro INS_STA_REG _r { db 0x50 + _r }
macro INS_ADD_REG _r { db 0x60 + _r }
macro INS_SUB_REG _r { db 0x70 + _r }
macro INS_AND_REG _r { db 0x90 + _r }
macro INS_XOR_REG _r { db 0xA0 + _r }
macro INS_ORA_REG _r { db 0xB0 + _r }
macro INS_INC_REG _r { db 0xC0 + _r }
macro INS_DEC_REG _r { db 0xD0 + _r }
macro INS_SHR        { db 0x12 }
macro INS_SWAP       { db 0x14 }
macro INS_RET        { db 0x16 }
macro INS_BRK        { db 0x17 }";
}
