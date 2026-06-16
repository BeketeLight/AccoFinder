#ifndef ROOM_H
#define ROOM_H

#include <QObject>
#include <QString>
#include "models/property.h"

class Room : public QObject
{
    Q_OBJECT
public:
    Room();
    explicit Room(const QString& id,
         const QString& propertyId,
         const QString& type,
         bool available ,
         QObject* parent = nullptr);

    QString getId() const;
    QString getPropertyId() const;
    QString getType() const;
    void setType(const QString &type);
    bool getAvailable() const;
    void setAvailable(bool available);

private:
    QString m_id;
    QString m_propertyId;
    QString m_type;
    bool m_available;
signals:
    void availabilityChanged();
    void newRoomCreated();
};

#endif // ROOM_H
