#ifndef CLIENT_H
#define CLIENT_H

#include "user.h"

class Client : public User
{
    Q_OBJECT
public:
    explicit Client(const QString& id,
                    const QString& name,
                    const QString& phone,
                    const QString& email,
                    const QDateTime& createdAt,
                    QObject *parent = nullptr);
    bool getIsStudent() const;
    void setIsStudent(bool newIsStudent);

    QString getPrefferedLOcation() const;
    void setPrefferedLOcation(const QString &prefferedLOcation);

    double getBudgetMin() const;
    void setBudgetMin(double budgetMin);

    double getBudgetMax() const;
    void setBudgetMax(double budgetMax);

private:
    bool m_isStudent;
    QString m_prefferedLOcation;
    double m_budgetMin;
    double m_budgetMax;

signals:
    void clientProfileCreated();
    void isStudentChanged();
    void preferredLocationChanged();
    void budgetMinChanged();
    void budgetMaxChanged();
    void bookingRequested(QString roomId);
};

#endif // CLIENT_H
