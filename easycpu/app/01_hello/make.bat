@echo off

php ../../asm/easy2fasm.php hello.asm inc=../../inc > hello.s
fasm hello.s
php ../../asm/easy2mif.php hello.bin > ../../mc3/prgram.mif
cd ../../mc3
update.bat

pause
