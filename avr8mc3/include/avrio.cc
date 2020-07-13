#ifndef __AVRIO_HFILE
#define __AVRIO_HFILE

#include <avr/pgmspace.h>

// Ссылка на пустой адрес
#define NULL        ((void*)0)
#define brk         asm volatile("sleep"); // break

// Базовые типы данных
#define byte        unsigned char
#define uint        unsigned int
#define word        unsigned int
#define ulong       unsigned long
#define dword       unsigned long

// Описания всех портов
enum PortsID {
};

// Чтение из порта
inline byte inp(int port) { return ((volatile byte*)0x20)[port]; }

// Запись в порт
inline void outp(int port, unsigned char val) { ((volatile unsigned char*)0x20)[port] = val; }

// Объявление указателя на память (имя x, адрес a)
#define heap(x, a) byte* x = (byte*) a
#define display(x) byte* x = (byte*) 0x8000

#endif
