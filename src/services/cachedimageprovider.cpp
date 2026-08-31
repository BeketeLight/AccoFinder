#include "cachedimageprovider.h"

#include <QQuickTextureFactory>
#include <QSize>
#include <QImageReader>
#include <QStandardPaths>
#include <QNetworkDiskCache>
#include <QNetworkRequest>
#include <QUrl>
#include <QDebug>
#include <QTimer>
#include <limits>

// ---- Response object; finished() fires on the thread that owns it ---------
class CachedImageResponse : public QQuickImageResponse
{
public:
    explicit CachedImageResponse(const QImage &image, const QString &error = QString())
        : m_image(image), m_error(error)
    {
    }

    void setImage(const QImage &image) { m_image = image; }

    QQuickTextureFactory *textureFactory() const override
    {
        return QQuickTextureFactory::textureFactoryForImage(m_image);
    }

    QString errorString() const override { return m_error; }

private:
    QImage m_image;
    QString m_error;
};

// ---- Provider ------------------------------------------------------------

CachedImageProvider::CachedImageProvider(QObject *parent)
    : QQuickAsyncImageProvider()
    , m_networkManager(new QNetworkAccessManager(this))
{
    QString cachePath = QStandardPaths::writableLocation(
        QStandardPaths::GenericCacheLocation);
    if (cachePath.isEmpty())
        cachePath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    cachePath += "/accofinder/images";

    QNetworkDiskCache *diskCache = new QNetworkDiskCache(this);
    diskCache->setCacheDirectory(cachePath);
    diskCache->setMaximumCacheSize(100 * 1024 * 1024); // 100 MB
    m_networkManager->setCache(diskCache);
}

CachedImageProvider::~CachedImageProvider() = default;

static QImage scaledTo(const QImage &image, const QSize &requestedSize)
{
    if (requestedSize.isValid() && !requestedSize.isEmpty()
        && (image.width() > requestedSize.width() || image.height() > requestedSize.height())) {
        return image.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }
    return image;
}

QQuickImageResponse *CachedImageProvider::requestImageResponse(
    const QString &id, const QSize &requestedSize)
{
    const QString url = QUrl::fromPercentEncoding(id.toUtf8());

    // Serve directly from the in-memory decoded cache when available.
    m_mutex.lock();
    auto it = m_images.find(url);
    if (it != m_images.end()) {
        it->lastUsed = ++m_clock;
        QImage img = it->image;
        m_mutex.unlock();

        auto *resp = new CachedImageResponse(scaledTo(img, requestedSize));
        QMetaObject::invokeMethod(resp, "finished", Qt::QueuedConnection);
        return resp;
    }
    m_mutex.unlock();

    // Cache miss. The network manager (and the waiter/in-flight bookkeeping)
    // may only be touched on the main thread, so queue it there. finished() is
    // re-delivered on the reader thread that owns each response.
    auto *resp = new CachedImageResponse(QImage());

    QMetaObject::invokeMethod(this, [this, resp, url]() {
        m_waiters[url].append(resp);
        if (m_inflight.contains(url)) {
            // A download for this URL is already running; it will deliver to
            // all waiters when it completes.
            return;
        }
        m_inflight.insert(url);

        QNetworkRequest request{QUrl(url)};
        request.setAttribute(QNetworkRequest::CacheLoadControlAttribute,
                             QNetworkRequest::PreferCache);
        request.setTransferTimeout(30000);

        QNetworkReply *reply = m_networkManager->get(request);
        m_inflightReply.insert(url, reply);
        connect(reply, &QNetworkReply::finished, this, [this, url, reply]() {
            reply->deleteLater();
            m_inflight.remove(url);
            m_inflightReply.remove(url);

            QString error;
            QImage image;
            if (reply->error() == QNetworkReply::NoError) {
                image = QImageReader(reply).read();
                if (image.isNull())
                    error = tr("Could not decode image");
            } else {
                error = reply->errorString();
            }

            if (!image.isNull()) {
                m_mutex.lock();
                if (m_images.size() >= 96) {
                    QString oldestKey;
                    qint64 oldest = std::numeric_limits<qint64>::max();
                    for (auto it = m_images.constBegin(); it != m_images.constEnd(); ++it) {
                        if (it->lastUsed < oldest) {
                            oldest = it->lastUsed;
                            oldestKey = it.key();
                        }
                    }
                    if (!oldestKey.isEmpty())
                        m_images.remove(oldestKey);
                }
                CachedImage entry;
                entry.image = image;
                entry.lastUsed = ++m_clock;
                m_images.insert(url, entry);
                m_mutex.unlock();
            }

            // Deliver to every response that requested this URL.
            const auto waiters = m_waiters.take(url);
            for (CachedImageResponse *w : waiters) {
                w->setImage(error.isEmpty() ? image : QImage());
                QMetaObject::invokeMethod(w, "finished", Qt::QueuedConnection);
            }
        });
    }, Qt::QueuedConnection);

    return resp;
}

void CachedImageProvider::invalidateUrl(const QString &url)
{
    if (url.isEmpty())
        return;

    // All network/disk-cache access and in-flight bookkeeping must happen on
    // the main thread (see requestImageResponse). The in-memory decoded cache
    // is additionally mutex-guarded for reader-thread reads.
    QMetaObject::invokeMethod(this, [this, url]() {
        m_mutex.lock();
        m_images.remove(url);
        m_mutex.unlock();

        if (m_networkManager && m_networkManager->cache())
            m_networkManager->cache()->remove(QUrl(url));

        // Abort any in-flight download so we never fall back to a stale copy,
        // and fail the responses that were waiting on it.
        auto it = m_inflightReply.find(url);
        if (it != m_inflightReply.end()) {
            it.value()->abort();
            m_inflightReply.erase(it);
        }
        m_inflight.remove(url);

        const auto waiters = m_waiters.take(url);
        for (CachedImageResponse *w : waiters) {
            w->setImage(QImage());
            QMetaObject::invokeMethod(w, "finished", Qt::QueuedConnection);
        }
    }, Qt::QueuedConnection);
}

void CachedImageProvider::clearCache()
{
    // Entirely main-thread bound: clear the decoded cache and the disk cache.
    QMetaObject::invokeMethod(this, [this]() {
        m_mutex.lock();
        m_images.clear();
        m_mutex.unlock();

        if (m_networkManager && m_networkManager->cache())
            m_networkManager->cache()->clear();
    }, Qt::QueuedConnection);
}
