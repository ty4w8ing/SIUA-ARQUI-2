
consola: consola.o
	ld -m elf_i386 -o consola consola.o

consola.o: consola.asm
	nasm -f elf -g -F stabs consola.asm -l consola.lst
