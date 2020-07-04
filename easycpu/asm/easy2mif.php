WIDTH=8;
DEPTH=32768;

ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;

CONTENT BEGIN
<?
$fp = file_get_contents($argv[1]);
$ln = strlen($fp);
for ($i = 0; $i < $ln; $i++) {
    echo sprintf("%04X : %02X;\n", $i, ord($fp[$i]));
}
echo sprintf("[%04X..7FFF] : 00;\n", $i, $ln);
?>

END;
