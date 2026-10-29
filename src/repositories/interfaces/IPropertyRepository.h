#ifndef IPROPERTYREPOSITORY_H
#define IPROPERTYREPOSITORY_H

#include <QObject>
#include <QStringList>
#include <QJsonArray>
#include "models/property.h"

// One struct for every filter the property list endpoint accepts. Every
// combination of search / type / district / village / amenities / price /
// pagination is a PropertyQuery with different fields populated.
//
// Passing a single struct rather than 10 positional arguments means:
//   - the caller can't forget a filter silently
//   - adding a new filter is one field, not one parameter in three files
//   - the URL builder is one function that reads the struct, not scattered
//     string concatenation at every call site
struct PropertyQuery
{
    QString owner;
    QString search;              // free text
    QString propertyType;        // "" | "WHOLE" | "HOSTEL" | "QUARTER"
    QString district;
    QString village;
    QStringList amenities;
    double minPrice = 0;         // 0 = unused
    double maxPrice = 0;         // 0 = unused
    int page = 1;
    int limit = 20;
    QString sortBy = QStringLiteral("createdAt");
    QString sortOrder = QStringLiteral("desc");

    // True when at least one filter is set. Used by the search screen to
    // distinguish "empty because the user hasn't searched yet" from "empty
    // because the search returned nothing".
    bool hasAnyFilter() const
    {
        return !search.isEmpty()
        || !propertyType.isEmpty()
            || !district.isEmpty()
            || !village.isEmpty()
            || !amenities.isEmpty()
            || minPrice > 0
            || maxPrice > 0;
    }
};


class IPropertyRepository : public QObject
{
    Q_OBJECT
public:
    explicit IPropertyRepository(QObject *parent = nullptr)
        : QObject(parent) {}
    // `owner` was rolled into PropertyQuery so the admin's owner-scoped view
    // and the client's search both travel through one method. Existing call
    // sites construct PropertyQuery{ .owner = ... }.
    virtual void getProperties(const PropertyQuery& query) = 0;

    // Admin-only listing (GET /house-listing/admin): every status, not just
    // VERIFIED. The public listing endpoint is unauthenticated, so it can never
    // recognise an admin and always hides unverified listings.
    virtual void getAdminProperties() = 0;

    // Listings that still need a decision are only returned when the request is
    // scoped to a single listing owner: GET /house-listing/ without `owner`
    // answers with VERIFIED listings only, while /dashboard/stats counts every
    // pending one. The admin verification queue therefore walks the owners and
    // asks for their unverified listings, delivered on its own signal so the
    // shared property list is never replaced by them.
    virtual void getPropertiesOwnedBy(const QString& ownerId) = 0;

    // Every listing awaiting a decision, fetched in one admin-scoped request
    // (GET /house-listing/?verificationStatus=PENDING). Preferred over walking
    // owners for the admin verification queue, because the listing's owner id
    // is a user id and is not necessarily present in the agent list.
    virtual void getPendingProperties() = 0;

    virtual void getPropertyById(const QString& houseId) = 0;
    virtual void getPropertiesByStatus(const QString& status) = 0;
    virtual void createProperty(const QString& title, const QString& description,
                                double price, const QString& propertyType, const QString& district, const QString& village,
                                const QStringList& amenities, const QString& landlord,
                                const QString& landlordPhone, const QString& verificationStatus,
                                bool isActive, const QJsonArray& rooms = QJsonArray()) = 0;
    virtual void updateProperty(const QString& houseId, const QString& title,
                                const QString& description, double price,
                                const QString& district, const QString& village,
                                const QStringList& amenities, const QString& landlord,
                                const QString& landlordPhone, const QString& verificationStatus,
                                bool isActive) = 0;
    virtual void updatePropertyStatus(const QString& houseId, const QString& status, const QString& reason = QString(),
                                      const QString& approvedById = QString(), const QString& approvedByName = QString()) = 0;
    // force skips the backend's active-booking guard. It is only ever set after
    // the user has explicitly confirmed the override dialog.
    virtual void deleteProperty(const QString& houseId, bool force = false) = 0;
    virtual void attachMedia(const QString& houseId, const QStringList& mediaIds) = 0;

    virtual ~IPropertyRepository() {}

};

#endif // IPROPERTYREPOSITORY_H
