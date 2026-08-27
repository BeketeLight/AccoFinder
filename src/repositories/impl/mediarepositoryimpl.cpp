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
        "/media/upload",
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
        "/media/property/" + propertyId,
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
