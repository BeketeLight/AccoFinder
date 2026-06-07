#ifndef REVIEW_H
#define REVIEW_H

#include <QObject>
#include <QDateTime>

class Review : public QObject
{
    Q_OBJECT
public:
    explicit Review(const QString& id,
                    int rating,
                    const QString& comment,
                    const QDateTime& createdAt = QDateTime(),
                    QObject* parent = nullptr);
    QString getId() const;
    int getRating() const;
    QString getComment() const;
    QDateTime getCreatedAt() const;


private:
    QString m_id;
    int m_rating;
    QString m_comment;
    QDateTime m_createdAt;
signals:
    void reviewSubmitted();

};

#endif // REVIEW_H
