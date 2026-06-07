#include "client.h"


Client::Client(const QString &id,
               const QString &name,
               const QString &email,
               const QString &phone,
               const QDateTime &createdAt,
               QObject *parent)
    :User(id,name,email,phone,createdAt,parent)
{
    emit clientProfileCreated();

}

bool Client::getIsStudent() const
{
    return m_isStudent;
}

void Client::setIsStudent(bool isStudent)
{
    m_isStudent = isStudent;
    emit isStudentChanged();
}

QString Client::getPrefferedLOcation() const
{
    return m_prefferedLOcation;
}

void Client::setPrefferedLOcation(const QString &prefferedLOcation)
{
    m_prefferedLOcation = prefferedLOcation;
    emit preferredLocationChanged();
}

double Client::getBudgetMin() const
{
    return m_budgetMin;
}

void Client::setBudgetMin(double budgetMin)
{
    m_budgetMin = budgetMin;
    emit budgetMinChanged();
}

double Client::getBudgetMax() const
{
    return m_budgetMax;
}

void Client::setBudgetMax(double budgetMax)
{
    m_budgetMax = budgetMax;
    emit budgetMaxChanged();
}
