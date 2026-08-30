#include "mediarepositoryimpl.h"
#include <QList>

MediaRepositoryImpl::MediaRepositoryImpl(QObject *parent)
    : QObject(parent)
{
}

void MediaRepositoryImpl::createMedia(const QString &propertyId,
                                      const QString &url,
                                      const QString &type,
                                      bool isPrimary,
                                      const QString &roomId)
{
    // `url` is the local device file path of the selected photo.
    // S3 storage is handled at the API level; we send the raw file bytes
    // via multipart/form-data plus the metadata fields below.
    QJsonObject metadata;
    metadata["propertyId"] = propertyId;
    metadata["type"] = type;
    metadata["isPrimary"] = isPrimary;
    metadata["roomId"] = roomId;

    APIClient::instance().postMultipart(
        "https://accofinder-trsm.onrender.com/media/upload",
        url,
        "file",
        "image/jpeg",
        metadata,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                MediaDto mediaDto = MediaDto::fromJson(response["data"].toObject());
                QSharedPointer<Media> media = mediaDto.toDomainModel();
                emit mediaCreated(media);
            } else {
                emit error(response.value("message").toString());
            }
        }
    );
}

void MediaRepositoryImpl::getMediaByProperty(const QString &propertyId)
{
    APIClient::instance().get(
        "https://accofinder-trsm.onrender.com/media/property/" + propertyId,
        [this](bool success, const QJsonObject& response)
        {
            if (success && response.contains("data")) {
                QJsonArray mediaArray = response["data"].toArray();
                QList<QSharedPointer<Media>> mediaList;
                for (const QJsonValue& value : std::as_const(mediaArray)) {
                    mediaList.append(MediaDto::fromJson(value.toObject()).toDomainModel());
                }
                emit mediaLoaded(mediaList);
            }
        }, false
    );
}

void MediaRepositoryImpl::deleteMedia(const QString &mediaId)
{
    APIClient::instance().del(
        "https://accofinder-trsm.onrender.com/media/" + mediaId,
        [this, mediaId](bool success, const QJsonObject& response)
        {
            if (success)
                emit mediaDeleted(mediaId);
            else
                emit error(response.value("message").toString());
        }
    );
}

void MediaRepositoryImpl::updateMedia(const QString &mediaId, bool isPrimary)
{
    QJsonObject data;
    data["isPrimary"] = isPrimary;

    APIClient::instance().patch(
        "https://accofinder-trsm.onrender.com/media/" + mediaId,
        data,
        [this](bool success, const QJsonObject& response)
        {
            if (success) {
                const QJsonObject mediaObj = response["data"].toObject();
                if (!mediaObj.isEmpty()) {
                    MediaDto dto = MediaDto::fromJson(mediaObj);
                    emit mediaUpdated(dto.toDomainModel());
                    return;
                }
            }
            emit error(response.value("message").toString());
        }
    );
}
