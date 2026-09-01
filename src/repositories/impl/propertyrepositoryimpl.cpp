#include "propertyrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonArray>
#include "services/apiclient.h"
#include <QList>

PropertyRepositoryImpl::PropertyRepositoryImpl(QObject *parent)
    : IPropertyRepository(parent)
{

}

void PropertyRepositoryImpl::getProperties(const QString &owner)
{
    QString url = "/house-listing/";
    // When an owner id is supplied, only fetch listings that belong to that
    // user (used by the agent dashboard's "My properties" view). Omitting it
    // returns every listing (admin "All properties" view).
    if (!owner.isEmpty())
        url += "?owner=" + owner;

    APIClient::instance().get(
        url.toUtf8(),
        [this] (bool success, const QJsonObject& response )
        {
            if (!success) {
                // Always clear loading state even when the fetch fails.
                emit propertyError(response.value("message").toString(
                                       QStringLiteral("Failed to load properties")));
                return;
            }
            QList<Property*> properties;
            if(response.contains("data")){
                // Backend wraps the list in "data.properties" (with pagination);
                // fall back to "data" being a plain array if the shape ever changes.
                QJsonArray dataArray;
                const QJsonValue dataValue = response.value("data");
                if (dataValue.isObject())
                    dataArray = dataValue.toObject().value("properties").toArray();
                else
                    dataArray = dataValue.toArray();

                for(const QJsonValue& value: std::as_const(dataArray)){
                    PropertyDto dto = PropertyDto::fromJson(value.toObject());
                    properties.append(dto.toDomainModel());
                }
                emit propertiesLoaded(properties);
            } else {
                // No "data" key: emit an error instead of an empty list so the
                // shared PropertyViewModel is not wiped out on a malformed reply.
                emit propertyError(QStringLiteral("Failed to load properties"));
            }
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

void PropertyRepositoryImpl::updatePropertyStatus(const QString &houseId, const QString &status, const QString &reason)
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
        "/house-listing/?status=" + status,
        [this] (bool success, const QJsonObject& response)
        {
            QList<Property*> properties;
            if(success && response.contains("data")){
                QJsonArray dataArray;
                const QJsonValue dataValue = response.value("data");
                if (dataValue.isObject())
                    dataArray = dataValue.toObject().value("properties").toArray();
                else
                    dataArray = dataValue.toArray();
                for(const QJsonValue& value: std::as_const(dataArray)){
                    PropertyDto dto = PropertyDto::fromJson(value.toObject());
                    properties.append(dto.toDomainModel());
                }
                emit propertiesLoaded(properties);
            }
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

void PropertyRepositoryImpl::deleteProperty(const QString &houseId)
{
    APIClient::instance().del(
        "/house-listing/" + houseId,
        [this, houseId] (bool success, const QJsonObject& response)
        {
            if(success){
                emit propertyDeleted(houseId);
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

