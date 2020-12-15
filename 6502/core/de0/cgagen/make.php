<?php

$screen = [
//             1         2         3         4         5         6         7
//   01234567890123456789012345678901234567890123456789012345678901234567890123456789
    "         Январь              Февраль             Март              Апрель       ", //  0
    " Пн     4 11 18 25     |  1  8 15 22     |  1  8 15 22 29  |     5 12 19 26     ", //  1
    " Вт     5 12 19 26     |  2  9 16 23     |  2  9 16 23 30  |     6 13 20 27     ", //  2
    " Ср     6 13 20 27     |  3 10 17 24     |  3 10 17 24 31  |     7 14 21 28     ", //  3
    " Чт     7 14 21 28     |  4 11 18 25     |  4 11 18 25     |  1  8 15 22 29     ", //  4
    " Пт  1  8 15 22 39     |  5 12 19 26     |  5 12 19 26     |  2  9 16 23 30     ", //  5
    " Сб  2  9 16 23 30     |  6 13 20 27     |  6 13 20 27     |  3 10 17 24        ", //  6
    " Вс  3 10 17 24 31     |  7 14 21 28     |  7 14 21 28     |  4 11 18 25        ", //  7
    "           Май                Июнь                Июль             Август       ", //  8
    " Пн     3 10 17 24 31  |     7 14 21 28  |     5 12 19 26  |     2  9 16 23 30  ", //  9
    " Вт     4 11 18 25     |  1  8 15 22 29  |     6 13 20 27  |     3 10 17 24 31  ", // 10
    " Ср     5 12 19 26     |  2  9 16 23 30  |     7 14 21 28  |     4 11 18 25     ", // 11
    " Чт     6 13 20 27     |  3 10 17 24     |  1  8 15 22 29  |     5 12 19 26     ", // 12
    " Пт     7 14 21 28     |  4 11 18 25     |  2  9 16 23 30  |     6 13 20 27     ", // 13
    " Сб  1  8 15 22 29     |  5 12 19 26     |  3 10 17 24 31  |     7 14 21 28     ", // 14
    " Вс  2  9 16 23 30     |  6 13 20 27     |  4 11 18 25     |  1  8 15 22 29     ", // 15
    "         Сентябрь            Октябрь            Ноябрь             Декабрь      ", // 16
    " Пн     6 13 20 27     |     4 11 18 25  |  1  8 15 22 29  |     6 13 20 27 ^__^", // 17
    " Вт     7 14 21 28     |     5 12 19 26  |  2  9 16 23 30  |     7 14 21 28 (oo)", // 18
    " Ср  1  8 15 22 29     |     6 13 20 27  |  3 10 17 24     |  1  8 15 22 29 (__)", // 19
    " Чт  2  9 16 23 30     |     7 14 21 28  |  4 11 18 25     |  2  9 16 23 30   ||", // 20
    " Пт  3 10 17 24        |  1  8 15 22 29  |  5 12 19 26     |  3 10 17 24 31   ||", // 21
    " Сб  4 11 18 25        |  2  9 16 23 30  |  6 13 20 27     |  4 11 18 25        ", // 22
    " Вс  5 12 19 26        |  3 10 17 24 31  |  7 14 21 28     |  5 12 19 26   2021 ", // 23
    "                                                                          Корова", // 24
];

$colors = [
//             1         2         3         4         5         6         7
//   01234567890123456789012345678901234567890123456789012345678901234567890123456789
    " 0AAAAAAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAA", //  0
    "    CC CC              8          CC     8    CC           8                    ", //  1
    "    CC CC              8          CC     8                 8                    ", //  2
    "    CC CC              8                 8                 8                    ", //  3
    "    CC CC              8                 8                 8                    ", //  4
    "    CC CC              8                 8                 8                    ", //  5
    " CCCCCCCCCCCCCCCCCCCCCC8CCCCCCC  CCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCCCCC", //  6
    " CCCCCCCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCCCCC", //  7
    " AAAAAAAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAA", //  8
    "       CC CC           8       CC        8                 8                    ", //  9
    "                       8                 8                 8                    ", // 10
    "                       8                 8                 8                    ", // 11
    "                       8                 8                 8                    ", // 12
    "                       8                 8                 8                    ", // 13
    " CCCCCCCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCCCCC", // 14
    " CCCCCCCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCCCCC", // 15
    " AAAAAAAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAA", // 16
    "                       8                 8                 8                    ", // 17
    "                       8                 8                 8                    ", // 18
    "                       8                 8                 8                    ", // 19
    "                       8                 8 CC              8                    ", // 20
    "                       8                 8                 8             CC     ", // 21
    " CCCCCCCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCCCCC", // 22
    " CCCCCCCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCCCC8CCCCCCCCCCCCCCAAAAAA", // 23
    "                                                                          222222", // 24
];

$font = file_get_contents("font.rom");

// Генератор шрифта
$out = "WIDTH=8;\nDEPTH=8192;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n";
for ($i = 0; $i < 4096; $i++) $out .= sprintf("  %03X: %02X;\n", $i, ord($font[$i]));

$addr = 0x1000;

// Генерация данных
foreach ($screen as $row_id => $row) {
    $row = iconv("utf8", "cp866", $row);
    for ($x = 0; $x < 80; $x++) {

        $cl = $colors[$row_id][$x];
        if ($cl === ' ') $cl = '7';

        $out .= sprintf("  %03X: %02X;\n", $addr++, ord($row[$x]));
        $out .= sprintf("  %03X: 0{$cl};\n", $addr++);
    }
}
$out .= sprintf("  [%03X..1FFF]: 00;\n", $addr);
$out .= "END;\n";
file_put_contents("../cga8k.mif", $out);
