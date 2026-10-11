#include "reviewrepositoryimpl.h"
#include <QJsonArray>
#include <QJsonObject>

ReviewRepositoryImpl::ReviewRepositoryImpl(QObject* parent)
    : IReviewRepository(parent)
{
}

void ReviewRepositoryImpl::fetchByProperty(const QString& propertyId)
{
    APIClient::instance().get(
        "/reviews/property/" + propertyId,
        [this](bool success, const QJsonObject& response)
        {
            if (success && response.contains("data")) {
                const QJsonArray arr = response["data"].toArray();
                QList<QSharedPointer<Review>> list;
                list.reserve(arr.size());
                for (const QJsonValue& v : std::as_const(arr))
                    list.append(ReviewDto::fromJson(v.toObject()).toDomainModel());
                emit reviewsFetched(list);
            } else {
                emit error(response.value("message").toString());
            }
        }, false
        );
}

void ReviewRepositoryImpl::fetchByAgent(const QString& agentId)
{
    APIClient::instance().get(
        "/reviews/agent/" + agentId,
        [this](bool success, const QJsonObject& response)
        {
            if (success && response.contains("data")) {
                const QJsonArray arr = response["data"].toArray();
                QList<QSharedPointer<Review>> list;
                list.reserve(arr.size());
                for (const QJsonValue& v : std::as_const(arr))
                    list.append(ReviewDto::fromJson(v.toObject()).toDomainModel());
                emit reviewsFetched(list);
            } else {
                emit error(response.value("message").toString());
            }
        }, false
        );
}

void ReviewRepositoryImpl::createReview(const QString& propertyId,
                                        const QString& agentId,
                                        int rating,
                                        const QString& comment)
{
    ReviewDto dto;
    dto.propertyId = propertyId;
    dto.agentId    = agentId;
    dto.rating     = rating;
    dto.comment    = comment;

    APIClient::instance().post(
        "/reviews",
        dto.toJson(),
        [this](bool success, const QJsonObject& response)
        {
            if (success && response.contains("data")) {
                ReviewDto respDto = ReviewDto::fromJson(response["data"].toObject());
                emit reviewCreated(respDto.toDomainModel());
            } else {
                emit error(response.value("message").toString());
            }
        }
        );
}

void ReviewRepositoryImpl::updateReview(const QString& id,
                                        int rating,
                                        const QString& comment)
{
    QJsonObject body;
    body["rating"]  = rating;
    body["comment"] = comment;

    APIClient::instance().patch(
        "/reviews/" + id,
        body,
        [this](bool success, const QJsonObject& response)
        {
            if (success && response.contains("data")) {
                ReviewDto dto = ReviewDto::fromJson(response["data"].toObject());
                emit reviewUpdated(dto.toDomainModel());
            } else {
                emit error(response.value("message").toString());
            }
        }
        );
}

void ReviewRepositoryImpl::deleteReview(const QString& id)
{
    APIClient::instance().del(
        "/reviews/" + id,
        [this, id](bool success, const QJsonObject& response)
        {
            if (success)
                emit reviewDeleted(id);
            else
                emit error(response.value("message").toString());
        }
        );
}