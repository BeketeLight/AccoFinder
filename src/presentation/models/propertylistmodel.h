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
        RoomCountRole,
        RejectionReasonRole,
        ApprovedByIdRole,
        ApprovedByNameRole,
        //Host--Property Owner
        OwnerIdRole,
        OwnerFirstNameRole,
        OwnerSurnameRole,
        OwnerEmailRole,
        OwnerPhoneRole,
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
    int indexOfPropertyId(const QString& propertyId) const;
    // Returns the property's amenities as a genuine list. Used by the detail
    // pages (which only know the propertyId) to avoid the fragility of passing
    // arrays through a QML ListModel and re-detecting them with Array.isArray.
    Q_INVOKABLE QVariantList amenitiesFor(const QString& propertyId) const;

    // Apply a new verification decision to a listing already held by this
    // model, in place. Used by the admin approval queue after a decision so
    // the row leaves (or stays in) the queue without another network round
    // trip. Only the status roles change, so no structural reset is emitted.
    void setVerificationStatus(const QString& propertyId, const QString& status,
                               const QString& reason = QString());

signals:
    void countChanged(int newCount);

private:
    QVector<Property*> m_properties;
};

#endif // PROPERTYLISTMODEL_H
