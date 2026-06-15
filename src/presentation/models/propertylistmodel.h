#ifndef PROPERTYLISTMODEL_H
#define PROPERTYLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include<QHash>
#include<QByteArray>
#include "models/property.h"

class PropertyListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole,
        TitleRole,
        LocationRole,
        AgentIdRole,
        LandlordIdRole,
        CreatedAtRole ,
        DescriptionRole,
        StatusRole

    };
    explicit PropertyListModel(QObject *parent = nullptr);

    // Header:
    // QVariant headerData(int section,
    //                     Qt::Orientation orientation,
    //                     int role = Qt::DisplayRole) const override;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int,QByteArray> roleNames() const override;

    void setProperties( QList<Property*>& newProperty);
    void updateProperty(int index,Property* property);
    void getPropertyById(int index);
    void clear();

private:
    QVector<Property*> m_properties;
};

#endif // PROPERTYLISTMODEL_H
