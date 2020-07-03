all:
	php easy2fasm.php example.asm > example.s
	fasm example.s
	../cpu/easymk example.bin
clean:
	rm -f *.s *.bin
