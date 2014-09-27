#ifndef MAPWIDGET_H
#define MAPWIDGET_H

#include <QWidget>
#include <QPainter>
#include <QPaintEvent>

#define DEFAULT_SIZE 70

class MapWidget : public QWidget
{
    Q_OBJECT

    int **m_map;
    int m_n, m_m; // Map size
    unsigned char m_cell_size;

    void buildWay(int start_crd, int val); //build way through walls and mark new cells with given value
    void bfs(int start_crd, int val); //marks all cells conected with a given cell of given value
    void generate();
    void clearMap();
    void makeBorders();
    void changeCellState(const int x, const int y);

public:
    //MapWidget();
    explicit MapWidget(QWidget *parent = 0);
    MapWidget(const int n, const int m);
    ~MapWidget();
    QSize sizeHint() const;
    QSize minimumSize() const;
    QSize maximumSize() const;

protected:
    void paintEvent(QPaintEvent *event);
    void mouseReleaseEvent(QMouseEvent *event);

signals:

public slots:
    //void slotClearMap();
    //void slotGenerateMap();

};

#endif // MAPWIDGET_H
