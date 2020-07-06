E2F=php ../../asm/easy2fasm.php
EMK=../../cpu/easymk
INC=../../inc

all:
	$(E2F) main.asm inc=$(INC) > main.s
	fasm main.s
	$(EMK) main.bin
