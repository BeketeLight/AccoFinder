#ifndef APPLIFECYCLE_H
#define APPLIFECYCLE_H

#include <QObject>

class AppLifecycle : public QObject
{
    Q_OBJECT
public:
    explicit AppLifecycle(QObject *parent = nullptr);

    Q_INVOKABLE void quit();
};

#endif // APPLIFECYCLE_H
