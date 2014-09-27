#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QWidget>
#include <QBoxLayout>
#include <QScrollArea>
#include "mapwidget.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

    MapWidget m_map;

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

signals:

public slots:

};

#endif // MAINWINDOW_H
