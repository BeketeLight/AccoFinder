#ifndef LANDLORD_H
#define LANDLORD_H

#include <QString>
#include "models/user.h"

class Landlord : public User
{
    Q_OBJECT
public:
    explicit Landlord(const QString& id,
             const QString& firstName,
             const QString& lastName,
             const QString& email,
             const QString& phone,
             const QDateTime& createdAt,
             const QString& paymentDetails,
             QObject* parent= nullptr);
    QString getId() const;
    // QString getName() const;
    // void setName(const QString &name);
    QString getPhone() const;
    void setPhone(const QString &phone);
    QString getPaymentDetails() const;
    void setPaymentDetails(const QString &paymentDetails);

    QString lastName() const;
    void setLastName(const QString &newLastName);

    QString firstName() const;
    void setFirstName(const QString &newFirstName);

private:
    QString m_id;
    QString m_firstName;
    QString m_lastName;
    QString m_phone;
    QString m_paymentDetails;
signals:
    void landlordProfileCreated();
    void landlordPaymentDetailsChanged();
};

#endif // LANDLORD_H
