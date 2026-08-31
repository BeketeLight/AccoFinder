#ifndef CACHEDIMAGEPROVIDER_H
#define CACHEDIMAGEPROVIDER_H

#include <QQuickAsyncImageProvider>
#include <QHash>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QQuickImageResponse>
#include <QImage>
#include <QMutex>
#include <QSet>
#include <QMap>
#include <QList>

class CachedImageResponse;

// Async image provider that downloads remote images once, decodes them,
// and keeps the decoded QImage in memory so every Image element that uses
// the same URL (thumbnail + lightbox, etc.) reuses the same pixels with
// zero re-fetch and zero re-decode.
//
// Usage in QML:  source: "image://cached/" + <percent-encoded url>
//
// Thread safety: QQuickAsyncImageProvider::requestImageResponse() is invoked
// on the QML reader thread. All network + cache mutations therefore happen on
// the main (GUI) thread via queued invocations, and the decoded-image cache is
// guarded by a mutex so reads from the reader thread are safe. finished() is
// re-emitted back onto the reader thread, matching the async provider contract.
class CachedImageProvider : public QQuickAsyncImageProvider
{
    Q_OBJECT

public:
    explicit CachedImageProvider(QObject *parent = nullptr);
    ~CachedImageProvider() override;

    QQuickImageResponse *requestImageResponse(const QString &id,
                                              const QSize &requestedSize) override;

    // Forget a specific remote URL: drops it from the in-memory decoded cache,
    // the disk cache, and (if still downloading) cancels the in-flight request
    // and fails any waiting responses. Safe to call from any thread. Used after
    // a property/media is deleted server-side so a removed image is not served
    // from a stale cached copy.
    Q_INVOKABLE void invalidateUrl(const QString &url);

    // Clear every cached image (memory + disk).
    Q_INVOKABLE void clearCache();

private:
    struct CachedImage
    {
        QImage image;
        qint64 lastUsed = 0;
    };

    QNetworkAccessManager *m_networkManager;

    // Decoded-image cache (guarded by m_mutex; mutated on main thread).
    mutable QMutex m_mutex;
    QHash<QString, CachedImage> m_images;
    qint64 m_clock = 0;

    // URLs for which a download is already in flight (main-thread only).
    QSet<QString> m_inflight;

    // The live reply for each in-flight download, so invalidateUrl can abort it.
    QHash<QString, QNetworkReply *> m_inflightReply;

    // Responses waiting on an in-flight download, keyed by URL (main-thread).
    QMap<QString, QList<CachedImageResponse *>> m_waiters;
};

#endif
