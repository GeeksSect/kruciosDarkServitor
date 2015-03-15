#include "mainwindow.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    Kosh w;
    w.showFullScreen();

    return a.exec();
}
