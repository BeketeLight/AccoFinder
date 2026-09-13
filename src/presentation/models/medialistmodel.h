#ifndef MEDIALISTMODEL_H
#define MEDIALISTMODEL_H

#include <QAbstractListModel>
#include <QByteArray>
#include <QSharedPointer>
#include <QHash>
#include <QVariantList>
#include <QVector>
#include "models/media.h"

class MediaListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum {
        IdRole = Qt::UserRole + 1,
        PropertyIdRole,
        UrlRole,
        TypeRole,
        IsPrimaryRole,
        RoomIdRole,
    };

    explicit MediaListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    // Replaces the whole media set (reset semantics). Screens that load a
    // single property's media and expect a fresh list use this.
    void setMedia(const QList<QSharedPointer<Media>>& newMedia);
    // Cache semantics: merge the incoming media into the existing vector by
    // mediaId. Rows whose id already exists are replaced in place; new ids are
    // appended. Used when several screens fetch different properties' media
    // into the same shared model (e.g. Home grids) — a reset would wipe
    // previously loaded properties.
    void upsertMedia(const QList<QSharedPointer<Media>>& newMedia);
    void appendMedia(const QSharedPointer<Media>& media);
    void removeMedia(const QString& mediaId);
    void setMediaPrimary(const QString& mediaId, bool isPrimary);
    void clearMedia();

    QVariantList mediaForProperty(const QString& propertyId) const;

signals:
    void countChanged(int newCount);

private:
    void emitCountIfChanged(int newCount);

    QVector<QSharedPointer<Media>> m_media;
    int m_lastEmittedCount = 0;
};

#endif // MEDIALISTMODEL_H
