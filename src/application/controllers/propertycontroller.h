#ifndef PROPERTYCONTROLLER_H
#define PROPERTYCONTROLLER_H

#include <QObject>
#include <QList>
#include <QStringList>
#include <QJsonArray>
#include "models/property.h"
#include "repositories/impl/propertyrepositoryimpl.h"

class PropertyController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit PropertyController(QObject *parent = nullptr);

    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void getProperties(const QString& owner = QString());
    Q_INVOKABLE void getPropertyById(const QString& houseId);
    Q_INVOKABLE void getPropertiesByStatus(const QString& status);
    Q_INVOKABLE void createProperty(const QString& title, const QString& description,
                                    double price, const QString& propertyType,
                                    const QString& district,
                                    const QString& village, const QStringList& amenities,
                                    const QString& landlord, const QString& landlordPhone,
                                    const QString& verificationStatus, bool isActive,
                                    const QJsonArray& rooms = QJsonArray());
    Q_INVOKABLE void updateProperty(const QString& houseId,
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
    Q_INVOKABLE void deleteProperty(const QString& houseId);
    Q_INVOKABLE void attachMedia(const QString& houseId, const QStringList& mediaIds);

signals:
    void propertiesLoaded(QList<Property*>& properties);
    void propertyLoaded(Property* property);
    void propertyUpdated(Property* property);
    void propertyCreated(Property* property);
    void propertyDeleted(const QString& houseId);
    void propertyError(const QString& error);
    void isLoadingChanged(bool isLoading);

private:
    PropertyRepositoryImpl *m_propertyRepositoryImpl = nullptr;
    bool m_isLoading = false;

    void setLoading(bool loading);
};

#endif // PROPERTYCONTROLLER_H
