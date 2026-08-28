#ifndef MEDIA_H
#define MEDIA_H

#include <QObject>
#include <QString>

class Media : public QObject
{
    Q_OBJECT
public:
    Media();
    explicit Media(const QString& id,
                   const QString& propertyId,
                   const QString& url,
                   const QString& type,
                   bool isPrimary,
                   const QString& roomId,
                   QObject* parent = nullptr);

    QString getId() const;
    void setId(const QString& id);

    QString getPropertyId() const;
    void setPropertyId(const QString& propertyId);

    // url mirrors the UI "path" of an uploaded photo
    QString getUrl() const;
    void setUrl(const QString& url);

    // type mirrors the UML Media.type (e.g. "image", "cover", "video")
    QString getType() const;
    void setType(const QString& type);

    // isPrimary mirrors the UI "isPrimary" cover flag
    bool getIsPrimary() const;
    void setIsPrimary(bool isPrimary);

    // roomId mirrors the UI "roomId" photo-to-room assignment (-1 = whole property)
    QString getRoomId() const;
    void setRoomId(const QString& roomId);

private:
    QString m_id;
    QString m_propertyId;
    QString m_url;
    QString m_type;
    bool m_isPrimary;
    QString m_roomId;
signals:
    void mediaAdded();
};

#endif // MEDIA_H
