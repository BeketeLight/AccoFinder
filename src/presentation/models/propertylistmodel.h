#ifndef PROPERTYLISTMODEL_H
#define PROPERTYLISTMODEL_H

#include <QAbstractListModel>

class PropertyListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit PropertyListModel(QObject *parent = nullptr);

    // Header:
    QVariant headerData(int section,
                        Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
};

#endif // PROPERTYLISTMODEL_H
