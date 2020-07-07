E2F=php ../../asm/easy2fasm.php
EMK=../../cpu/easymk
INC=inc=../../inc

all:
	$(E2F) main.asm $(INC) > main.s
	fasm main.s
	$(EMK) main.bin
