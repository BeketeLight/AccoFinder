#ifndef APICLIENT_H
#define APICLIENT_H

#include <QObject>


class ApiClient : public QObject
{
    Q_OBJECT
public:
   explicit ApiClient(QObject *parent = nullptr);
    void getRequest();
    void postRequest();
    void deleteRequest();
    void putRequest();
private:
signals:
    void requestSuccess();
    void requestFailed();
};

#endif // APICLIENT_H
