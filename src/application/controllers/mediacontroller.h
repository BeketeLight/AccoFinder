#ifndef MEDIACONTROLLER_H
#define MEDIACONTROLLER_H

#include <QObject>
#include <QString>
#include "repositories/impl/mediarepositoryimpl.h"

class MediaController : public QObject
{
    Q_OBJECT
public:
    explicit MediaController(QObject *parent = nullptr);

    Q_INVOKABLE void createMedia(const QString& propertyId,
                                 const QString& url,
                                 const QString& type,
                                 bool isPrimary,
                                 const QString& roomId);
    Q_INVOKABLE void getMediaByProperty(const QString& propertyId);
    Q_INVOKABLE void deleteMedia(const QString& mediaId);
    Q_INVOKABLE void updateMediaPrimary(const QString& mediaId, bool isPrimary);

signals:
    void mediaCreated(const QSharedPointer<Media>& media);
    void mediaLoaded(const QList<QSharedPointer<Media>>& media);
    void mediaDeleted(const QString& mediaId);
    void mediaUpdated(const QSharedPointer<Media>& media);
    void onError(const QString& message);

private:
    MediaRepositoryImpl* m_mediaRepositoryImpl = nullptr;
};

#endif // MEDIACONTROLLER_H
