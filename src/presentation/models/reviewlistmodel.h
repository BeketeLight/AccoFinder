#ifndef REVIEWLISTMODEL_H
#define REVIEWLISTMODEL_H

#include <QAbstractListModel>

class ReviewListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit ReviewListModel(QObject *parent = nullptr);

    // Header:
    QVariant headerData(int section,
                        Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
};

#endif // REVIEWLISTMODEL_H
