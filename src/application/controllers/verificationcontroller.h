#ifndef VERIFICATIONCONTROLLER_H
#define VERIFICATIONCONTROLLER_H

#include <QObject>

class VerificationController : public QObject
{
    Q_OBJECT
public:
    explicit VerificationController(QObject *parent = nullptr);

signals:
};

#endif // VERIFICATIONCONTROLLER_H
