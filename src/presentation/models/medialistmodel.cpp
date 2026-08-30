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

void MediaListModel::removeMedia(const QString &mediaId)
{
    for (int i = 0; i < m_media.size(); ++i) {
        if (m_media.at(i)->getId() != mediaId)
            continue;
        beginRemoveRows(QModelIndex(), i, i);
        m_media.removeAt(i);
        endRemoveRows();
        return;
    }
}

void MediaListModel::setMediaPrimary(const QString &mediaId, bool isPrimary)
{
    // A property owns at most one cover photo: demote every media belonging to
    // the same property before promoting the requested one.
    QString propertyId;
    int targetIndex = -1;
    for (int i = 0; i < m_media.size(); ++i) {
        const QSharedPointer<Media>& media = m_media.at(i);
        if (media->getId() == mediaId) {
            targetIndex = i;
            propertyId = media->getPropertyId();
        }
    }
    if (targetIndex >= 0 && !propertyId.isEmpty() && isPrimary) {
        for (int i = 0; i < m_media.size(); ++i) {
            if (i == targetIndex)
                continue;
            const QSharedPointer<Media>& media = m_media.at(i);
            if (media->getPropertyId() != propertyId || !media->getIsPrimary())
                continue;
            media->setIsPrimary(false);
            const QModelIndex idx = index(i, 0);
            emit dataChanged(idx, idx, {IsPrimaryRole});
        }
    }
    if (targetIndex >= 0) {
        const QSharedPointer<Media>& target = m_media.at(targetIndex);
        if (target->getIsPrimary() != isPrimary) {
            target->setIsPrimary(isPrimary);
            const QModelIndex idx = index(targetIndex, 0);
            emit dataChanged(idx, idx, {IsPrimaryRole});
        }
    }
}

void MediaListModel::clearMedia()
{
    beginResetModel();
    m_media.clear();
    endResetModel();
}

QVariantList MediaListModel::mediaForProperty(const QString &propertyId) const
{
    QVariantList result;
    for (const auto& media : std::as_const(m_media)) {
        if (!media)
            continue;
        if (media->getPropertyId() != propertyId)
            continue;
        QVariantMap m;
        m["mediaId"] = media->getId();
        m["path"] = media->getUrl();
        m["url"] = media->getUrl();
        m["isPrimary"] = media->getIsPrimary();
        m["roomId"] = media->getRoomId();
        m["mediaType"] = media->getType();
        result.append(m);
    }
    return result;
}
