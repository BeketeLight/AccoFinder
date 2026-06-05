#ifndef REVIEW_H
#define REVIEW_H

#include <QObject>
#include <QDateTime>

class Review : public QObject
{
    Q_OBJECT
public:
    explicit Review(QObject *parent = nullptr);
    QString getId() const;
    void setId(const QString &newId);

    int getRating() const;
    void setRating(int newRating);

    QString getComment() const;
    void setComment(const QString &newComment);

    QDateTime getCreatedAt() const;
    void setCreatedAt(const QDateTime &newCreatedAt);

private:
    QString id;
    int rating;
    QString comment;
    QDateTime createdAt;
signals:
    void reviewSubmitted();

};

#endif // REVIEW_H
