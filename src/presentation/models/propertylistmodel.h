#ifndef PROPERTYLISTMODEL_H
#define PROPERTYLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include<QHash>
#include<QByteArray>
#include <QVariantMap>
#include <QVariantList>
#include "models/property.h"

class PropertyListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole,
        FirstNameRole,
        SecondNameRole,
        TitleRole,
        LocationRole,
        PriceRole,
        AgentIdRole,
        AgentPhoneRole,
        LandlordIdRole,
        CreatedAtRole,
        DescriptionRole,
        StatusRole,
        DistrictRole,
        VillageRole,
        AmenitiesRole,
        LandlordPhoneRole,
        VerificationStatusRole,
        IsActiveRole,
        PropertyTypeRole,
        RoomCountRole
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
    void appendProperty(Property* property);
    void updateProperty(int index,Property* property);
    void removeProperty(const QString& propertyId);
    void getPropertyById(Property* property);
    void clear();

    Q_INVOKABLE int size() const { return m_properties.size(); }
    Q_INVOKABLE QVariantMap at(int index) const;
    // Returns the property's amenities as a genuine list. Used by the detail
    // pages (which only know the propertyId) to avoid the fragility of passing
    // arrays through a QML ListModel and re-detecting them with Array.isArray.
    Q_INVOKABLE QVariantList amenitiesFor(const QString& propertyId) const;

signals:
    void countChanged(int newCount);

private:
    QVector<Property*> m_properties;
};

#endif // PROPERTYLISTMODEL_H
