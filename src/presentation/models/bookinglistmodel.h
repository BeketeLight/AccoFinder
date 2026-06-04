#ifndef BOOKINGLISTMODEL_H
#define BOOKINGLISTMODEL_H

#include <QAbstractListModel>

class BookingListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit BookingListModel(QObject *parent = nullptr);

    // Header:
    QVariant headerData(int section,
                        Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
};

#endif // BOOKINGLISTMODEL_H
