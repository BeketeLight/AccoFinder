#include "landlord.h"

Landlord::Landlord(const QString &id,
                   const QString &name,
                   const QString &email,
                   const QString &phone,
                   const QDateTime &createdAt,
                   const QString &paymentDetails,
                   QObject *parent)
    :User(id,name,email,phone,createdAt,parent)
    ,m_id(id)
    ,m_name(name)
    ,m_phone(phone)
    ,m_paymentDetails(paymentDetails)
{
    emit landlordProfileCreated();

}

QString Landlord::getId() const
{
    return m_id;
}



QString Landlord::getName() const
{
    return m_name;
}

void Landlord::setName(const QString &name)
{
    m_name = name;
}

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
