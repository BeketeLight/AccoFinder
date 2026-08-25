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
        "api/house-listing/",
        [this] (bool success, const QJsonObject& response )
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

void PropertyRepositoryImpl::getPropertyById(const QString& houseId)
{
    APIClient::instance().get(
        "api/house-listing/" + houseId,
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PropertyDto dto = PropertyDto::fromJson(response["data"].toObject());
                Property* property = dto.toDomainModel();

                emit propertyLoaded(property);
            }
           
        }
    );
    
}

void PropertyRepositoryImpl::updateProperty(const QString& houseId,const QString& title,const QString& description,double price,const QString& costCategory)
{
    PropertyDto dto(title,description,price,costCategory);

    APIClient::instance().put(
        "api/house-listing/:" + houseId, 
         dto.toUpdateJson(),
        [this] (bool success, const QJsonObject& response)
        {
            if(success){
                PropertyDto updatedDto = PropertyDto::fromJson(response["data"].toObject());
                Property* property = updatedDto.toDomainModel();
                emit propertyUpdated(property);
            }
          
        }
    );

}

void PropertyRepositoryImpl::getPropertiesByStatus(const QString &status)
{
    APIClient::instance().get(
        "api/house-listing/?status=" + status,
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

void PropertyRepositoryImpl::createProperty(const QString &title, const QString &description, double price, const QString &costCategory)
{
    PropertyDto dto(title, description, price, costCategory);

    APIClient::instance().post(
        "api/house-listing/",
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
        }
    );
}

void PropertyRepositoryImpl::deleteProperty(const QString &houseId)
{
    APIClient::instance().del(
        "api/house-listing/" + houseId,
        [this, houseId] (bool success, const QJsonObject& response)
        {
            if(success){
                emit propertyDeleted(houseId);
            } else {
                emit propertyError(response.value("message").toString());
            }
        }
    );
}

