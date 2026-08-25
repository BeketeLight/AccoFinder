#ifndef PROPERTYVIEWMODEL_H
#define PROPERTYVIEWMODEL_H

#include <QObject>
#include "application/controllers/propertycontroller.h"
#include "presentation/models/propertylistmodel.h"

class PropertyViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PropertyListModel* propertyListModel READ propertyListModel CONSTANT)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
public:
    explicit PropertyViewModel(QObject *parent = nullptr);

    PropertyListModel* propertyListModel() const { return m_propertyListModel; }
    bool isLoading() const { return m_isLoading; }

    Q_INVOKABLE void getProperties();
    Q_INVOKABLE void getPropertyById(const QString& houseId);
    Q_INVOKABLE void updateProperty(int index,
                                    const QString& houseId,
                                    const QString& title,
                                    const QString& description,
                                    double price,
                                    const QString& costCategory);
    Q_INVOKABLE void createProperty(const QString& title,
                                    const QString& description,
                                    double price,
                                    const QString& costCategory);
    Q_INVOKABLE void deleteProperty(const QString& houseId);

private:
    int m_index = -1;
    bool m_isLoading = false;
    PropertyListModel* m_propertyListModel = nullptr;
    PropertyController* m_propertyController = nullptr;

    void setLoading(bool loading);

private slots:
    void onPropertiesLoaded(QList<Property*>& properties);
    void onGetPropertyById(Property* property);
    void onUpdateProperty(Property* property);
    void onPropertyError(const QString& error);

signals:
    void isLoadingChanged(bool isLoading);
    void propertyError(const QString& error);
};

#endif // PROPERTYVIEWMODEL_H
