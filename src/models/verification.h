#ifndef VERIFICATION_H
#define VERIFICATION_H

#include <QObject>
#include <QDateTime>
#include <QString>
#include "core/utils/EVerificationStatus.h"

class Verification : public QObject
{
    Q_OBJECT
public:
    explicit Verification(const QString& id,
                          const QString agentId,
                          const QString propertyId,
                          const QString notes,
                          const QDateTime verifiedAt,
                          const VerificationStatus& status,
                          QObject *parent  = nullptr);
    QString getId() const;

    QString getPropertyId() const;

    VerificationStatus getStatus() const;
    void setStatus(VerificationStatus& status);

    QString agentId() const;
    QString notes() const;
    void setNotes(const QString &newNotes);
    QDateTime verifiedAt() const;

private:
    QString m_id;
    QString m_agentId;
    QString m_propertyId;
    QString m_notes;
    VerificationStatus m_status;
    QDateTime m_verifiedAt;

signals:
    void verificationApproved();
    void verificationRejected();
    void verificationNotesChanged();
};

#endif // VERIFICATION_H
