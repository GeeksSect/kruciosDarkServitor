#include "mapwidget.h"

#include <iostream>
#include <stdlib.h>
#include <ctime>
#include <QQueue>
#include <math.h>

#define BIG_NUMBER 2000000
#define WALL Qt::darkRed
#define HALL Qt::white
#define CELL_SIZE 10

/*        PRIVATE METHODS        */

void MapWidget::buildWay(int start_crd, int val)
{
    int dx[4] = {0, 1, 0, -1};
    int dy[4] = {1, 0, -1, 0};

    int x = start_crd / m_m;
    int y = start_crd % m_m;

    m_map[x][y] = val;

    double min_len = BIG_NUMBER;
    int choosen = 0;

    for (int i = 0; i < 4; ++i)
    {
        if (m_map[x + dx[i]][y + dy[i]] == 2)
            return;
        if ((x + dx[i] > 0) && (x + dx[i] < m_n) &&
            (y + dy[i] > 0) && (y + dy[i] < m_m)) //if (x + dx[i], y + dy[i]) is not at the border
        {
            double len = sqrt((x + dx[i] - 1) * (x + dx[i] - 1) +
                              (y + dy[i] - 1) * (y + dy[i] - 1));
            if (len < min_len)
            {
                min_len = len;
                choosen = i;
            }
        }
    }

    buildWay(((x + dx[choosen]) * m_m) + y + dy[choosen], val);
}

void MapWidget::bfs(int start_crd, int val)
{
    QQueue<int> bfs_queue;
    bfs_queue.enqueue(start_crd);

    //create **visited
    bool **visited = new bool*[m_n];
    for (int i = 0; i < m_n; ++i)
    {
        visited[i] = new bool[m_m];
    }

    // initialization **visited
    for (int i = 0; i< m_n; ++i)
    {
        for (int j = 0; j < m_m; ++j)
        {
            visited[i][j] = false;
        }
    }
    for (int i = 0; i < m_n; ++i)
    {
        visited[i][0] = visited[i][m_m - 1] = true;
    }
    for (int i = 0; i < m_m; ++i)
    {
        visited[0][i] = visited[m_n - 1][i] = true;
    }

    int dx[4] = {0, 1, 0, -1};
    int dy[4] = {1, 0, -1, 0};

    while (!bfs_queue.isEmpty())
    {
        int temp = bfs_queue.dequeue();
        int y = temp % m_m;
        int x = temp / m_m;

        m_map[x][y] = val;
        visited[x][y] = true;
        for (int i = 0; i < 4; ++i)
        {
            if (m_map[x + dx[i]][y + dy[i]] && !visited[x + dx[i]][y + dy[i]])
            {
                visited[x + dx[i]][y + dy[i]] = true;
                bfs_queue.enqueue((x + dx[i]) * m_m + (y + dy[i]));
            }
        }
    }

    // delete **visited
    for (int i = 0; i < m_n; ++i)
        delete[] visited[i];
    delete[] visited;
}

void MapWidget::generate()
{
    // borders
    srand(time(NULL));
    makeBorders();

    // random generate (1 Step)
    for (int i = 1; i < m_n - 1; ++i)
        for (int j = 1; j < m_m - 1; ++j)
        {
            m_map[i][j] = rand() % 2;
        }
    m_map[1][1] = 1;
    m_map[m_n - 2][m_m - 2] = 1;

    // bfs (2 Step)
    int val = 2;
    for (int i = 1; i < m_n - 1; ++i)
    {
        for (int j = 1; j < m_m - 1; ++j)
        {
            if (m_map[i][j] == 1)
            {
                bfs((i * m_m) + j, val);
                ++val;
            }
        }
    }

    // (3 Step)

    for (int i = 1; i < m_n - 1; ++i)
    {
        for (int j = 1; j < m_m - 1; ++j)
        {
            if (m_map[i][j] > 2)
            {
                buildWay((i * m_m) + j, m_map[i][j]);
                bfs((i * m_m) + j, 2);
            }
        }
    }


}

