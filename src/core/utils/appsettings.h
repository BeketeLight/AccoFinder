#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#if defined(Q_OS_ANDROID)
#include <QJniObject>
#include <QJniEnvironment>
#include <QPermission>
#include <QImage>
#endif
#include <QCoreApplication>
class AppSettings : public QObject
{
    Q_OBJECT
public:
    explicit AppSettings(QObject *parent = nullptr);
    static AppSettings& instance();
    Q_INVOKABLE void setStatusBarAppearance(const QColor &backgroundColor, bool darkIcons);
signals:
};

#endif // APPSETTINGS_H
