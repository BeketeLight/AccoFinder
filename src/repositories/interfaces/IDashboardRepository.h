#ifndef IDASHBOARDREPOSITORY_H
#define IDASHBOARDREPOSITORY_H

#include <QObject>
#include <QJsonObject>

class IDashboardRepository : public QObject
{
    Q_OBJECT
public:
    explicit IDashboardRepository(QObject *parent = nullptr)
        : QObject(parent) {}

    virtual void fetchStats() = 0;

    virtual ~IDashboardRepository() {}
};

#endif // IDASHBOARDREPOSITORY_H