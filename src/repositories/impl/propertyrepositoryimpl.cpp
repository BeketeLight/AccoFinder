#include "propertyrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>
#include "services/apiclient.h"
#include <QList>
#include <QUrlQuery>

namespace {

// The listing endpoints answer with { "data": { "properties": [...],
// "pagination": {...} } }, but a plain { "data": [...] } has been seen too, so
// accept both shapes instead of duplicating the unwrapping per endpoint.
QList<Property*> parseListingResponse(const QJsonObject& response)
{
    QList<Property*> properties;
    const QJsonValue dataValue = response.value("data");
    QJsonArray dataArray;
    if (dataValue.isObject())
        dataArray = dataValue.toObject().value("properties").toArray();
    else if (dataValue.isArray())
        dataArray = dataValue.toArray();

    for (const QJsonValue& value : std::as_const(dataArray))
        properties.append(PropertyDto::fromJson(value.toObject()).toDomainModel());

    return properties;
}

}

PropertyRepositoryImpl::PropertyRepositoryImpl(QObject *parent)
    : IPropertyRepository(parent)
{

}

// void PropertyRepositoryImpl::getHouseListings(const PropertyQuery &query)
// {

// }
void PropertyRepositoryImpl::getHouseListings(const PropertyQuery& query)
{
    // Build the query string once, from the struct. Empty fields are skipped,
    // so a default PropertyQuery{ .owner = ... } produces exactly the URL the
    // old overload produced, and the admin view keeps working unchanged.
    QUrlQuery params;
    if (!query.owner.isEmpty())
        params.addQueryItem("owner", query.owner);
    if (!query.search.isEmpty())
        params.addQueryItem("search", query.search);
    if (!query.propertyType.isEmpty())
        params.addQueryItem("propertyType", query.propertyType);
    if (!query.district.isEmpty())
        params.addQueryItem("district", query.district);
    if (!query.village.isEmpty())
        params.addQueryItem("village", query.village);
    if (!query.amenities.isEmpty())
        params.addQueryItem("amenities", query.amenities.join(','));
    // Price filters are only sent when the backend supports them. Until
    // queryPropertySchema grows minPrice/maxPrice, sending these is a silent
    // no-op because Joi strips unknown keys — so we still send them. Once
    // the backend adds the fields, no client change is needed.
    if (query.minPrice > 0)
        params.addQueryItem("minPrice", QString::number(query.minPrice, 'f', 0));
    if (query.maxPrice > 0)
        params.addQueryItem("maxPrice", QString::number(query.maxPrice, 'f', 0));
    params.addQueryItem("page",  QString::number(qMax(1, query.page)));
    params.addQueryItem("limit", QString::number(qBound(1, query.limit, 100)));
    if (!query.sortBy.isEmpty())
        params.addQueryItem("sortBy", query.sortBy);
    if (!query.sortOrder.isEmpty())
        params.addQueryItem("sortOrder", query.sortOrder);

    QString url = QStringLiteral("/properties/");
    const QString qs = params.toString(QUrl::FullyEncoded);
    if (!qs.isEmpty())
        url += QStringLiteral("?") + qs;

    // Capture the token before the request; drop the response if a newer
    // request has been issued since.
    const int myToken = m_listRequestToken.fetchAndAddOrdered(1) + 1;
    const int requestedPage = qMax(1, query.page);
    const bool isSearch = query.hasAnyFilter();

    APIClient::instance().get(
        url.toUtf8(),
        [this, myToken, requestedPage, isSearch] (bool success, const QJsonObject& response)
        {
            // Stale response: a newer request has been issued since this one
            // was sent. Discard silently — the newer request will fire its
            // own signal when it returns.
            if (myToken != m_listRequestToken.loadRelaxed())
                return;

            if (!success) {
                emit propertyError(response.value("message").toString(
                    QStringLiteral("Failed to load properties")));
                return;
            }
            if (!response.contains("data")) {
                emit propertyError(QStringLiteral("Failed to load properties"));
                return;
            }
            QList<Property*> properties = parseListingResponse(response);
            propertiesLoaded(properties);
        }
        );
}

