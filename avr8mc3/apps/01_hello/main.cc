#include <avrio.cc>
#include <screen.cc>
#include <stdio.cc>

screen D;
stdio io;

int main() {

    D.cls(1);
    D.circlef(160, 100, 50, 14);

    D.color(15, 1);
    D.locate(8, 8);
    D.print("Hello, World! Support only English for compact progmem size... ");

    D.lineb(1,1,318,198,7);
    D.lineb(3,3,316,196,7);

    for(;;) {

        D.locate(8, 16);
        D.print(io.timer());

        //D.print4( io.getch() );
    }
}
