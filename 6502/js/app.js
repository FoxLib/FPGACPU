// Карта памяти
// 0000-00FF 256    Регистры
// 0100-01FF 256    Стек
// 0200-0FFF 3.5k   Память и устройства
// 1000-1FFF 4k     Знакогенератор или банки
// 2000-2FFF 4k     Видеопамять
// 3000-FFFF 52k    Память программ

class app extends nescpu {

    constructor() {

        super();

        this.el     = document.getElementById('viewport');
        this.ctx    = this.el.getContext('2d');
        this.width  = this.el.width;
        this.height = this.el.height;
        this.img    = this.ctx.getImageData(0, 0, this.el.width, this.el.height);

        this.ram = new Uint8Array(65536);
    }

    // Рисование пикселя на экране
    pset(x, y, k) {

        if (x < this.width && y < this.height && x >= 0 && y >= 0) {

            let p = 4*(x + y * this.width);
            this.img.data[p    ] =  (k >> 16) & 0xff;
            this.img.data[p + 1] =  (k >>  8) & 0xff;
            this.img.data[p + 2] =  (k      ) & 0xff;
            this.img.data[p + 3] = ((k >> 24) & 0xff) ^ 0xff;
        }
    }

    // Обновление экрана
    flush() { this.ctx.putImageData(this.img, 0, 0); }

    // IO
    read(address) { return this.ram[address & 0xffff]; }
    write(address, data) {

        this.ram[address & 0xffff] = data;

    }

}
