#ifndef CLIENT_H
#define CLIENT_H

#include "user.h"

class Client : public User
{
public:
    Client();
    bool getIsStudent() const;
    void setIsStudent(bool newIsStudent);

    QString getPrefferedLOcation() const;
    void setPrefferedLOcation(const QString &newPrefferedLOcation);

    double getBudgetMin() const;
    void setBudgetMin(double newBudgetMin);

    double getBudgetMax() const;
    void setBudgetMax(double newBudgetMax);

private:
    bool isStudent;
    QString prefferedLOcation;
    double budgetMin;
    double budgetMax;

signals:
    void bookingRequested(QString roomId);
};

#endif // CLIENT_H
