#ifndef IMEDIAREPOSITORY_H
#define IMEDIAREPOSITORY_H

#include <QString>
#include <QStringList>

class IMediaRepository
{
public:
    IMediaRepository() {}

    virtual void createMedia(const QString& propertyId,
                             const QString& url,
                             const QString& type,
                             bool isPrimary,
                             const QString& roomId) = 0;
    virtual void getMediaByProperty(const QString& propertyId) = 0;

    virtual ~IMediaRepository() {}
};

#endif // IMEDIAREPOSITORY_H
