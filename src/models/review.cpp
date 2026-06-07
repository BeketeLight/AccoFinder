#include "review.h"

Review::Review(const QString& id,
               int rating,
               const QString& comment,
               const QDateTime& createdAt,
               QObject* parent)
    : QObject(parent)
    , m_id(id)
    , m_rating(rating)
    , m_comment(comment)
    , m_createdAt(createdAt)
{
}

QString Review::getId() const
{
    return m_id;
}

int Review::getRating() const
{
    return m_rating;
}

QString Review::getComment() const
{
    return m_comment;
}

QDateTime Review::getCreatedAt() const
{
    return m_createdAt;
}
