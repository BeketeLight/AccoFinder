#ifndef MEDIALISTMODEL_H
#define MEDIALISTMODEL_H

#include <QAbstractListModel>
#include <QByteArray>
#include <QSharedPointer>
#include <QHash>
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

    void setMedia(const QList<QSharedPointer<Media>>& newMedia);
    void appendMedia(const QSharedPointer<Media>& media);
    void clearMedia();

private:
    QVector<QSharedPointer<Media>> m_media;
};

#endif // MEDIALISTMODEL_H
