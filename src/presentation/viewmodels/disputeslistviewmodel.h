#ifndef DISPUTESLISTVIEWMODEL_H
#define DISPUTESLISTVIEWMODEL_H

#include <QObject>

class DisputesListViewModel : public QObject
{
    Q_OBJECT
public:
    explicit DisputesListViewModel(QObject *parent = nullptr);

signals:
};

#endif // DISPUTESLISTVIEWMODEL_H
