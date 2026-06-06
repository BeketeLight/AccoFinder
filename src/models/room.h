#ifndef ROOM_H
#define ROOM_H

#include <QObject>
#include <QString>

class Room : public QObject
{
    Q_OBJECT
public:
    explicit Room(QObject *parent = nullptr);
    Room(const QString& newId,
         const QString& newPropertyId,
         const QString& newType,
         bool newAvailable = true,
         QObject* parent = nullptr);
    QString getId() const;
    void setId(const QString &newId);
    QString getPropertyId() const;
    void setPropertyId(const QString &newPropertyId);
    QString getType() const;
    void setType(const QString &newType);
    bool getAvailable() const;
    void setAvailable(bool newAvailable);

private:
    QString id;
    QString propertyId;
    QString type;
    bool available;
signals:
    void availabilityChanged();
    void newRoomCreated();
};

#endif // ROOM_H
