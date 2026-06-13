#ifndef DISPUTE_H
#define DISPUTE_H

#include <QObject>
#include <QString>
#include "core/utils/EDisputeStatus.h"
class Dispute : public QObject
{
    Q_OBJECT
public:
    Dispute();
    explicit Dispute(const QString &id,
                     const QString &bookingId,
                     const QString &issue,
                     const DisputeStatus& status,
                     QObject *parent = nullptr);
    QString getId() const;
    void setId(const QString &id);

    QString getBookingId() const;
    void setBookingId(const QString &bookingId);

    QString getIssue() const;
    void setIssue(const QString &issue);

    DisputeStatus getStatus() const;
    void setStatus(DisputeStatus status);

private:
    QString m_id;
    QString m_bookingId;
    QString m_issue;
    DisputeStatus m_status;
signals:
    void disputeRaised();
    void disputeResolved();
};

#endif // DISPUTE_H
