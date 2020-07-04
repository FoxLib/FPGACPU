@echo off

php ../../asm/easy2fasm.php main.asm > main.s
fasm main.s
php ../../asm/easy2mif.php main.bin > ../../mc3/prgram.mif
cd ../../mc3
update.bat
