#include "landlord.h"

Landlord::Landlord(const QString &id,
                   const QString& firstName,
                   const QString& lastName,
                   const QString &email,
                   const QString &phone,
                   const QDateTime &createdAt,
                   const QString &paymentDetails,
                   QObject *parent)
    :User(id,firstName,lastName,email,phone,createdAt,parent)
    ,m_id(id)
    ,m_firstName(firstName)
    ,m_lastName(lastName)
    ,m_phone(phone)
    ,m_paymentDetails(paymentDetails)
{
    emit landlordProfileCreated();

}

QString Landlord::getId() const
{
    return m_id;
}



// QString Landlord::getName() const
// {
//     return m_name;
// }

// void Landlord::setName(const QString &name)
// {
//     m_name = name;
// }

QString Landlord::getPhone() const
{
    return m_phone;
}

void Landlord::setPhone(const QString &phone)
{
    m_phone = phone;
}

QString Landlord::getPaymentDetails() const
{
    return m_paymentDetails;
}

void Landlord::setPaymentDetails(const QString &paymentDetails)
{
    m_paymentDetails = paymentDetails;
    emit landlordPaymentDetailsChanged();
}

QString Landlord::lastName() const
{
    return m_lastName;
}

void Landlord::setLastName(const QString &newLastName)
{
    m_lastName = newLastName;
}

QString Landlord::firstName() const
{
    return m_firstName;
}

void Landlord::setFirstName(const QString &newFirstName)
{
    m_firstName = newFirstName;
}
