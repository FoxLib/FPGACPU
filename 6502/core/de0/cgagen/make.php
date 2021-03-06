<?php

//include "screen1.php";
include "screen2.php";

$image = imagecreatetruecolor(640, 400);
$font = file_get_contents("font.rom");

// Генератор шрифта
$out = "WIDTH=8;\nDEPTH=8192;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n";
for ($i = 0; $i < 4096; $i++) $out .= sprintf("  %03X: %02X;\n", $i, ord($font[$i]));

$addr = 0x1000;
$pal = [
    0x111111, 0x000088, 0x008800, 0x008888,
    0x880000, 0x880088, 0x888800, 0xcccccc,
    0x888888, 0x0000ff, 0x00ff00, 0x00ffff,
    0xff0000, 0xff00ff, 0xffff00, 0xffffff,
];

// Генерация данных
foreach ($screen as $row_id => $row) {
    $row = iconv("utf8", "cp866", $row);
    for ($x = 0; $x < 80; $x++) {

        $cl = $colors[$row_id][$x];
        $ch = ord($row[$x]);
        if ($cl === ' ') $cl = '7';

        // Рендеринг символа
        $fore = hexdec($cl) & 15;
        $back = 0;

        for ($i = 0; $i < 16; $i++) {

            $mask = ord($font[$ch*16 + $i]);
            for ($j = 0; $j < 8; $j++) {

                $px = $pal[ $mask & (1 << (7 - $j)) ? $fore : $back ];
                imagesetpixel($image, $x*8 + $j, $row_id*16 + $i, $px);
            }
        }

        $out .= sprintf("  %03X: %02X;\n", $addr++, $ch);
        $out .= sprintf("  %03X: 0{$cl};\n", $addr++);
    }
}
$out .= sprintf("  [%03X..1FFF]: 00;\n", $addr);
$out .= "END;\n";
file_put_contents("../cga8k.mif", $out);

imagepng($image, "screen.png");
