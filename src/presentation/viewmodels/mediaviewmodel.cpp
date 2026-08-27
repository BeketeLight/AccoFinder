#include "mediaviewmodel.h"

MediaViewModel::MediaViewModel(QObject *parent)
    : QObject(parent),
      m_mediaListModel(new MediaListModel(this)),
      m_mediaController(new MediaController(this))
{
    connect(m_mediaController, &MediaController::mediaCreated,
            this, &MediaViewModel::onMediaCreated);
    connect(m_mediaController, &MediaController::mediaLoaded,
            this, &MediaViewModel::onMediaLoaded);
    connect(m_mediaController, &MediaController::onError,
            this, &MediaViewModel::onError);
}

void MediaViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged(loading);
    }
}

void MediaViewModel::createMedia(const QString &propertyId,
                                 const QString &url,
                                 const QString &type,
                                 bool isPrimary,
                                 const QString &roomId)
{
    setLoading(true);
    m_mediaController->createMedia(propertyId, url, type, isPrimary, roomId);
}

void MediaViewModel::getMediaByProperty(const QString &propertyId)
{
    setLoading(true);
    m_mediaController->getMediaByProperty(propertyId);
}

void MediaViewModel::onMediaCreated(const QSharedPointer<Media> &media)
{
    setLoading(false);
    if (m_mediaListModel)
        m_mediaListModel->appendMedia(media);
    emit mediaCreatedSignal(media->getId());
}

void MediaViewModel::onMediaLoaded(const QList<QSharedPointer<Media>> &media)
{
    setLoading(false);
    if (m_mediaListModel)
        m_mediaListModel->setMedia(media);
}

void MediaViewModel::onError(const QString &message)
{
    setLoading(false);
    emit mediaError(message);
}
