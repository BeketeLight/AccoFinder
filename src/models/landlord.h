#ifndef LANDLORD_H
#define LANDLORD_H

#include <QString>
#include "models/user.h"

class Landlord : public User
{
    Q_OBJECT
public:
    Landlord(QString& newId,QString& newName, QString& newPhone,QString& newPaymentDetails);
    QString getId() const;
    void setId(const QString &newId);
    QString getName() const;
    void setName(const QString &newName);
    QString getPhone() const;
    void setPhone(const QString &newPhone);
    QString getPaymentDetails() const;
    void setPaymentDetails(const QString &newPaymentDetails);

private:
    QString id;
    QString name;
    QString phone;
    QString paymentDetails;
signals:
    void landlordProfileCreated();
    void landlordPaymentDetailsChanged();
};

#endif // LANDLORD_H
