#ifndef REVIEWDTO_H
#define REVIEWDTO_H

#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include <QSharedPointer>
#include "models/review.h"

class ReviewDto
{
public:
    QString id;
    QString clientId;
    QString propertyId;
    QString agentId;
    int rating = 0;
    QString comment;
    QDateTime createdAt;

    static ReviewDto fromJson(const QJsonObject& obj);
    QJsonObject toJson() const;

    QSharedPointer<Review> toDomainModel() const;    // ← renamed

    static ReviewDto fromDomainModel(const Review* review);
};

#endif // REVIEWDTO_H