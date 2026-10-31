import QtQuick

// Backing state for the Settings screen. AppSettings is a plain QObject with
// non-reactive Q_INVOKABLE getters, so every value is mirrored here and
// refreshed from the matching change signal. All writes go straight to
// AppSettings, which persists them with QSettings.
Item {
    id: root

    readonly property var themeOptions: [
        { key: "System", label: qsTr("System") },
        { key: "Light", label: qsTr("Light") },
        { key: "Dark", label: qsTr("Dark") }
    ]

    readonly property var languageOptions: [
        { key: "en", label: qsTr("English") },
        { key: "ny", label: qsTr("Chichewa") }
    ]

    property string theme: AppSettings.theme()
    property string language: AppSettings.language()
    property bool notificationsEnabled: AppSettings.notificationsEnabled()
    property bool bookingNotifications: AppSettings.bookingNotifications()
    property bool promotionNotifications: AppSettings.promotionNotifications()
    property bool systemNotifications: AppSettings.systemNotifications()

    function labelFor(options, key) {
        for (var i = 0; i < options.length; i++) {
            if (options[i].key === key)
                return options[i].label
        }
        return key
    }

    function setTheme(key) {
        AppSettings.setTheme(key)
    }

    function setLanguage(key) {
        AppSettings.setLanguage(key)
    }

    function setNotificationsEnabled(value) {
        AppSettings.setNotificationsEnabled(value)
    }

    function setBookingNotifications(value) {
        AppSettings.setBookingNotifications(value)
    }

    function setPromotionNotifications(value) {
        AppSettings.setPromotionNotifications(value)
    }

    function setSystemNotifications(value) {
        AppSettings.setSystemNotifications(value)
    }

    Connections {
        target: AppSettings

        function onThemeChanged() {
            root.theme = AppSettings.theme()
        }

        function onLanguageChanged() {
            root.language = AppSettings.language()
        }

        function onNotificationPreferencesChanged() {
            root.notificationsEnabled = AppSettings.notificationsEnabled()
            root.bookingNotifications = AppSettings.bookingNotifications()
            root.promotionNotifications = AppSettings.promotionNotifications()
            root.systemNotifications = AppSettings.systemNotifications()
        }
    }
}
