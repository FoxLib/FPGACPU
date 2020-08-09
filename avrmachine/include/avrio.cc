#ifndef __AVRIO_HFILE
#define __AVRIO_HFILE

#include <avr/pgmspace.h>

// Ссылка на пустой адрес
#define NULL    ((void*) 0)
#define brk     asm volatile("sleep"); // break

// Базовые типы данных
#define byte    unsigned char
#define uint    unsigned int
#define word    unsigned int
#define ulong   unsigned long
#define dword   unsigned long

// Объявление указателя на память (имя x, адрес a)
#define heap(x, a)  byte* x = (byte*) a
#define bank(x)     outp(BANK_LO, x)

// Описания всех портов
enum InputOutputPort {

    // Банкинг
    BANK_LO         = 0x00, // RW
    BANK_HI         = 0x01, // RW

    // Клавиатура
    KB_DATA         = 0x02, // R
    KB_HIT          = 0x03, // R

    // Текстовый курсор
    CURSOR_X        = 0x04, // RW
    CURSOR_Y        = 0x05, // RW

    // Конфигурация таймера
    TIMER_LO        = 0x06, // R
    TIMER_HI        = 0x07, // R
    TIMER_HI2       = 0x0F, // R
    TIMER_HI3       = 0x10, // R
    TIMER_INTR      = 0x16, // W Прерывание таймера

    // SPI SD
    SPI_DATA        = 0x08, // W
    SPI_CMD         = 0x09, // W
    SPI_STATUS      = 0x09, // R

    // Эмулятор мыши
    MOUSE_X_LO      = 0x0A, // R
    MOUSE_Y_LO      = 0x0B, // R
    MOUSE_STATUS    = 0x0C, // R
    MOUSE_X_HI      = 0x0E, // R

    // Видеорежим
    VIDEOMODE       = 0x0D, // RW

    // Управление SDRAM
    SDRAM_B0        = 0x10, //  7:0
    SDRAM_B1        = 0x11, // 15:8
    SDRAM_B2        = 0x12, // 23:16
    SDRAM_B3        = 0x13, // 31:24
    SDRAM_DATA      = 0x14, // RW
    SDRAM_CTRL      = 0x15, // R  Status [0=Ready], W Control [0=WE]
};

// Список видеорежимов
enum VideoModes {

    VM_80x25        = 0,
    VM_320x200x8    = 1,
    VM_320x240x2    = 2,
    VM_320x200x4    = 3
};

enum SPICommands {

    SPI_CMD_INIT    = 0,
    SPI_CMD_SEND    = 1,
    SPI_CMD_CE0     = 2,
    SPI_CMD_CE1     = 3
};

enum SDRAMStatus {

    SDRAM_WE        = 1,
    SDRAM_READY     = 2
};

enum KBASCII {

    key_LSHIFT      = 0x00,
    key_LALT        = 0x00,
    key_LCTRL       = 0x00,
    key_UP          = 0x00,
    key_DN          = 0x00,
    key_LF          = 0x00,
    key_RT          = 0x00,
    key_BS          = 0x00,
    key_TAB         = 0x00,
    key_ENTER       = 0x00,
    key_HOME        = 0x00,
    key_END         = 0x00,
    key_PGUP        = 0x00,
    key_PGDN        = 0x00,
    key_DEL         = 0x00,
    key_F1          = 0x00,
    key_F2          = 0x00,
    key_F3          = 0x00,
    key_F4          = 0x00,
    key_F5          = 0x00,
    key_F6          = 0x00,
    key_F7          = 0x00,
    key_F8          = 0x00,
    key_F9          = 0x00,
    key_F10         = 0x00,
    key_F11         = 0x00,
    key_F12         = 0x00,
    key_ESC         = 0x00,
    key_INS         = 0x00,
    key_NL          = 0x00,
    key_SPECIAL     = 0x00,         // Особая клавиша
};

// Чтение из порта
inline byte inp(int port) { return ((volatile byte*)0x20)[port]; }

// Запись в порт
inline void outp(int port, unsigned char val) { ((volatile unsigned char*)0x20)[port] = val; }

#endif
