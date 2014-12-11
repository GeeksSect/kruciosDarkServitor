#ifndef KOSH_H
#define KOSH_H

#include <QWidget>
#include <QTimer>
#include <QGLWidget>
#include <QMouseEvent>
#include <cmath>
#include <complex>

class Kosh : public QGLWidget
{
    Q_OBJECT
    typedef std::complex<double> dcomplex;
    std::vector<dcomplex> koshi;

    int width;
    int height;

    int x_offset;
    int y_offset;

    double m_x;
    double m_y;

    double k;
    double phi;

    double eps;

    QTimer *m_timer;

protected:
    virtual void initializeGL();
    virtual void resizeGL(int w, int h);
    virtual void paintGL();

public:
    explicit Kosh(QGLWidget *parent = 0);
    dcomplex fun(const dcomplex z);
    dcomplex fun2(const dcomplex z);

signals:

public slots:
    virtual void SlotMoveForward();
    virtual void SlotMoveBack();

    void repaint();

};

#endif // KOSH_H
