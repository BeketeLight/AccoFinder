#include "review.h"

Review::Review(const QString& id,
               const QString& clientId,
               const QString& propertyId,
               const QString& agentId,
               int rating,
               const QString& comment,
               const QDateTime& createdAt,
               QObject* parent)
    : QObject(parent)
    , m_id(id)
    , m_clientId(clientId)
    , m_propertyId(propertyId)
    , m_agentId(agentId)
    , m_rating(rating)
    , m_comment(comment)
    , m_createdAt(createdAt)
{}

QString Review::getId() const { return m_id; }
QString Review::getClientId() const { return m_clientId; }
QString Review::getPropertyId() const { return m_propertyId; }
QString Review::getAgentId() const { return m_agentId; }
int Review::getRating() const { return m_rating; }
QString Review::getComment() const { return m_comment; }
QDateTime Review::getCreatedAt() const { return m_createdAt; }