#include <screen3.cc>
#include <sdcard.cc>

byte sector[512];

int main() {

    Screen3 D(0x07);
    SDCard sd;

    sd.read(0, sector);

    for(;;);
}
