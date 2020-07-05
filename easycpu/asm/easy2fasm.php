<?php

$filename = isset($argv[1]) ? $argv[1] : '';

// Детект
if ($filename && $filename[0] == '-') {
    $filename = substr($filename, 1);
    $no_macro = true;
}

$dir = __DIR__;

// Загрузка файла
$rows = [];
$list = load_stream($filename);
foreach ($list as $row) {

    // Компиляция include
    if (preg_match('~include\s"(.+)"~i', $row, $c)) {

        $sfile = preg_replace("~\.asm~i", '.s', $c[1]);
        $comm  = "php $dir/easy2fasm.php -".$c[1]." > ".$sfile;
        `$comm`;
    }
}

// Замена инструкции
foreach ($list as $row) {

    // MOV a, b
    if (preg_match('~mov\s(.+),(.+)~i', $row, $c)) {

        $rows[] = str_replace($c[0], '', $row);
        $rows[] = "    LDA " . trim($c[2]);
        $rows[] = "    STA " . trim($c[1]);
    }
    // SHL a
    elseif (preg_match('~shl\s(.+)~i', $row, $c)) {

        $rows[] = str_replace($c[0], '', $row);
        $rows[] = "    LDA " . trim($c[1]);
        $rows[] = "    ADD " . trim($c[1]);
        $rows[] = "    STA " . trim($c[1]);
    }
    // SHR a
    elseif (preg_match('~shr\s(.+)~i', $row, $c)) {

        $rows[] = str_replace($c[0], '', $row);
        $rows[] = "    LDA " . trim($c[1]);
        $rows[] = "    SHR";
        $rows[] = "    STA " . trim($c[1]);
    }
    else if (preg_match('~(add|and|xor|ora)\s(.+),(.+)~i', $row, $c)) {

        $rows[] = str_replace($c[0], '', $row);
        $rows[] = "    LDA " . trim($c[3]);
        $rows[] = "  ".$c[1]." ".$c[2];
        $rows[] = "    STA " . trim($c[2]);
    }
    else if (preg_match('~(push|pop)\s(.+)~i', $row, $c)) {
        foreach (preg_split("~\s+~", trim($c[2])) as $m) {
            $rows[] = "    ".$c[1]." " . $m;
        }
    }
    else {
        $rows[] = $row;
    }
}

// Выполнение преобразования
foreach ($rows as $id => $row) {

    // $row = iconv("utf8", "cp866", $row); // сделать вручную

    if (preg_match('~include\s"(.+)"~i', $row, $c)) {

        $sfile = preg_replace("~\.asm~i", '.s', $c[1]);
        $row   = str_replace($c[0], 'include "'.$sfile.'"', $row);
    }
    else if (preg_match('~ldi\s+r(\d+),(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_LDI '.$c[1].','.$c[2], $row);
    }
    else if (preg_match('~(lda|sta)\s+\[r(\d+)\]~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).'_MEM '.$c[2], $row);
    }
    else if (preg_match('~(add|sub|and|xor|ora|inc|dec|lda|sta|push|pop)\s+r(\d+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).'_REG '.$c[2], $row);
    }
    else if (preg_match('~jmp\s+(nc|c|nz|z),(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_JMP_'.strtoupper($c[1]).' '.$c[2], $row);
    }
    else if (preg_match('~(jmp|call)\s+(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).' '.$c[2], $row);
    }
    else if (preg_match('~bra\s+(nc|c|nz|z),(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_BRA_'.strtoupper($c[1]).' '.$c[2], $row);
    }
    else if (preg_match('~bra\s+(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_BRA '.$c[1], $row);
    }
    else if (preg_match('~(lda|sta)\s+\[(.+)\]~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_'.strtoupper($c[1]).'_IMMEM '.$c[2], $row);
    }
    else if (preg_match('~lda\s+(.+)~i', $row, $c)) {
        $row = str_replace($c[0], 'INS_LDA_I16 '.$c[1], $row);
    }
    else if (preg_match($pat = '~\b(shr|swap|ret|brk|cli|sti|reti|clh)\b~i', $row)) {
        $row = preg_replace_callback($pat, function($e) { return 'INS_' . strtoupper($e[1]); }, $row);
    }

    $rows[$id] = $row;
}

// Не включать макросы
echo (empty($no_macro) ?  macroasm()."\n" : '') . join("\n", $rows);

// ---------------------------------------------------------------------
// Функции и определения
// ---------------------------------------------------------------------

function load_stream($filename) {

    $rows = [];
    $fp = @fopen($f = $filename ?: "php://stdin", "r");
    while ($fp && !feof($fp)) {
        $row = rtrim(fgets($fp));
        if (ltrim($row)) $rows[] = $row;
    }
    @fclose($fp);
    return $rows;
}

function macroasm() {

return
"macro INS_LDI _r, _d { db _r\ndw _d }
macro INS_LDA_I16 _d  { db 0x13\ndw _d }
macro INS_LDA_IMMEM _d { db 0x10\ndw _d }
macro INS_STA_IMMEM _d { db 0x11\ndw _d }
macro INS_BRA _a     { db 0x80\ndb (_a - 1) - $ }
macro INS_JMP _a     { db 0x81\ndw _a }
macro INS_CALL _a    { db 0x15\ndw _a }
macro INS_JMP_NC _a  { db 0x82\ndw _a }
macro INS_JMP_C _a   { db 0x83\ndw _a }
macro INS_JMP_NZ _a  { db 0x84\ndw _a }
macro INS_JMP_Z _a   { db 0x85\ndw _a }
macro INS_BRA_NC _a  { db 0x8A\ndb (_a - 1) - $ }
macro INS_BRA_C _a   { db 0x8B\ndb (_a - 1) - $ }
macro INS_BRA_NZ _a  { db 0x8C\ndb (_a - 1) - $ }
macro INS_BRA_Z _a   { db 0x8D\ndb (_a - 1) - $ }
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
macro INS_PUSH_REG _r { db 0xE0 + _r }
macro INS_POP_REG _r  { db 0xF0 + _r }
macro INS_SHR        { db 0x12 }
macro INS_SWAP       { db 0x14 }
macro INS_RET        { db 0x16 }
macro INS_BRK        { db 0x17 }
macro INS_RETI       { db 0x18 }
macro INS_CLI        { db 0x19 }
macro INS_STI        { db 0x1A }
macro INS_CLH        { db 0x1B }
";
}
