#include <avrio.cc>
#include <kb.cc>
#include <con.cc>

KB  kb;
CON d;

int main() {

    d.init();
    d.cls(0x07);
    d.cursor(2, 1);

    d.print("Hello");
    d.print(542.321, 2);

}
