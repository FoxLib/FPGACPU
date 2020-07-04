E2F=php ../../asm/easy2fasm.php
EMK=../../cpu/easymk

all:
	$(E2F) main.asm > main.s
	fasm main.s
	$(EMK) main.bin
