#include "propertyrepositoryimpl.h"
#include <QJsonObject>
#include <QJsonArray>
#include "services/apiclient.h"
#include <QList>

PropertyRepositoryImpl::PropertyRepositoryImpl(QObject *parent)
    : IPropertyRepository(parent)
{

}

QJsonObject PropertyRepositoryImpl::propertyDtoToJson(const PropertyDto& dto ) const
{
    QJsonObject json;
    json["id"] = dto.id;
    json["title"] = dto.title;
    json["location"] = dto.location;
    json["price"] = dto.price;
    json["description"] = dto.description;
    json["status"] = dto.status;
    json["agentId"] = dto.agentId;
    json["landlordId"] = dto.landlordId;
    json["createdAt"]  = dto.createdAt.toString(Qt::ISODate);
    
    return json;

}

PropertyDto PropertyRepositoryImpl::jsonToPropertyDto(const QJsonObject& json) const
{
    return PropertyDto::fromJson(json);
}

Property* PropertyRepositoryImpl::dtoToDomainModel(const PropertyDto& dto) const
{
    return dto.toDomainModel();
}

void PropertyRepositoryImpl::getProperties()
{
    APIClient::instance().get(
        "api/house-listing/",
        [this] (bool success, const QJsonObject& response )
        {
            QList<Property*> properties;
            if(success && response.contains("data")){
                QJsonArray dataArray = response["data"].toArray();
                for(const QJsonValue& value: dataArray){
                    PropertyDto dto = jsonToPropertyDto(value.toObject());
                    properties.append(dtoToDomainModel(dto));
                }
                emit propertiesLoaded(properties);
            }
          
        }
    );

}

void PropertyRepositoryImpl::getPropertyById(const QString& houseId)
{
    APIClient::instance().get(
        "api/house-listing/" + houseId,
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PropertyDto dto = jsonToPropertyDto(response);
                Property* property = dtoToDomainModel(dto);

                emit propertyLoaded(property);
            }
           
        }
    );
    
}

void PropertyRepositoryImpl::updateProperty(const QString& houseId, const PropertyDto& dto)
{
    QJsonObject payload = propertyDtoToJson(dto);
    APIClient::instance().put(
        "api/house-listing/:" + houseId, 
        payload,
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PropertyDto updatedDto = jsonToPropertyDto(response);
                Property* property = dtoToDomainModel(updatedDto);
                emit propertyUpdated(property);
            }
          
        }
    );

}

