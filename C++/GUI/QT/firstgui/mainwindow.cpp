#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    for(int i = 0; i<10; i++){
        for(int j = 0; j<10;j++){
            QPushButton * a = new QPushButton("Hello");
            cells.push_front(a);
            ui->gridLayout_2->addWidget(a, i , j);
            a->setStyleSheet("Height:100;Width:100;padding:0;margin:0;background-color:red;");
        }
    }
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::paintEvent(QPaintEvent *event)
{
    QPainter painter(this);
    for(int i = 0; i<10; i++){
        for(int j = 0; j<10;j++){
        painter.drawRect(QRect(0+j*10, 30+i*10, 10, 10));
        }
    }
}



void MainWindow::on_pushButton_16_clicked()
{
    currentColour = colours[0];
}

void MainWindow::on_horizontalSlider_sliderMoved(int position)
{
}
