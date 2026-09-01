#ifndef PROPERTYVIEWMODEL_H
#define PROPERTYVIEWMODEL_H

#include <QObject>
#include <QStringList>
#include <QJsonArray>
#include <QVariantList>
#include <QVariantMap>
#include "application/controllers/propertycontroller.h"
#include "presentation/models/propertylistmodel.h"

class PropertyViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PropertyListModel* propertyListModel READ propertyListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit PropertyViewModel(QObject *parent = nullptr);

    PropertyListModel* propertyListModel() const { return m_propertyListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE QVariantList propertiesForView() const;
    Q_INVOKABLE int pendingPropertiesCount() const;
    Q_INVOKABLE int verifiedPropertiesCount() const;
    Q_INVOKABLE void getProperties(const QString& owner = QString());
    Q_INVOKABLE void getPropertyById(const QString& houseId);
    // Row index of the property with the given backend id in the list model
    // (-1 when the property is not currently in the model).
    Q_INVOKABLE int indexOfProperty(const QString& houseId) const;
    Q_INVOKABLE void updateProperty(int index,
                                    const QString& houseId,
                                    const QString& title,
                                    const QString& description,
                                    double price,
                                    const QString& district,
                                    const QString& village,
                                    const QStringList& amenities,
                                    const QString& landlord,
                                    const QString& landlordPhone,
                                    const QString& verificationStatus,
                                    bool isActive);
    // Minimal status update used by the admin approve/reject flow. Persists the
    // new verificationStatus on the backend (not just the local list).
    Q_INVOKABLE void updatePropertyStatus(const QString& houseId, const QString& status, const QString& reason = QString());
    Q_INVOKABLE void createProperty(const QString& title,
                                    const QString& description,
                                    double price,
                                    const QString& propertyType,
                                    const QString& district,
                                    const QString& village,
                                    const QStringList& amenities,
                                    const QString& landlord,
                                    const QString& landlordPhone,
                                    const QString& verificationStatus,
                                    bool isActive,
                                    const QJsonArray& rooms = QJsonArray());
    Q_INVOKABLE void deleteProperty(const QString& houseId);
    Q_INVOKABLE void attachMedia(const QString& houseId, const QStringList& mediaIds);

private:
    int m_index = -1;
    bool m_isLoading = false;
    PropertyListModel* m_propertyListModel = nullptr;
    PropertyController* m_propertyController = nullptr;

    void setLoading(bool loading);

private slots:
    void onPropertiesLoaded(QList<Property*>& properties);
    void onGetPropertyById(Property* property);
    void onUpdateProperty(Property* property);
    void onCreateProperty(Property* property);
    void onPropertyDeleted(const QString& houseId);
    void onPropertyError(const QString& error);

signals:
    void isLoadingChanged(bool isLoading);
    void propertyError(const QString& error);
    void propertyCreatedSignal(const QString& id, const QString& title);
    void propertyUpdatedSignal(const QString& id);
    void propertyDeletedSignal(const QString& id);
};

#endif // PROPERTYVIEWMODEL_H
