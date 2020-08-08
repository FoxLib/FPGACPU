CC=g++
SDL=`sdl-config --cflags --libs`
LIBS=-lSDL
WARN=-Wall -Wno-strict-overflow -Wno-unused-result -Wno-unused-variable -Wno-unused-but-set-variable
CFLAGS=-Icore -I. $(SDL) -O3 $(WARN)
OBJ=disasm.o ui.o cpu.o kr580.o

all: $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) $(LIBS) -o kr580
	./kr580 test/main.bin

%.o: %.cc kr580.h
	$(CC) $(CFLAGS) $(LIBS) $< -c -o $@

clean:
	rm *.o kr580
