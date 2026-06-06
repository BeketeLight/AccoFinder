#ifndef CLIENT_H
#define CLIENT_H

#include "user.h"

class Client : public User
{
    Q_OBJECT
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
    void isStudentChanged();
    void preferredLocationChanged();
    void budgetMinChanged();
    void budgetMaxChanged();
    void bookingRequested(QString roomId);
};

#endif // CLIENT_H
