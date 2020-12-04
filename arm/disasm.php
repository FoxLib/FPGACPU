<?php

$bin = file_get_contents("main");
$prg = unpack("V*", $bin);

$condition = ["eq", "ne", "cs", "cc", "mi", "pl", "vs", "vc", "hi", "ls", "ge", "lt", "gt", "le", "", "???"];
$dataproc  = ["and", "eor", "sub", "rsb", "add", "adc", "sbc", "rsc", "tst", "teq", "cmp", "cmn", "orr", "mov", "bic", "mvn"];

foreach (array_values($prg) as $i => $code) {

    $pc = 4 * $i;

    echo sprintf("%04X | %08X | ", $pc, $code);

    $cond = $condition[$code >> 28];

    // BX Rm
    if (($code & 0x0FFFFFF0) == 0x012FFF10) {
        echo tab8("bx{$cond}"). " " . get_reg($code);
    }
    // B (branch)
    else if (($code & 0x0E000000) == 0x0A000000) {

        $br = $code & 0x00FFFFFF;
        if ($br & 0x00800000) $br |= 0xFF000000;

        echo tab8("b{$cond}" . ($code & 0x01000000 ? "l" : "")) . " $" . sprintf("%x", ($pc + 8 + 4*$br) & 0xFFFFFFFF);
    }
    // Блочная передача
    // http://www.gaw.ru/html.cgi/txt/doc/micros/arm/asm/asm_arm/ldm_stm.htm
    // 1. Сначала вычисляется адрес
    // 2. Потом последовательно сохраняется или загружается от младшего к старшему, причем младший всегда будет в младших адресах памяти
    else if (($code & 0x0E000000) == 0x08000000) {

        // name                   | stack | other | L P U
        // pre-increment    load  | LDMED | LDMIB | 1 1 1
        // post-increment   load  | LDMFD | LDMIA | 1 0 1
        // pre-decrement    load  | LDMEA | LDMDB | 1 1 0
        // post-decrement   load  | LDMFA | LDMDA | 1 0 0

        // pre-increment    store | STMFA | STMIB | 0 1 1
        // post-increment   store | STMEA | STMIA | 0 0 1
        // pre-decrement    store | STMFD | STMDB | 0 1 0
        // post-decrement   store | STMED | STMDA | 0 0 0

        $BW = ($code >> 21) & 1 ? 1 : 0;
        $BS = ($code >> 22) & 1 ? 1 : 0;

        $BU = ($code >> 23) & 1 ? 1 : 0;
        $BP = ($code >> 24) & 1 ? 2 : 0;
        $BL = ($code >> 20) & 1 ? 4 : 0;

        $Bcode = ($BL | $BP | $BU);

        // DA - Decrement After |  DB - Decrement Before | IA - Inrement After | Increment Before
        // ---
        // DA - Сначала запись, потом декремент
        // IA - Сначала запись, потом инкремент
        // DB - Сначала декремент, потом запись
        // DA - Сначала инкремент, потом запись
        // ---

        $Mcode = ["stmda", "stmia", "stmdb", "stmib", "ldmda", "ldmia", "ldmdb", "ldmib"];

        // Код операции + базовый регистр
        echo tab8($Mcode[$Bcode]) . " " . get_reg($code >> 16) . ($BW ? "!": ""). ", ";

        $list = [];
        for ($i = 0; $i < 16; $i++) if ($code & (1 << $i)) $list[] = get_reg($i);
        echo "{".join(",", $list)."}";

        // Sbit
        if ($BS) echo "^";

    }
    // Обработка данных
    // cccc|00iO|OOOs|nnnn|dddd|oooo|oooo|oooo
    // усл.    опкод  Rn   Rd   операнд
    else if (($code & 0x0C000000) == 0) {

        $dp = ($code >> 21) & 15;

        $imm = ($code & 0x02000000) ? 1 : 0;
        $sav = ($code >> 20) & 1 ? 's' : '';

        $dst = get_reg(($code & 0x0000F000) >> 12);
        $op1 = get_reg(($code & 0x000F0000) >> 16);
        $op2 = get_operand($code, $imm);

        $cmd = $dataproc[$dp];

        if ($cmd == 'mov')
            echo tab8("mov{$cond}{$sav}"). " $dst, $op2";
        else
            echo tab8($dataproc[$dp] . $cond . $sav) . " $dst, $op1, $op2";
    }

    echo "\n";

}

function tab8($s) {

    return str_pad($s, 8, " ", STR_PAD_RIGHT);
}

function get_reg($n) {

    $n &= 15;

    if ($n == 15) return 'pc';
    if ($n == 14) return 'lr';
    if ($n == 13) return 'sp';
    if ($n == 12) return 'ip';

    return 'r' . $n;
}

function get_operand($code, $imm) {

    if ($imm) {

        // Кол-во вращений вправо
        $shift = ($code & 0xf00) >> 8;
        $imm   = $code & 0xff;

        // Вращение идет направо
        for ($i = 0; $i < 2*$shift; $i++) $imm = ($imm >> 1) | (($imm & 1) << 31);

        return "#" . $imm;
    }

    $type = ['lsl', 'lsr', 'asr', 'ror'];
    $type = $type[($code & 0x60)>>5];

    // 7=0, 4=1 [Rm <s> Rs]
    if (($code & 0x810) == 0x010) {

        $rm = $code & 0xf;
        $rs = ($code & 0xf00) >> 8;

        return "[".get_reg($rm)." $type ".get_reg($rs)."]";
    }
    else if (($code & 0x810) == 0x000) {

        $rm = $code & 0xf;
        $ic = ($code & 0xf80) >> 7;

        if ($type == 'lsl' && $ic == 0)
            return get_reg($rm);

        return "[".get_reg($rm)." $type #".$ic."]";
    }


    return '---';
}
