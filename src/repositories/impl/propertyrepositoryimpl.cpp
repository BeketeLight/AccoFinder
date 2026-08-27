#include "propertyrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonArray>
#include "services/apiclient.h"
#include <QList>

PropertyRepositoryImpl::PropertyRepositoryImpl(QObject *parent)
    : IPropertyRepository(parent)
{

}

void PropertyRepositoryImpl::getProperties()
{
    APIClient::instance().get(
        "/house-listing/",
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
                QJsonArray dataArray = response["data"].toArray();
                for(const QJsonValue& value: std::as_const(dataArray)){
                    PropertyDto dto = PropertyDto::fromJson(value.toObject());
                    properties.append(dto.toDomainModel());
                }
                emit propertiesLoaded(properties);
            } else {
                emit propertiesLoaded(properties);
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
        "/house-listing/:" + houseId, 
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

void PropertyRepositoryImpl::getPropertiesByStatus(const QString &status)
{
    APIClient::instance().get(
        "/house-listing/?status=" + status,
        [this] (bool success, const QJsonObject& response)
        {
            QList<Property*> properties;
            if(success && response.contains("data")){
                QJsonArray dataArray = response["data"].toArray();
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
    PropertyDto dto(title, description, price, propertyType, district, village, amenities,
                    landlord, landlordPhone, verificationStatus, isActive, rooms);

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

