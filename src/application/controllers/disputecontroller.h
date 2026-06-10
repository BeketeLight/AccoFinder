#ifndef DISPUTECONTROLLER_H
#define DISPUTECONTROLLER_H

#include <QObject>

class DisputeController : public QObject
{
    Q_OBJECT
public:
    explicit DisputeController(QObject *parent = nullptr);

signals:
};

#endif // DISPUTECONTROLLER_H
