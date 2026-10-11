#ifndef REVIEW_H
#define REVIEW_H

#include <QObject>
#include <QDateTime>

class Review : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ getId CONSTANT)
    Q_PROPERTY(QString clientId READ getClientId CONSTANT)
    Q_PROPERTY(QString propertyId READ getPropertyId CONSTANT)
    Q_PROPERTY(QString agentId READ getAgentId CONSTANT)
    Q_PROPERTY(int rating READ getRating CONSTANT)
    Q_PROPERTY(QString comment READ getComment CONSTANT)
    Q_PROPERTY(QDateTime createdAt READ getCreatedAt CONSTANT)

public:
    explicit Review(const QString& id,
                    const QString& clientId,
                    const QString& propertyId,
                    const QString& agentId,
                    int rating,
                    const QString& comment,
                    const QDateTime& createdAt = QDateTime(),
                    QObject* parent = nullptr);

    QString getId() const;
    QString getClientId() const;
    QString getPropertyId() const;
    QString getAgentId() const;
    int getRating() const;
    QString getComment() const;
    QDateTime getCreatedAt() const;
    void setRating(int r);
    void setComment(const QString& c);

private:
    QString m_id;
    QString m_clientId;
    QString m_propertyId;
    QString m_agentId;
    int m_rating;
    QString m_comment;
    QDateTime m_createdAt;
};

#endif // REVIEW_H