void PropertyRepositoryImpl::searchProperties(const PropertyQuery& query)
{
    // Build the query string once, from the struct. Empty fields are skipped,
    // so a default PropertyQuery{ .owner = ... } produces exactly the URL the
    // old overload produced, and the admin view keeps working unchanged.
    QUrlQuery params;
    if (!query.owner.isEmpty())
        params.addQueryItem("owner", query.owner);
    if (!query.search.isEmpty())
        params.addQueryItem("search", query.search);
    if (!query.propertyType.isEmpty())
        params.addQueryItem("propertyType", query.propertyType);
    if (!query.district.isEmpty())
        params.addQueryItem("district", query.district);
    if (!query.village.isEmpty())
        params.addQueryItem("village", query.village);
    if (!query.amenities.isEmpty())
        params.addQueryItem("amenities", query.amenities.join(','));
    // Price filters are only sent when the backend supports them. Until
    // queryPropertySchema grows minPrice/maxPrice, sending these is a silent
    // no-op because Joi strips unknown keys — so we still send them. Once
    // the backend adds the fields, no client change is needed.
    if (query.minPrice > 0)
        params.addQueryItem("minPrice", QString::number(query.minPrice, 'f', 0));
    if (query.maxPrice > 0)
        params.addQueryItem("maxPrice", QString::number(query.maxPrice, 'f', 0));
    params.addQueryItem("page",  QString::number(qMax(1, query.page)));
    params.addQueryItem("limit", QString::number(qBound(1, query.limit, 100)));
    if (!query.sortBy.isEmpty())
        params.addQueryItem("sortBy", query.sortBy);
    if (!query.sortOrder.isEmpty())
        params.addQueryItem("sortOrder", query.sortOrder);

    QString url = QStringLiteral("/properties/");
    const QString qs = params.toString(QUrl::FullyEncoded);
    if (!qs.isEmpty())
        url += QStringLiteral("?") + qs;

    // Capture the token before the request; drop the response if a newer
    // request has been issued since.
    const int myToken = m_listRequestToken.fetchAndAddOrdered(1) + 1;
    const int requestedPage = qMax(1, query.page);
    const bool isSearch = query.hasAnyFilter();

    APIClient::instance().get(
        url.toUtf8(),
        [this, myToken, requestedPage, isSearch] (bool success, const QJsonObject& response)
        {
            // Stale response: a newer request has been issued since this one
            // was sent. Discard silently — the newer request will fire its
            // own signal when it returns.
            if (myToken != m_listRequestToken.loadRelaxed())
                return;

            if (!success) {
                emit propertyError(response.value("message").toString(
                    QStringLiteral("Failed to load properties")));
                return;
            }
            if (!response.contains("data")) {
                emit propertyError(QStringLiteral("Failed to load properties"));
                return;
            }
            QList<Property*> properties = parseListingResponse(response);
            if (isSearch)
                emit searchResultsLoaded(properties, requestedPage);
        }
        );
}

void PropertyRepositoryImpl::getAdminProperties()
{
    // Authenticated admin listing: returns every status. Uses a high limit so
    // the admin pages are not silently truncated by the default pagination.
    APIClient::instance().get(
        "/house-listing/admin?limit=100",
        [this] (bool success, const QJsonObject& response)
        {
            if (!success) {
                emit propertyError(response.value("message").toString(
                    QStringLiteral("Failed to load properties")));
                return;
            }
            if (!response.contains("data")) {
                emit propertyError(QStringLiteral("Failed to load properties"));
                return;
            }
            QList<Property*> properties = parseListingResponse(response);
            emit propertiesLoaded(properties);
        }
        );
}

void PropertyRepositoryImpl::getPropertiesOwnedBy(const QString &ownerId)
{
    if (ownerId.isEmpty())
        return;

    APIClient::instance().get(
        ("/house-listing/?owner=" + QUrl::toPercentEncoding(ownerId)),
        [this] (bool success, const QJsonObject& response)
        {
            QList<Property*> properties;
            if (success && response.contains("data"))
                properties = parseListingResponse(response);
            // A failed owner request must not stop the caller from walking the
            // remaining owners, so the signal fires either way.
            emit ownedPropertiesLoaded(properties);
        }
        );
}

void PropertyRepositoryImpl::getPendingProperties()
{
    // Authenticated admin listing filtered to PENDING. The unauthenticated
    // public endpoint cannot see the caller's role and would return VERIFIED
    // listings instead.
    APIClient::instance().get(
        "/house-listing/admin?verificationStatus=PENDING&limit=100",
        [this] (bool success, const QJsonObject& response)
        {
            QList<Property*> properties;
            if (success && response.contains("data"))
                properties = parseListingResponse(response);
            // Emitted either way so the caller's loading state always settles.
            emit pendingPropertiesLoaded(properties);
        }
        );
}

void PropertyRepositoryImpl::getPropertyById(const QString& houseId)
{
    APIClient::instance().get(
        "/house-listing/" + houseId,
        [this] (bool success, const QJsonObject& response)
        {
            if (!success) {
                emit propertyError(response.value("message").toString(
                    QStringLiteral("Failed to load property")));
                return;
            }
            if(success){
                PropertyDto dto = PropertyDto::fromJson(response["data"].toObject());
                Property* property = dto.toDomainModel();

                emit propertyLoaded(property);
            }

        }
        );
    
}

void PropertyRepositoryImpl::updateProperty(const QString& houseId, const QString& title,
                                            const QString& description, double price,
                                            const QString& district, const QString& village,
                                            const QStringList& amenities, const QString& landlord,
                                            const QString& landlordPhone, const QString& verificationStatus,
                                            bool isActive)
{
    PropertyDto dto(title, description, price, QString(), district, village, amenities,
                    landlord, landlordPhone, verificationStatus, isActive);

    APIClient::instance().put(
        "/house-listing/" + houseId, 
        dto.toUpdateJson(),
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PropertyDto updatedDto = PropertyDto::fromJson(response["data"].toObject());
                Property* property = updatedDto.toDomainModel();
                emit propertyUpdated(property);
            }

        }, false
        );

}

