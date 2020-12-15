<?php

$screen = [
//             1         2         3         4         5         6         7
//   01234567890123456789012345678901234567890123456789012345678901234567890123456789
    "Hello World You Are Buiz                                                        ", //  0
    " Все говорят буйза, но на самом деле все так как есть                           ", //  1
    "                                                                                ", //  2
    "                                                                                ", //  3
    "                                                                                ", //  4
    "                                                                                ", //  5
    "                                                                                ", //  6
    "                                                                                ", //  7
    "                                                                                ", //  8
    "                                                                                ", //  9
    "                                                                                ", // 10
    "                                                                                ", // 11
    "                                                                                ", // 12
    "                                                                                ", // 13
    "                                                                                ", // 14
    "                                                                                ", // 15
    "                                                                                ", // 16
    "                                                                                ", // 17
    "                                                                                ", // 18
    "                                                                                ", // 19
    "                                                                                ", // 20
    "                                                                                ", // 21
    "                                                                                ", // 22
    "                                                                                ", // 23
    "                                                                                ", // 24
];

$font = file_get_contents("font.rom");

// Генератор шрифта
$out = "WIDTH=8;\nDEPTH=8192;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n";
for ($i = 0; $i < 4096; $i++) $out .= sprintf("  %03X: %02X\n", $i, ord($font[$i]));

$addr = 0x1000;

// Генерация данных
foreach ($screen as $row) {
    $row = iconv("utf8", "cp866", $row);
    for ($x = 0; $x < 80; $x++) {
        $out .= sprintf("  %03X: %02X\n", $addr++, ord($row[$x]));
        $out .= sprintf("  %03X: 17\n", $addr++);
    }
}
$out .= sprintf("  [%03X..1FFF]: 00\n", $addr);
$out .= "END;\n";
file_put_contents("../cga8k.mif", $out);
