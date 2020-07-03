E2F=php ../../asm/easy2fasm.php
EMK=../../cpu/easymk

all:
	$(E2F) hello.asm > hello.s
	fasm hello.s
	$(EMK) hello.bin
