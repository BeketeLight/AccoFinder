#ifndef PROPERTYREPOSITORYIMPL_H
#define PROPERTYREPOSITORYIMPL_H

#include "application/dto/propertydto.h"
#include "repositories/interfaces/IPropertyRepository.h"
#include "models/property.h"
#include <QStringList>
#include <QJsonArray>
#include <QAtomicInt>

class PropertyRepositoryImpl : public IPropertyRepository
{
    Q_OBJECT
public:
    explicit PropertyRepositoryImpl(QObject *parent = nullptr);
    void getHouseListings(const PropertyQuery& query) override;
    void searchProperties(const PropertyQuery& query) override;
    void getAdminProperties() override;
    void getPropertiesOwnedBy(const QString& ownerId) override;
    void getPendingProperties() override;
    void getPropertyById(const QString& houseId) override;
    void getPropertiesByStatus(const QString& status) override;
    void createProperty(const QString& title, const QString& description,
                        double price, const QString& propertyType, const QString& district, const QString& village,
                        const QStringList& amenities, const QString& landlord,
                        const QString& landlordPhone, const QString& verificationStatus,
                        bool isActive, const QJsonArray& rooms) override;
    void updateProperty(const QString& houseId, const QString& title,
                        const QString& description, double price,
                        const QString& district, const QString& village,
                        const QStringList& amenities, const QString& landlord,
                        const QString& landlordPhone, const QString& verificationStatus,
                        bool isActive) override;
    void updatePropertyStatus(const QString& houseId, const QString& status,
                              const QString& reason = QString(),
                              const QString& approvedById = QString(),
                              const QString& approvedByName = QString()) override;
    void deleteProperty(const QString& houseId, bool force = false) override;
    void attachMedia(const QString& houseId, const QStringList& mediaIds) override;

private:
    // Incremented before every list/search request. The response lambda
    // captures this value and drops itself if a newer request has been
    // issued in the meantime. Prevents an older response (from "Bla")
    // overwriting a newer one (from "Blan").
    QAtomicInt m_listRequestToken{0};

signals:
    void propertyLoaded(Property* property);
    void propertiesLoaded(QList<Property*>& properties);
    // One owner's listings (every verification status), fetched for the admin
    // verification queue. Always emitted, with an empty list when the request
    // failed, so a caller walking several owners always advances.
    void ownedPropertiesLoaded(QList<Property*>& properties);
    // Every pending listing, fetched for the admin verification queue in a
    // single admin-scoped request. Always emitted, with an empty list when the
    // request failed.
    void pendingPropertiesLoaded(QList<Property*>& properties);
    void propertyUpdated(Property* properties);
    void propertyCreated(Property* property);
    void propertyDeleted(const QString& houseId);
    void propertyError(const QString& error);
    // The backend refused a delete with HTTP 409 because rooms still hold
    // bookings. Carries the count so the UI can offer an explicit override
    // instead of surfacing a generic failure.
    void propertyDeleteBlocked(int activeBookings);

    // Search-specific completion signal. Fires alongside propertiesLoaded
    // but carries the page number, so the ViewModel knows whether to replace
    // (page 1) or append (page > 1).
    void searchResultsLoaded(QList<Property*>& properties, int page);

};

#endif // PROPERTYREPOSITORYIMPL_H
