#ifndef REVIEWVIEWMODEL_H
#define REVIEWVIEWMODEL_H

#include <QObject>

class ReviewViewModel : public QObject
{
    Q_OBJECT
public:
    explicit ReviewViewModel(QObject *parent = nullptr);

signals:
};

#endif // REVIEWVIEWMODEL_H
