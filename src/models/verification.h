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
    explicit Verification(QObject *parent  = nullptr);
    QString getId() const;
    void setId(const QString &newId);

    QString getPropertyId() const;
    void setPropertyId(const QString &newPropertyId);

    VerificationStatus getStatus() const;
    void setStatus(VerificationStatus newStatus);

private:
    QString id;
    QString propertyId;
    VerificationStatus status;

signals:
    void verificationCompleted();
};

#endif // VERIFICATION_H
