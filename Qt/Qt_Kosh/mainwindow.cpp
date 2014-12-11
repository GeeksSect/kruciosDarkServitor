#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    m_k = new Kosh;

    QScrollArea *scroll_map = new QScrollArea;
    scroll_map->setWidget(m_k);

    QHBoxLayout *hlout = new QHBoxLayout;
    hlout->setAlignment(Qt::AlignLeft);
    hlout->addWidget(scroll_map);

    QWidget *central = new QWidget;
    central->setLayout(hlout);

    setCentralWidget(central);
    setWindowTitle("Kosh");
}

MainWindow::~MainWindow()
{

}
