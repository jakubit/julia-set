CC = gcc
CFLAGS = -Wall -m64

all: main.o assembler.o
	$(CC) $(CFLAGS) -o JuliaSet main.o assembler.o `allegro-config --libs --shared`

assembler.o: assembler.s
	nasm -f elf64 -o assembler.o assembler.s

main.o: main.c assembler.h
	$(CC) $(CFLAGS) -c -o main.o main.c
clean:
	rm -f *.o
