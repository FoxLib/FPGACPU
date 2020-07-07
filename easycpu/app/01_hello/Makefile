E2F=php ../../asm/easy2fasm.php
EMK=../../cpu/easymk
INC=inc=../../inc

all:
	$(E2F) hello.asm $(INC) > hello.s
	fasm hello.s
	$(EMK) hello.bin
