#include <avrio.c>
#include <kbd.c>
#include <math.h>

static const char map[16][16] = {

    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 1, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1},
    {1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1},
    {1, 2, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1},
    {1, 0, 1, 0, 1, 2, 2, 0, 0, 0, 1, 1, 1, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1},
    {1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1},
    {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 2, 2, 2, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
};

static const char tex[2][16][16] = {

    {
        {0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x00, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x00},
        {0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00},
        {0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00},
        {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
        {0x77, 0x77, 0x77, 0x00, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x00, 0x77, 0x77, 0x77, 0x77},
        {0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88},
        {0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88},
        {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
        {0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x00, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x00},
        {0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00},
        {0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00},
        {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
        {0x77, 0x77, 0x77, 0x00, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x77, 0x00, 0x77, 0x77, 0x77, 0x77},
        {0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88},
        {0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00, 0x77, 0x88, 0x88, 0x88},
        {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
    },
    {   // Красные кирпичи
        {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00},
        {0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00},
        {0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00},
        {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
        {0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff},
        {0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44},
        {0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44},
        {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
        {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00},
        {0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00},
        {0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00},
        {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
        {0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xff, 0xff, 0xff, 0xff},
        {0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44},
        {0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x00, 0xff, 0x44, 0x44, 0x44},
        {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
    }
};

const float sqrt2 = 0.7071; // 1/sqrt(2)

int main() {

    outp(0xD, 3);

    float px = 1.5, py = 1.1, a = 0.0;
    char* vm = (char*) 0xF000; unsigned int z;
    char bounce;

    int tex_id;
    char KW = 0, KF = 0, KA = 0, KD = 0;

    for (;;) {

        // Предвычисление
        float a_cos = sqrt2 * cos(a),
              a_sin = sqrt2 * sin(a);

        // Стартовая позиция точки
        int xi_ = (int) px; float x_ = px - xi_; float x; int xi;
        int yi_ = (int) py; float y_ = py - yi_; float y; int yi;

        // Просмотр горизонта событий
        for (int i = -160; i < 160; i += 2) {

            // Скопировать инициирующие точки
            x = x_; xi = xi_;
            y = y_; yi = yi_;

            // Вычисление смещения
            float fi = (float)i / 160.0;

            // Поворот точки
            float dx = a_cos*fi + a_sin;
            float dy = a_cos    - a_sin*fi;

            // Предвычисление
            float xa = (dx > 0) ? 1.0 :  0.0;
            float ya = (dy > 0) ? 1.0 :  0.0;
            float xb = (dx > 0) ? 1.0 : -1.0;
            float yb = (dy > 0) ? 1.0 : -1.0;
            float xc = 1.0 - xa;
            float yc = 1.0 - ya;
            float t  = 0.0, t1, t2;

            // Итерации по блокам
            for (int j = 0; j < 32; j++) {

                // Расчет разностей
                t1 = dx ? (xa - x) / dx : 100.0;
                t2 = dy ? (ya - y) / dy : 100.0;

                // Правая или левая стенка
                if (t1 < t2) {

                    x   = xc;
                    xi += xb;
                    y  += t1*dy;
                    t  += t1;
                    bounce = 0;

                    if      (y >= 1.0) y -= 1.0;
                    else if (y  < 0.0) y += 1.0;
                }
                // Верхняя или нижняя стена
                else {

                    y   = yc;
                    yi += yb;
                    x  += t2*dx;
                    t  += t2;
                    bounce = 1;

                    if      (x >= 1.0) x -= 1.0;
                    else if (x <  0.0) x += 1.0;
                }

                // Тест точки пересечения
                if (map[yi][xi]) {

                    // Вычисление Y = PPD / Z
                    t = 100.0 / t;
                    tex_id = map[yi][xi] - 1;

                    unsigned int cc;

                    // Текстура
                    cc = t < 30 ? 0x88 : (t < 50 ? 0x77 : 0xff);

                    // Границы
                    int y1 = 100 - t,
                        y2 = 100 + t;

                    // Смотря от чего отбился луч, оттуда взята текстура
                    int tx = (bounce ? x : y) * 32,
                        tym = 0,
                        ty  = 0,
                        dty = y2 - y1;

                    unsigned char sh1 = t > 50 ? 0xFF : 0xF0;
                    unsigned char sh2 = t > 50 ? 0x00 : (t > 30 ? 0x08 : 0x00);
                    //unsigned char shad = bounce ? 0xFF : 0xF0;

                    // Если начало стены находится за верхом
                    if (y1 < 0) {

                        tym  = 32 * (-y1);
                        ty  += (tym / dty);
                        tym %= dty;
                    }

                    // Сверху вниз заполнять линии
                    outp(0, 8); z = 80 + (i >> 1);

                    // Рисовать сверху вниз
                    for (int k = 0; k < 200; k++) {

                        // Расчет верха, стены и пола
                        if (k < y1) { cc = 0x11; }
                        // Рисование стены
                        else if (k < y2) {

                            // Целочисленное вычисление положения текстуры
                            tym += 32; while (tym > dty) { tym -= dty; ty++; }

                            // Вычисление картинки
                            cc = (tex[tex_id][ty & 15][tx & 15] & sh1) | sh2;

                            // Сеточка
                            sh1 = (sh1 >> 4) | (sh1 << 4);
                            sh2 = (sh2 >> 4) | (sh2 << 4);
                        }
                        // Рисовать пол
                        else cc = 0x22;

                        vm[z] = cc;
                        z    += 160;

                        // К следующему банку
                        if (z & 0x1000) { outp(0, inp(0) + 1); z &= 0xfff; }
                    }

                    break;
                }
            }

            // Что-то было нажато или отжато
            if (inp(3) & 1) {

                unsigned char ki = inp(2);

                if (ki == 0x11) KW = 1; else if (ki == 0x91) KW = 0;
                if (ki == 0x1F) KF = 1; else if (ki == 0x9F) KF = 0;
                if (ki == 0x1E) KA = 1; else if (ki == 0x9E) KA = 0;
                if (ki == 0x20) KD = 1; else if (ki == 0xA0) KD = 0;
            }
        }

        if (KW) { px += 0.25 * a_sin; py += 0.25 * a_cos; }
        if (KF) { px -= 0.25 * a_sin; py -= 0.25 * a_cos; }

        if (KA) { a -= 0.25; }
        if (KD) { a += 0.25; }
    }
}