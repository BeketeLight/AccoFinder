#include "reviewdto.h"

ReviewDto ReviewDto::fromJson(const QJsonObject& obj)
{
    ReviewDto dto;
    dto.id         = obj.value("_id").toString();
    dto.clientId   = obj.value("clientId").toVariant().toString();
    dto.propertyId = obj.value("propertyId").toVariant().toString();
    dto.agentId    = obj.value("agentId").toVariant().toString();
    dto.rating     = obj.value("rating").toInt();
    dto.comment    = obj.value("comment").toString();
    dto.createdAt  = QDateTime::fromString(
        obj.value("createdAt").toString(), Qt::ISODate);
    return dto;
}

QJsonObject ReviewDto::toJson() const
{
    QJsonObject obj;
    if (!id.isEmpty())
        obj.insert("_id", id);
    obj.insert("clientId",   clientId);
    obj.insert("propertyId", propertyId);
    obj.insert("agentId",    agentId);
    obj.insert("rating",     rating);
    obj.insert("comment",    comment);
    if (createdAt.isValid())
        obj.insert("createdAt", createdAt.toString(Qt::ISODate));
    return obj;
}

QSharedPointer<Review> ReviewDto::toDomainModel() const
{
    return QSharedPointer<Review>(new Review(
        id,
        clientId,
        propertyId,
        agentId,
        rating,
        comment,
        createdAt
        ));
}

ReviewDto ReviewDto::fromDomainModel(const Review* review)
{
    ReviewDto dto;
    if (!review) return dto;

    dto.id         = review->getId();
    dto.clientId   = review->getClientId();
    dto.propertyId = review->getPropertyId();
    dto.agentId    = review->getAgentId();
    dto.rating     = review->getRating();
    dto.comment    = review->getComment();
    dto.createdAt  = review->getCreatedAt();
    return dto;
}