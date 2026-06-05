#ifndef PROPERTYVIEWMODEL_H
#define PROPERTYVIEWMODEL_H

#include <QObject>

class PropertyViewModel : public QObject
{
    Q_OBJECT
public:
    explicit PropertyViewModel(QObject *parent = nullptr);

signals:
};

#endif // PROPERTYVIEWMODEL_H
