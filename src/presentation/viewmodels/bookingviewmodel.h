#ifndef BOOKINGVIEWMODEL_H
#define BOOKINGVIEWMODEL_H

#include <QObject>

class BookingViewModel : public QObject
{
    Q_OBJECT
public:
    explicit BookingViewModel(QObject *parent = nullptr);

signals:
};

#endif // BOOKINGVIEWMODEL_H
