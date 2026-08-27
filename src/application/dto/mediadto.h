#ifndef MEDIADTO_H
#define MEDIADTO_H

#include <QJsonObject>
#include "models/media.h"
#include <QSharedPointer>

class MediaDto
{
public:
    MediaDto();
    MediaDto(const QString& id,
             const QString& propertyId,
             const QString& url,
             const QString& type,
             bool isPrimary,
             const QString& roomId);

    QString m_id;
    QString m_propertyId;
    QString m_url;
    QString m_type;
    bool m_isPrimary;
    QString m_roomId;

    static MediaDto fromJson(const QJsonObject& json);

    QJsonObject toJson() const;

    QJsonObject toCreateJson() const;

    QSharedPointer<Media> toDomainModel() const;
};

#endif // MEDIADTO_H
