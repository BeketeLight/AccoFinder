#ifndef ROOM_H
#define ROOM_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include "models/property.h"

class Room : public QObject
{
    Q_OBJECT
public:
    Room();
    explicit Room(const QString& id,
         const QString& propertyId,
         const QString& type,
         double price,
         bool available,
         bool holdActive = false,
         const QDateTime& holdExpiresAt = QDateTime(),
         QObject* parent = nullptr);

    QString getId() const;
    QString getPropertyId() const;
    QString getType() const;
    void setType(const QString &type);
    double getPrice() const;
    void setPrice(double price);
    bool getAvailable() const;
    void setAvailable(bool available);

    // Provisional-hold state, decorated by the backend on every room payload.
    // `available == false` means permanently booked; `holdActive == true` means
    // a live hold, i.e. a client is mid-checkout. Both states must still be
    // shown in the property details list (labelled), never hidden.
    bool getHoldActive() const;
    void setHoldActive(bool holdActive);
    QDateTime getHoldExpiresAt() const;
    void setHoldExpiresAt(const QDateTime& holdExpiresAt);
    // Single display status derived from the two flags above.
    QString getStatusLabel() const;

private:
    QString m_id;
    QString m_propertyId;
    QString m_type;
    double m_price = 0;
    bool m_available;
    bool m_holdActive = false;
    QDateTime m_holdExpiresAt;
signals:
    void availabilityChanged();
    void newRoomCreated();
    void holdStateChanged();
};

#endif // ROOM_H
