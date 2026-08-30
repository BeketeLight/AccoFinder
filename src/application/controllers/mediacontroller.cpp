#include "mediacontroller.h"

MediaController::MediaController(QObject *parent)
    : QObject(parent),
      m_mediaRepositoryImpl(new MediaRepositoryImpl(this))
{
    connect(m_mediaRepositoryImpl, &MediaRepositoryImpl::mediaCreated,
            this, &MediaController::mediaCreated);
    connect(m_mediaRepositoryImpl, &MediaRepositoryImpl::mediaLoaded,
            this, &MediaController::mediaLoaded);
    connect(m_mediaRepositoryImpl, &MediaRepositoryImpl::mediaDeleted,
            this, &MediaController::mediaDeleted);
    connect(m_mediaRepositoryImpl, &MediaRepositoryImpl::mediaUpdated,
            this, &MediaController::mediaUpdated);
    connect(m_mediaRepositoryImpl, &MediaRepositoryImpl::error,
            this, &MediaController::onError);
}

void MediaController::createMedia(const QString &propertyId,
                                  const QString &url,
                                  const QString &type,
                                  bool isPrimary,
                                  const QString &roomId)
{
    if (propertyId.isEmpty()) {
        emit onError("propertyId cannot be empty");
        return;
    }
    if (url.isEmpty()) {
        emit onError("url cannot be empty");
        return;
    }
    m_mediaRepositoryImpl->createMedia(propertyId, url, type, isPrimary, roomId);
}

void MediaController::getMediaByProperty(const QString &propertyId)
{
    if (propertyId.isEmpty()) {
        emit onError("propertyId cannot be empty");
        return;
    }
    m_mediaRepositoryImpl->getMediaByProperty(propertyId);
}

void MediaController::deleteMedia(const QString &mediaId)
{
    if (mediaId.isEmpty()) {
        emit onError("mediaId cannot be empty");
        return;
    }
    m_mediaRepositoryImpl->deleteMedia(mediaId);
}

void MediaController::updateMediaPrimary(const QString &mediaId, bool isPrimary)
{
    if (mediaId.isEmpty()) {
        emit onError("mediaId cannot be empty");
        return;
    }
    m_mediaRepositoryImpl->updateMedia(mediaId, isPrimary);
}
