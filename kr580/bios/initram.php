<?php

$fb = []; for ($i = 0; $i < 65536; $i++) $fb[$i] = 0x00;

/* Заполнить rom */
$vb = file_get_contents("mon.bin");
for ($i = 0; $i < strlen($vb); $i++) $fb[0x0000 + $i] = ord($vb[$i]);

/* Заполнить видеопамять */
$vb = @ file_get_contents("vram.bin");
for ($i = 0; $i < strlen($vb); $i++) $fb[0x4000 + $i] = ord($vb[$i]);

?>
WIDTH=8;
DEPTH=65536;

ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;
CONTENT BEGIN

<?php for ($i = 0; $i < 65536; $i++) {
    echo str_pad(dechex($i), 4, '0', STR_PAD_LEFT) . ": " . str_pad(dechex($fb[$i]), 2, '0', STR_PAD_LEFT) . ";\n";
}
?>

END;
