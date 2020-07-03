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
echo file_get_contents(__DIR__ . '/macro.asm') . "\n" . join("\n", $rows);


