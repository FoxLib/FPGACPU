<?php

// 16 bit
$gif = imagecreatefromgif("main.gif");

ob_start();
echo "WIDTH=8;\nDEPTH=153600;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n";
echo "CONTENT BEGIN\n";

$address = 0;
for ($y = 0; $y < 480; $y++)
for ($x = 0; $x < 640; $x += 2) {

    $c1 = imagecolorat($gif, $x+0, $y);
    $c0 = imagecolorat($gif, $x+1, $y);

    $cl = $c1*16 + $c0;
    echo sprintf("  %05x: %02x;\n", $address++, $cl);
}

echo "END\n";
file_put_contents("../vram.mif", ob_get_clean());
