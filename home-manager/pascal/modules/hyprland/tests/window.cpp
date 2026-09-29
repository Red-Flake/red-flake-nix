#include <QApplication>
#include <QMainWindow>
#include <QMenuBar>
#include <QMenu>
#include <QLabel>
#include <QSocketNotifier>
#include <iostream>
#include <unistd.h>
int main(int argc, char** argv) {
    QApplication app(argc, argv);
    app.setApplicationName("StellarisTest");
    QMainWindow first, second;
    int number = 0;
    for (auto window : {&first, &second}) {
        window->setWindowTitle(QString("Stellaris test %1").arg(++number));
        window->resize(480, 300);
        window->setCentralWidget(new QLabel("Real Qt window: titlebars, menus and native minimize"));
        auto menu = window->menuBar()->addMenu(QString("&Window%1").arg(number));
        auto action = menu->addAction("&Test action");
        QObject::connect(action, &QAction::triggered, [number]() { std::cout << "clicked " << number << std::endl; });
        window->show();
    }
    QSocketNotifier input(STDIN_FILENO, QSocketNotifier::Read);
    QObject::connect(&input, &QSocketNotifier::activated, [&]() {
        std::string command;
        std::getline(std::cin, command);
        if (command == "minimize") first.showMinimized();
        if (command == "restore") first.showNormal();
        if (command == "maximize") second.showMaximized();
        if (command == "focus") { first.raise(); first.activateWindow(); }
        if (command == "quit" || std::cin.eof()) app.quit();
        std::cout << "command " << command << " states " << first.windowState() << " " << second.windowState() << std::endl;
    });
    return app.exec();
}
