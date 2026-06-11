#ifndef PROPERTYREPOSITORYIMPL_H
#define PROPERTYREPOSITORYIMPL_H

#include "application/dto/propertydto.h"
#include "repositories/interfaces/IPropertyRepository.h"
#include "models/property.h"

class PropertyRepositoryImpl : public IPropertyRepository
{
    Q_OBJECT
public:
    explicit PropertyRepositoryImpl(QObject *parent = nullptr);
    void getProperties() override;
    void getPropertyById(const QString& houseId) override;
    void updateProperty(const QString& houseId, const PropertyDto& dto) override;

private:
//    ===== HELPER METHODS FOR DTO, JSON CONVERSION ====
QJsonObject propertyDtoToJson(const PropertyDto& dto ) const;
PropertyDto jsonToPropertyDto(const QJsonObject& json) const;
Property* dtoToDomainModel(const PropertyDto& dto) const;

signals:
    void propertyLoaded(Property* property);
    void propertiesLoaded(const QList<Property*>& properties);
    void propertyUpdated(Property* properties);
    void propertyError(const QString& error);

};

#endif // PROPERTYREPOSITORYIMPL_H
