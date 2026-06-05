#ifndef ROOM_H
#define ROOM_H

#include <QObject>
#include <QString>

class Room : public QObject
{
    Q_OBJECT
public:
    explicit Room(QObject *parent = nullptr);
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
};

#endif // ROOM_H
