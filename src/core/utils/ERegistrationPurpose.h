#ifndef EREGISTRATIONPURPOSE_H
#define EREGISTRATIONPURPOSE_H

#include <QString>

enum class RegistrationPurpose {
    registration,
    password_reset
};

inline QString registrationPurposeToString(RegistrationPurpose purpose)
{
    switch (purpose) {
    case RegistrationPurpose::registration:
        return QStringLiteral("registration");
    case RegistrationPurpose::password_reset:
        return QStringLiteral("password_reset");
    }
    return QStringLiteral("registration");
}

inline QString normalizeRegistrationPurpose(const QString &purpose)
{
    QString normalized = purpose.trimmed().toLower();
    normalized.replace(QLatin1Char('-'), QLatin1Char('_'));
    normalized.remove(QLatin1Char(' '));

    if (normalized == QLatin1String("password_reset")
        || normalized == QLatin1String("passwordreset")) {
        return registrationPurposeToString(RegistrationPurpose::password_reset);
    }

    return registrationPurposeToString(RegistrationPurpose::registration);
}

#endif // EREGISTRATIONPURPOSE_H