all:
	arm-none-eabi-gcc -nostdlib -nostartfiles -Os main.c -Ttext=0x10000 -o main
	arm-none-eabi-objdump -S main > main.lst
