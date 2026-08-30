#ifndef MEDIAVIEWMODEL_H
#define MEDIAVIEWMODEL_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include "presentation/models/medialistmodel.h"
#include "application/controllers/mediacontroller.h"

class MediaViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MediaListModel* mediaListModel READ mediaListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit MediaViewModel(QObject* parent = nullptr);

    MediaListModel* mediaListModel() const { return m_mediaListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void createMedia(const QString& propertyId,
                                 const QString& url,
                                 const QString& type,
                                 bool isPrimary,
                                 const QString& roomId);
    Q_INVOKABLE void getMediaByProperty(const QString& propertyId);
    Q_INVOKABLE void deleteMedia(const QString& mediaId);
    Q_INVOKABLE void updateMediaPrimary(const QString& mediaId, bool isPrimary);

    // Media belonging to the given property id, shaped for QML display as
    // {mediaId, path, url, isPrimary, roomId, mediaType} maps.
    Q_INVOKABLE QVariantList mediaForProperty(const QString& propertyId) const;

private:
    bool m_isLoading = false;
    MediaListModel* m_mediaListModel = nullptr;
    MediaController* m_mediaController = nullptr;

    void setLoading(bool loading);

private slots:
    void onMediaCreated(const QSharedPointer<Media>& media);
    void onMediaLoaded(const QList<QSharedPointer<Media>>& media);
    void onMediaDeleted(const QString& mediaId);
    void onMediaUpdated(const QSharedPointer<Media>& media);
    void onError(const QString& message);

signals:
    void isLoadingChanged(bool isLoading);
    void mediaError(const QString& error);
    void mediaCreatedSignal(const QString& mediaId);
    void mediaDeletedSignal(const QString& mediaId);
    void mediaUpdatedSignal(const QString& mediaId);
};

#endif // MEDIAVIEWMODEL_H
