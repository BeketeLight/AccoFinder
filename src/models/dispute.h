#ifndef DISPUTE_H
#define DISPUTE_H

#include <QObject>
#include <QString>
#include "core/utils/EDisputeStatus.h"
class Dispute : public QObject
{
    Q_OBJECT
public:
    explicit Dispute(QObject *parent = nullptr);
    QString getId() const;
    void setId(const QString &newId);

    QString getBookingId() const;
    void setBookingId(const QString &newBookingId);

    QString getIssue() const;
    void setIssue(const QString &newIssue);

    DisputeStatus getStatus() const;
    void setStatus(DisputeStatus newStatus);

private:
    QString id;
    QString bookingId;
    QString issue;
    DisputeStatus status;
signals:
    void disputeRaised();
    void disputeResolved();
};

#endif // DISPUTE_H
