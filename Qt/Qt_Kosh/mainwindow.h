#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QMainWindow>
#include <QHBoxLayout>
#include <QScrollArea>
#include "kosh.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

    Kosh* m_k;

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();
};

#endif // MAINWINDOW_H
