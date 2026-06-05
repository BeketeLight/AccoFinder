#ifndef LANDLORD_H
#define LANDLORD_H

#include <QString>

class Landlord
{
public:
    Landlord();
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
};

#endif // LANDLORD_H
