#include "draftviewmodel.h"

#include <QSettings>
#include <QJsonDocument>
#include <QDateTime>
#include <QDebug>

#include "presentation/viewmodels/propertyviewmodel.h"

namespace {
const QString kDraftSettingsKey = QStringLiteral("propertyDrafts");
}

DraftViewModel::DraftViewModel(PropertyViewModel *propertyViewModel, QObject *parent)
    : QObject{parent},
      m_propertyViewModel(propertyViewModel)
{
    m_cache = loadCache();

    if (m_propertyViewModel) {
        connect(m_propertyViewModel, &PropertyViewModel::propertyCreatedSignal,
                this, &DraftViewModel::onPropertyCreated);
        connect(m_propertyViewModel, &PropertyViewModel::propertyError,
                this, &DraftViewModel::onPropertyFailed);
    }
}

int DraftViewModel::count() const
{
    return m_cache.size();
}

QJsonObject DraftViewModel::loadCache() const
{
    QSettings settings;
    return QJsonDocument::fromJson(
                settings.value(kDraftSettingsKey).toByteArray()
    ).object();
}

void DraftViewModel::persist()
{
    QSettings settings;
    settings.setValue(kDraftSettingsKey,
                      QJsonDocument(m_cache).toJson(QJsonDocument::Compact));
    emit draftsChanged();
}

QString DraftViewModel::saveDraft(const QJsonObject &payload)
{
    if (payload.isEmpty())
        return QString();

    QString key = QStringLiteral("draft_%1")
                      .arg(QDateTime::currentMSecsSinceEpoch());

    // Keep the title so the Drafts list is human-readable.
    QSettings settings;

    QJsonObject stored = payload;
    if (!stored.contains("title"))
        stored["title"] = QStringLiteral("Untitled property");
    if (!stored.contains("savedAt"))
        stored["savedAt"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    m_cache[key] = stored;
    persist();
    qDebug() << "Draft saved:" << key << "total drafts:" << m_cache.size();
    return key;
}

void DraftViewModel::removeDraft(const QString &key)
{
    if (!m_cache.contains(key))
        return;
    m_cache.remove(key);
    persist();
}

void DraftViewModel::clearAll()
{
    if (m_cache.isEmpty())
        return;
    m_cache = QJsonObject();
    persist();
}

QJsonObject DraftViewModel::getDraft(const QString &key) const
{
    return m_cache.value(key).toObject();
}

QStringList DraftViewModel::keys() const
{
    return m_cache.keys();
}

QJsonObject DraftViewModel::allDrafts() const
{
    return m_cache;
}

bool DraftViewModel::updateDraft(const QString &key, const QJsonObject &payload)
{
    if (!m_cache.contains(key) || payload.isEmpty())
        return false;

    QJsonObject stored = payload;
    // Preserve the original savedAt so the Drafts list ordering is stable.
    if (!stored.contains("savedAt"))
        stored["savedAt"] = m_cache.value(key).toObject().value("savedAt").toString(
                                QDateTime::currentDateTime().toString(Qt::ISODate));
    if (!stored.contains("title"))
        stored["title"] = QStringLiteral("Untitled property");

    m_cache[key] = stored;
    persist();
    qDebug() << "Draft updated:" << key;
    return true;
}

bool DraftViewModel::resendDraft(const QString &key)
{
    if (!m_propertyViewModel)
        return false;

    const QJsonObject draft = getDraft(key);
    if (draft.isEmpty())
        return false;

    const QJsonObject addr = draft.value("physicalAddress").toObject();
    const QJsonArray amenities = draft.value("amenities").toArray();
    const QJsonArray rawRooms = draft.value("rooms").toArray();

    QStringList amens;
    for (const QJsonValue &v : amenities)
        amens.append(v.toString());

    // Normalize stored room objects ({ roomId, roomType, price, available })
    // into the backend shape used at creation ({ type, price, available }).
    QJsonArray rooms;
    for (const QJsonValue &v : rawRooms) {
        const QJsonObject r = v.toObject();
        QJsonObject room;
        room["type"] = r.value(QLatin1String("roomType")).toString(
                           r.value(QLatin1String("type")).toString(
                               QStringLiteral("Room")));
        room["price"] = r.value("price").toDouble();
        room["available"] = r.value("available").toBool(true);
        rooms.append(room);
    }

    // Remember which draft is being resent so it can be removed ONLY when the
    // upload succeeds. On failure it stays in storage for a later retry.
    m_resendingKey = key;

    // Drafts are local, un-submitted listings and therefore carry no
    // verificationStatus. The backend only accepts PENDING/VERIFIED/REJECTED/
    // DRAFT and rejects an empty string, so default unsent drafts to PENDING.
    QString verificationStatus = draft.value("verificationStatus").toString();
    if (verificationStatus.isEmpty())
        verificationStatus = QStringLiteral("PENDING");

    m_propertyViewModel->createProperty(
        draft.value("title").toString(),
        draft.value("description").toString(),
        draft.value("price").toDouble(),
        draft.value("propertyType").toString(),
        addr.value("district").toString(),
        addr.value("village").toString(),
        amens,
        draft.value("landlord").toString(),
        draft.value("landlordPhone").toString(),
        verificationStatus,
        draft.value("isActive").toBool(true),
        rooms);

    return true;
}

void DraftViewModel::onPropertyCreated(const QString &id, const QString &title)
{
    Q_UNUSED(id)
    Q_UNUSED(title)
    if (m_resendingKey.isEmpty())
        return;
    // Upload succeeded: the draft can be removed.
    const QString resendingKey = m_resendingKey;
    m_resendingKey.clear();
    removeDraft(resendingKey);
    qDebug() << "Draft resent successfully, removed:" << resendingKey;
}

void DraftViewModel::onPropertyFailed(const QString &error)
{
    // A resend that fails must keep its draft so the user can retry later.
    if (!m_resendingKey.isEmpty()) {
        qDebug() << "Draft resend failed (" << error << ") — keeping draft:" << m_resendingKey;
        m_resendingKey.clear();
    }
}
