all:
	arm-none-eabi-as entry.s -o entry.o
	arm-none-eabi-gcc main.c -Os -c -o main.o
	arm-none-eabi-ld -Ttext=0x0 entry.o main.o -o main.elf
	arm-none-eabi-objcopy main.elf -O binary -R .note -R .note.gnu.build-id -R .comment -S main
	arm-none-eabi-objdump -S main.elf > main.lst
clean:
	rm -f *.o *.elf *.lst main
