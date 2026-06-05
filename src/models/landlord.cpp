#include "landlord.h"

Landlord::Landlord() {}

QString Landlord::getId() const
{
    return id;
}

void Landlord::setId(const QString &newId)
{
    id = newId;
}

QString Landlord::getName() const
{
    return name;
}

void Landlord::setName(const QString &newName)
{
    name = newName;
}

QString Landlord::getPhone() const
{
    return phone;
}

void Landlord::setPhone(const QString &newPhone)
{
    phone = newPhone;
}

QString Landlord::getPaymentDetails() const
{
    return paymentDetails;
}

void Landlord::setPaymentDetails(const QString &newPaymentDetails)
{
    paymentDetails = newPaymentDetails;
}
