#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent)
{
    QWidget *central = new QWidget;

    this->setMinimumSize(m_map.maximumSize());

    QHBoxLayout *lout = new QHBoxLayout;
    lout->setAlignment(Qt::AlignLeft | Qt::AlignTop);
    QScrollArea *scroll_map = new QScrollArea;
    scroll_map->setWidget(&m_map);
    lout->addWidget(scroll_map);

    central->setLayout(lout);

    setCentralWidget(central);
    setWindowTitle("Labirinth");
}

MainWindow::~MainWindow()
{
}
