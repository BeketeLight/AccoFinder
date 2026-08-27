#include "medialistmodel.h"

MediaListModel::MediaListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int MediaListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_media.size();
}

QVariant MediaListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_media.size())
        return QVariant();

    const QSharedPointer<Media>& media = m_media.at(index.row());

    switch (role) {
    case IdRole:
        return media->getId();
    case PropertyIdRole:
        return media->getPropertyId();
    case UrlRole:
        return media->getUrl();
    case TypeRole:
        return media->getType();
    case IsPrimaryRole:
        return media->getIsPrimary();
    case RoomIdRole:
        return media->getRoomId();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> MediaListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "mediaId";
    roles[PropertyIdRole] = "propertyId";
    roles[UrlRole] = "url";
    roles[TypeRole] = "mediaType";
    roles[IsPrimaryRole] = "isPrimary";
    roles[RoomIdRole] = "roomId";
    return roles;
}

void MediaListModel::setMedia(const QList<QSharedPointer<Media>>& newMedia)
{
    beginResetModel();
    m_media.clear();
    m_media.reserve(newMedia.size());
    for (const QSharedPointer<Media>& media : newMedia)
        m_media.append(media);
    endResetModel();
}

void MediaListModel::appendMedia(const QSharedPointer<Media>& media)
{
    beginInsertRows(QModelIndex(), m_media.size(), m_media.size());
    m_media.append(media);
    endInsertRows();
}

void MediaListModel::clearMedia()
{
    beginResetModel();
    m_media.clear();
    endResetModel();
}