void PropertyRepositoryImpl::updatePropertyStatus(const QString &houseId, const QString &status, const QString &reason,
                                                  const QString &approvedById, const QString &approvedByName)
{
    if (houseId.isEmpty()) {
        emit propertyError(QStringLiteral("houseId cannot be empty"));
        return;
    }
    QString normalized = status.trimmed().toUpper();
    if (normalized != QStringLiteral("PENDING")
        && normalized != QStringLiteral("VERIFIED")
        && normalized != QStringLiteral("REJECTED")
        && normalized != QStringLiteral("DRAFT")) {
        emit propertyError(QStringLiteral("Invalid verification status"));
        return;
    }

    QJsonObject payload;
    payload["verificationStatus"] = normalized;
    if (normalized == QStringLiteral("REJECTED"))
        payload["verificationReason"] = reason.trimmed();

    // Record who approved this listing.
    // NOTE: the backend's property-update schema must accept `approvedBy`
    // (and `approvedByName`) or the approve call will 400 with
    // "Not authorized to perform this action" style validation.
    if (normalized == QStringLiteral("VERIFIED") && !approvedById.isEmpty()) {
        payload["approvedBy"] = approvedById;
        if (!approvedByName.isEmpty())
            payload["approvedByName"] = approvedByName;
    }

    APIClient::instance().put(
        "/house-listing/" + houseId,
        payload,
        [this] (bool success, const QJsonObject& response)
        {
            if (success) {
                PropertyDto updatedDto = PropertyDto::fromJson(response["data"].toObject());
                Property* property = updatedDto.toDomainModel();
                emit propertyUpdated(property);
            } else {
                emit propertyError(response.value("message").toString(
                    QStringLiteral("Failed to update property status")));
            }
        }, false
        );
}

void PropertyRepositoryImpl::getPropertiesByStatus(const QString &status)
{
    APIClient::instance().get(
        "/house-listing/?verificationStatus=" + status,
        [this] (bool success, const QJsonObject& response)
        {
            QList<Property*> properties;
            if(success && response.contains("data"))
                properties = parseListingResponse(response);
            emit propertiesLoaded(properties);
        }
        );
}

void PropertyRepositoryImpl::createProperty(const QString &title, const QString &description, double price,
                                            const QString &propertyType, const QString &district, const QString &village,
                                            const QStringList &amenities, const QString &landlord,
                                            const QString &landlordPhone, const QString &verificationStatus,
                                            bool isActive, const QJsonArray &rooms)
{
    // The backend only accepts PENDING/VERIFIED/REJECTED/DRAFT and rejects an
    // empty string, so default an unset verificationStatus to PENDING.
    QString effectiveStatus = verificationStatus;
    if (effectiveStatus.trimmed().isEmpty())
        effectiveStatus = QStringLiteral("PENDING");

    PropertyDto dto(title, description, price, propertyType, district, village, amenities,
                    landlord, landlordPhone, effectiveStatus, isActive, rooms);

    APIClient::instance().post(
        "/house-listing/",
        dto.toCreateJson(),
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PropertyDto createdDto = PropertyDto::fromJson(response["data"].toObject());
                Property* property = createdDto.toDomainModel();
                emit propertyCreated(property);
            } else {
                emit propertyError(response.value("message").toString());
            }
        }, false
        );
}

void PropertyRepositoryImpl::deleteProperty(const QString &houseId, bool force)
{
    // The backend rejects the delete with 409 while any room of the property
    // still holds a booking. force=true is the override, and is only ever sent
    // after the user has confirmed the warning dialog.
    const QString endpoint = "/house-listing/" + houseId
                             + (force ? QStringLiteral("?force=true") : QString());

    APIClient::instance().del(
        endpoint,
        [this, houseId] (bool success, const QJsonObject& response)
        {
            if(success){
                emit propertyDeleted(houseId);
            } else if(response.contains("activeBookings")) {
                // 409 body carries the blocking count alongside the message.
                emit propertyDeleteBlocked(response.value("activeBookings").toInt());
            } else {
                emit propertyError(response.value("message").toString());
            }
        }, false
        );
}

void PropertyRepositoryImpl::attachMedia(const QString &houseId, const QStringList &mediaIds)
{
    QJsonArray mediaArray;
    for (const QString& id : mediaIds)
        mediaArray.append(id);

    QJsonObject payload;
    payload["media"] = mediaArray;

    APIClient::instance().put(
        "/house-listing/" + houseId,
        payload,
        [this, houseId] (bool success, const QJsonObject& response)
        {
            if (!success)
                emit propertyError(response.value("message").toString());
            Q_UNUSED(houseId)
        }, false
        );
}

