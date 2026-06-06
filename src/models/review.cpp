#include "review.h"

Review::Review(QObject *parent)
    :QObject(parent)
{}
Review::Review(const QString& newId,
               int newRating,
               const QString& newComment,
               const QDateTime& newCreatedAt,
               QObject* parent)
    : QObject(parent)
    , id(newId)
    , rating(newRating)
    , comment(newComment)
    , createdAt(newCreatedAt)
{
}

QString Review::getId() const
{
    return id;
}

void Review::setId(const QString &newId)
{
    id = newId;
}

int Review::getRating() const
{
    return rating;
}

void Review::setRating(int newRating)
{
    rating = newRating;
}

QString Review::getComment() const
{
    return comment;
}

void Review::setComment(const QString &newComment)
{
    comment = newComment;
}

QDateTime Review::getCreatedAt() const
{
    return createdAt;
}

void Review::setCreatedAt(const QDateTime &newCreatedAt)
{
    createdAt = newCreatedAt;
}
