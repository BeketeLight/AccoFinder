#include "review.h"

Review::Review(QObject *parent)
    :QObject(parent)
{}

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
