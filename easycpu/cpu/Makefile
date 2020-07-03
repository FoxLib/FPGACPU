CC=g++
INCLUDE=`sdl-config --cflags --libs` -lm
OPTIONS=-O3
WARNING=-Wall
OBJECTS=ui.o cpu.o main.o

all: $(OBJECTS)
	$(CC) $(OBJECTS) $(INCLUDE) -o easymk
	./easymk

%.o: %.cc %.h
	$(CC) $(INCLUDE) $(OPTIONS) $(WARNING) -c $< -o $@

clean:
	rm *.o
