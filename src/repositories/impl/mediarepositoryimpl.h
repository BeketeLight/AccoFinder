#ifndef MEDIAREPOSITORYIMPL_H
#define MEDIAREPOSITORYIMPL_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QSharedPointer>
#include "models/media.h"
#include "services/apiclient.h"
#include "repositories/interfaces/IMediaRepository.h"
#include "application/dto/mediadto.h"

class MediaRepositoryImpl : public QObject, public IMediaRepository
{
    Q_OBJECT
public:
    MediaRepositoryImpl(QObject* parent = nullptr);

    void createMedia(const QString& propertyId,
                     const QString& url,
                     const QString& type,
                     bool isPrimary,
                     const QString& roomId) override;
    void getMediaByProperty(const QString& propertyId) override;

private:
    QList<QSharedPointer<Media>> m_media;
signals:
    void mediaCreated(const QSharedPointer<Media>& media);
    void mediaLoaded(const QList<QSharedPointer<Media>>& media);
    void error(const QString& message);
};

#endif // MEDIAREPOSITORYIMPL_H
