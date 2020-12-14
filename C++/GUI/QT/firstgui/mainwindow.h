#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QPainter>
#include <QtCore>
#include <QtGui>
#include <QPushButton>
#include <QGridLayout>
#include <QScrollArea>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
    virtual void paintEvent(QPaintEvent *event);

private slots:
    void on_pushButton_16_clicked();

    void on_horizontalSlider_sliderMoved(int position);

private:
    QVector<int> colours {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
    int currentColour = 0;
    QVector<QPushButton*> cells;
    Ui::MainWindow *ui;
};
#endif // MAINWINDOW_H
