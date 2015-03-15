#include "kosh.h"
#include <cmath>

Kosh::Kosh(QGLWidget *parent) :
    QGLWidget(parent)
{
    width = 1366;
    height = 768;

    setMinimumSize(width, height);

    x_offset = 1366 /2;
    y_offset = 768 / 2;

    m_x = 1366 / 4;
    m_y = 768 / 4;

    k = 0.99;
    phi = M_PI / 57;

    eps = 0.05;

    resizeGL(1366, 768);

    m_timer = new QTimer(this);
    connect(m_timer, SIGNAL(timeout()), SLOT(repaint()));
    m_timer->start(1);
}

/*virtual*/ void Kosh::initializeGL()
{
    qglClearColor(Qt::black);
}

/*virtual*/ void Kosh::resizeGL(int w, int h)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glViewport(0, 0, (GLint)w, (GLint)h);
    height = h;
    width = w;
    //emit widthChanged(w);
    //emit heightChanged(h);
    glOrtho(0, w, h, 0, -1, 1);
}

/*virtual*/ void Kosh::paintGL()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glPointSize(3);
    glBegin(GL_POINTS);
        glColor3f(1, 1, 1);
        for (auto it = koshi.begin(), end = koshi.end(); it < end; ++it)
        {
            dcomplex temp = fun2(*it) * 1.;
            //dcomplex temp = *it;
            double x = std::real(temp) + x_offset;
            double y = std::imag(temp) + y_offset;
            glVertex2d(x, y);
        }
    glEnd();
}

/*virtual*/ void Kosh::SlotMoveForward()
{
    bool isCreatedNew = false;
    int pos_diff = 0;
    for (auto it = koshi.begin(), end = koshi.end(); it < end; ++it)
    {
        auto diff = *it;
        *it = fun(*it);
        //*it - fun2(*it);
        diff = diff - *it;
        if (std::abs(diff) < 0.0005 || std::abs(diff) > 999)
        {
            *it = dcomplex(1000 + (pos_diff * 1753 % 590) / 1., (1000 + pos_diff * 2997 % 530) / 1.);
            isCreatedNew = true;
        }
        ++pos_diff;
    }
    if (!isCreatedNew)
        koshi.push_back(dcomplex(1000 + (pos_diff * 1753 % 900) / 1., (1000 + pos_diff * 2997 % 900) / 1.));
}
Kosh::dcomplex Kosh::fun(const Kosh::dcomplex z)
{
    //return dcomplex(1, 0) / z;
    return k * z * std::exp(dcomplex(0, phi));
    //z0 = (z0 + dcomplex(1, 0)) / (z0 - dcomplex(1, 0));
}

Kosh::dcomplex Kosh::fun2(const Kosh::dcomplex z)
{
    dcomplex one(1, 0);
    dcomplex k(1, 50);
    return (k * z + one) / (z - k * one);
}

/*virtual*/ void Kosh::SlotMoveBack()
{
    // TODO
}

void Kosh::repaint()
{
    //paintGL();
    update();
    SlotMoveForward();
}
