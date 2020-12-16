// Карта памяти
// ---------------------------------------------------------------------
// 0000-00FF 256    Регистры
// 0100-01FF 256    Стек
// 0200-0FFF 3.5k   Память и устройства
// 1000-1FFF 4k     Знакогенератор или банки
// 2000-2FFF 4k     Видеопамять
// 3000-FFFF 52k    Память программ
// ---------------------------------------------------------------------
// 0200 R           Последняя клавиша клавиатуры ASCII
// 0201 R           Счетчик нажатых клавиш
// ---------------------------------------------------------------------

class app extends nescpu {

    constructor() {

        super();

        this.el     = document.getElementById('viewport');
        this.ctx    = this.el.getContext('2d');
        this.width  = this.el.width;
        this.height = this.el.height;
        this.img    = this.ctx.getImageData(0, 0, this.el.width, this.el.height);

        // Инициализация памяти
        this.ram = new Uint8Array(65536);
        this.started = 0;
        this.palette = [
            0x111111, 0x000088, 0x008800, 0x008888,
            0x880000, 0x880088, 0x888800, 0xcccccc,
            0x888888, 0x0000ff, 0x00ff00, 0x00ffff,
            0xff0000, 0xff00ff, 0xffff00, 0xffffff,
        ];

        // Сначала загрузить FONT.ROM
        this.load("font.rom", 0x1000, function() {

            // Потом загрузить тестовую программу
            this.load("app1/main.bin?v=" + Math.random(), 0x3000, function() {

                this.pc = 0x3000;
                this.started = 1;

                // Заполнение дисплея тестовыми данными
                for (let i = 0x2000; i < 0x3000; i += 2) {
                    this.write(i,   0x00);
                    this.write(i+1, 0x07);
                }

                this.frame();

            }.bind(this));

        }.bind(this));
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

    // Запись в память или на экран
    write(address, data) {

        address &= 0xffff;
        this.ram[address] = data;

        // Запись в видеопамять
        if (address >= 0x2000 && address < 0x3000) {
            this.update(address);
        }
    }

    update(address) {

        let ad = (address - 0x2000) >> 1;
        let y  = Math.floor(ad / 80);
        let x  = ad % 80;
        let bs = 0x2000 + 2*ad;
        let ch = this.ram[bs];
        let cl = this.ram[bs+1];

        // Рендеринг символа
        let fore =  cl & 15;
        let back = (cl >> 4) & 7;

        for (let i = 0; i < 16; i++) {

            let mask = this.ram[0x1000 + ch*16 + i];
            for (let j = 0; j < 8; j++) {

                let px = this.palette[mask & (1 << (7 - j)) ? fore : back];
                this.pset(8*x + j, 16*y + i, px);
            }
        }
    }

    // Загрузка бинарных данных
    load(url, address, callback) {

        let xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.responseType = "arraybuffer";
        xhr.send();
        xhr.onload = function() {

            if (xhr.status !== 200) {
                alert(`Ошибка ${xhr.status}: ${xhr.statusText}`);
            } else {

                let data = new Uint8Array(xhr.response);
                for (let i = 0; i < data.length; i++)
                    this.ram[address + i] = data[i];

                if (typeof callback === 'function') callback();
            }

        }.bind(this)
    }

    debug() {

        console.log("A:  $" + this.reg.a.toString(16));
        console.log("X:  $" + this.reg.x.toString(16));
        console.log("Y:  $" + this.reg.y.toString(16));
        console.log("S:  $" + this.reg.s.toString(16));
        console.log("P:  $" + this.reg.p.toString(16));
        console.log("PC: $" + this.pc.toString(16));
    }

    frame() {

        let time = (new Date()).getTime();
        let cycles = 0;

        if (this.started) {

            while (cycles < 29780) {

                /* BRK */
                if (this.ram[this.pc] == 0x00) {

                    this.started = 0;
                    this.debug();
                    break;
                }

                cycles += this.step();
            }
        }

        time = (new Date()).getTime() - time;
        time = (time < 25) ? 25 - time : 1;

        this.flush();
        setTimeout(function() { this.frame(); }.bind(this), time);
    }
}