void MapWidget::clearMap()
{
    for (int i = 0; i < this->m_n; ++i)
    {
        for (int j = 0; j < this->m_m; ++j)
        {
            m_map[i][j] = 1;
        }
    }
}

void MapWidget::makeBorders()
{
    for (int i = 0; i < m_n; ++i)
    {
        m_map[i][0] = m_map[i][m_m - 1] = 0;
    }
    for (int i = 0; i < m_m; ++i)
    {
        m_map[0][i] = m_map[m_n - 1][i] = 0;
    }
}

void MapWidget::changeCellState(const int x, const int y)
{
    m_map[x][y] = m_map[x][y] ? 0 : 2;
}

/*       /PRIVATE METHODS        */
/*        CONSTUCTORS            */

/*
MapWidget::MapWidget()
    : m_map(nullptr),
      m_n(DEFAULT_SIZE),
      m_m(DEFAULT_SIZE),
      m_cell_size(CELL_SIZE)
{
    m_map = new int*[DEFAULT_SIZE];
    for (int i = 0; i < DEFAULT_SIZE; ++i)
        m_map[i] = new int[DEFAULT_SIZE];
    if (m_map)
    {
        clearMap();
        generate();
    }
};
*/

MapWidget::MapWidget(QWidget *parent)
    : m_map(nullptr),
      m_n(DEFAULT_SIZE),
      m_m(DEFAULT_SIZE),
      m_cell_size(CELL_SIZE),
      QWidget(parent)
{
    m_map = new int*[DEFAULT_SIZE];
    for (int i = 0; i < DEFAULT_SIZE; ++i)
        m_map[i] = new int[DEFAULT_SIZE];
    if (m_map)
    {
        clearMap();
        generate();
    }
}

MapWidget::MapWidget(const int n, const int m)
    : m_map(nullptr),
      m_n(n),
      m_m(m),
      m_cell_size(CELL_SIZE)
{
    m_map = new int*[n];
    for (int i = 0; i < n; ++i)
        m_map[i] = new int[m];
    if (m_map)
    {
        clearMap();
        generate();
    }
};

/*       /CONSTUCTORS            */
/*        DESTRUCTOR             */

MapWidget::~MapWidget()
{
    for (int i = 0; i < m_n; ++i)
    {
        delete[] m_map[i];
    }
    delete[] m_map;
}

/*       /DESTRUCTOR             */
/*        PUBLIC METHODS         */

QSize MapWidget::sizeHint() const
{
    return QSize(m_n * m_cell_size, m_m * m_cell_size);
}

QSize MapWidget::minimumSize() const
{
    return QSize(m_n * m_cell_size, m_m * m_cell_size);
}

QSize MapWidget::maximumSize() const
{
    return QSize(m_n * m_cell_size, m_m * m_cell_size);
}

/*       /PUBLIC METHODS         */
/*        PROTECTED METHODS      */

void MapWidget::paintEvent(QPaintEvent *event)
{
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.fillRect(event->rect(), QBrush(Qt::darkGray));

    for (int i = 0; i < m_n; i++)
    {
        for (int j = 0; j < m_m; j++)
        {
            painter.fillRect(i * m_cell_size,
                                 j * m_cell_size,
                                 m_cell_size - m_cell_size / 20,
                                 m_cell_size - m_cell_size / 20,
                                 //m_map[i][j] ? QBrush(QPixmap("LiveCell_liveCell.png")) : QBrush(QPixmap("LiveCell_deadCell.png"))
                                 m_map[i][j] ? QBrush(HALL) : QBrush(WALL)
                                 );
        }
    }
}

void MapWidget::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton || event->button() == Qt::RightButton) {
        changeCellState(event->x() / m_cell_size, event->y() / m_cell_size);
        update();
    }
    else
        QWidget::mousePressEvent(event);
}

/*       /PROTECTED METHODS      */
