#include "client.h"

Client::Client() {}

bool Client::getIsStudent() const
{
    return isStudent;
}

void Client::setIsStudent(bool newIsStudent)
{
    isStudent = newIsStudent;
}

QString Client::getPrefferedLOcation() const
{
    return prefferedLOcation;
}

void Client::setPrefferedLOcation(const QString &newPrefferedLOcation)
{
    prefferedLOcation = newPrefferedLOcation;
}

double Client::getBudgetMin() const
{
    return budgetMin;
}

void Client::setBudgetMin(double newBudgetMin)
{
    budgetMin = newBudgetMin;
}

double Client::getBudgetMax() const
{
    return budgetMax;
}

void Client::setBudgetMax(double newBudgetMax)
{
    budgetMax = newBudgetMax;
}
