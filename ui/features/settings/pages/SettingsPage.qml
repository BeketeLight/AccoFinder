import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
import "../../properties/components"

// The settings content. `SettingsScreen` wraps this in AppScrollablePage so the
// page participates in the standard header/back-stack flow.
Item {
    id: root

    property SettingsModel settingsModel: SettingsModel {}
    property string actionError: ""
    property bool pendingLogout: false

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color dangerColor: "#DC2626"
    readonly property color mutedColor: "#6B7280"

    function openPrivacy() {
        privacyDialog.open()
    }

    function requestLogout() {
        actionError = ""
        logoutDialog.open()
    }

    function confirmLogout() {
        logoutDialog.close()
        pendingLogout = true
        AuthController.logOut()
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Rectangle {
            Layout.fillWidth: true
            visible: root.actionError.length > 0
            implicitHeight: actionErrorLabel.implicitHeight + 16
            radius: 8
            color: "#FEF2F2"
            border.color: "#FECACA"

            Label {
                id: actionErrorLabel
                anchors.fill: parent
                anchors.margins: 8
                text: root.actionError
                color: root.dangerColor
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }
        }

        // ---------------------------------------------------------------
        // Appearance
        // ---------------------------------------------------------------
        SectionHeader {
            title: qsTr("Appearance")
        }

        SettingsGroup {
            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Theme")
                subtitle: qsTr("Apply immediately and remember on this device")
                kind: "navigation"
                valueText: root.settingsModel.labelFor(root.settingsModel.themeOptions,
                                                       root.settingsModel.theme)
                onActivated: themeDialog.open()
            }

            SettingsDivider { }

            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Language")
                subtitle: qsTr("Used for app text and number/date formatting")
                kind: "navigation"
                valueText: root.settingsModel.labelFor(root.settingsModel.languageOptions,
                                                       root.settingsModel.language)
                onActivated: languageDialog.open()
            }
        }

        // ---------------------------------------------------------------
        // Notifications
        // ---------------------------------------------------------------
        SectionHeader {
            title: qsTr("Notifications")
        }

        SettingsGroup {
            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Allow notifications")
                subtitle: qsTr("Master switch for all push notifications")
                kind: "toggle"
                checked: root.settingsModel.notificationsEnabled
                onToggled: (value) => root.settingsModel.setNotificationsEnabled(value)
            }

            SettingsDivider { }

            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Booking updates")
                subtitle: qsTr("Payment, hold and booking status changes")
                kind: "toggle"
                rowEnabled: root.settingsModel.notificationsEnabled
                checked: root.settingsModel.bookingNotifications
                onToggled: (value) => root.settingsModel.setBookingNotifications(value)
            }

            SettingsDivider { }

            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Promotions")
                subtitle: qsTr("Offers and featured listings")
                kind: "toggle"
                rowEnabled: root.settingsModel.notificationsEnabled
                checked: root.settingsModel.promotionNotifications
                onToggled: (value) => root.settingsModel.setPromotionNotifications(value)
            }

            SettingsDivider { }

            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("System announcements")
                subtitle: qsTr("Maintenance and account notices")
                kind: "toggle"
                rowEnabled: root.settingsModel.notificationsEnabled
                checked: root.settingsModel.systemNotifications
                onToggled: (value) => root.settingsModel.setSystemNotifications(value)
            }
        }

        // ---------------------------------------------------------------
        // Privacy
        // ---------------------------------------------------------------
        SectionHeader {
            title: qsTr("Privacy")
        }

        SettingsGroup {
            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Privacy notice")
                subtitle: qsTr("What the app stores and where it is sent")
                kind: "navigation"
                onActivated: root.openPrivacy()
            }
        }

        // ---------------------------------------------------------------
        // Account
        // ---------------------------------------------------------------
        SectionHeader {
            title: qsTr("Account")
        }

        SettingsGroup {
            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Log out")
                subtitle: qsTr("End the session on this device")
                kind: "action"
                destructive: true
                rowEnabled: !root.pendingLogout
                onActivated: root.requestLogout()
            }

            // "Delete account" is intentionally not shown: the API only allows
            // an ADMIN to delete a user (DELETE /users/:id), so a self-service
            // button here would be a dead end. Account deletion stays a
            // support/admin action until the backend exposes a self-delete
            // endpoint.
        }

        // ---------------------------------------------------------------
        // About
        // ---------------------------------------------------------------
        SectionHeader {
            title: qsTr("About")
        }

        SettingsGroup {
            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Version")
                kind: "action"
                valueText: Qt.application.version.length > 0
                           ? Qt.application.version
                           : qsTr("Development build")
            }

            SettingsDivider { }

            SettingsDelegate {
                Layout.fillWidth: true
                title: qsTr("Account type")
                kind: "action"
                valueText: AppSettings.userType().length > 0
                           ? AppSettings.userType()
                           : qsTr("Guest")
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
        }
    }

    // -------------------------------------------------------------------
    // Reusable group shell: white card with rounded corners.
    // -------------------------------------------------------------------
    component SettingsGroup: Rectangle {
        id: group
        default property alias content: groupColumn.data

        Layout.fillWidth: true
        implicitHeight: groupColumn.implicitHeight + 12
        radius: 12
        color: "#FFFFFF"
        border.color: "#E5E7EB"
        border.width: 1

        ColumnLayout {
            id: groupColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 6
            spacing: 0
        }
    }

    component SettingsDivider: Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        implicitHeight: 1
        color: "#F3F4F6"
    }

    // -------------------------------------------------------------------
    // Theme / language pickers
    // -------------------------------------------------------------------
    OptionDialog {
        id: themeDialog
        heading: qsTr("Theme")
        options: root.settingsModel.themeOptions
        currentKey: root.settingsModel.theme
        onSelected: (key) => root.settingsModel.setTheme(key)
    }

    OptionDialog {
        id: languageDialog
        heading: qsTr("Language")
        options: root.settingsModel.languageOptions
        currentKey: root.settingsModel.language
        onSelected: (key) => root.settingsModel.setLanguage(key)
    }

    component OptionDialog: Popup {
        id: dialog

        property string heading: ""
        property var options: []
        property string currentKey: ""

        signal selected(string key)

        modal: true
        anchors.centerIn: parent
        width: Math.min((parent ? parent.width : 360) - 48, 340)
        padding: 18
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 16
            color: "#FFFFFF"
            border.color: "#E5E7EB"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 6

            Label {
                Layout.fillWidth: true
                Layout.bottomMargin: 4
                text: dialog.heading
                color: "#111827"
                font.pixelSize: 16
                font.bold: true
            }

            Repeater {
                model: dialog.options

                delegate: Button {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 44
                    text: modelData.label

                    contentItem: RowLayout {
                        spacing: 8

                        Label {
                            Layout.fillWidth: true
                            text: modelData.label
                            color: modelData.key === dialog.currentKey
                                   ? "#2563EB"
                                   : "#111827"
                            font.pixelSize: 14
                            font.bold: modelData.key === dialog.currentKey
                        }

                        Label {
                            visible: modelData.key === dialog.currentKey
                            text: "\u2713"
                            color: "#2563EB"
                            font.pixelSize: 15
                            font.bold: true
                        }
                    }

                    background: Rectangle {
                        radius: 10
                        color: modelData.key === dialog.currentKey
                               ? "#EFF6FF"
                               : (parent.down ? "#F3F4F6" : "transparent")
                    }

                    onClicked: {
                        dialog.selected(modelData.key)
                        dialog.close()
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------
    // Privacy notice
    // -------------------------------------------------------------------
    Popup {
        id: privacyDialog

        modal: true
        anchors.centerIn: parent
        width: Math.min((parent ? parent.width : 360) - 48, 380)
        padding: 20
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 16
            color: "#FFFFFF"
            border.color: "#E5E7EB"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Privacy notice")
                color: "#111827"
                font.pixelSize: 16
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("AccoFinder stores the account details you provide (name, email, phone, location and payment details) together with listings, bookings and payment references so the service can operate. Requests are sent over HTTPS to the AccoFinder API.")
                color: "#374151"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Theme, language and notification preferences are stored only on this device. Signing out clears the session token from this device.")
                color: "#374151"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Account deletion is handled by an administrator because the API does not expose self-service deletion. Contact your administrator to remove your account.")
                color: "#374151"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Button {
                Layout.fillWidth: true
                Layout.topMargin: 4
                implicitHeight: 42
                text: qsTr("Close")

                contentItem: Label {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 10
                    color: "#2563EB"
                }

                onClicked: privacyDialog.close()
            }
        }
    }

    // -------------------------------------------------------------------
    // Logout confirmation
    // -------------------------------------------------------------------
    Popup {
        id: logoutDialog

        modal: true
        anchors.centerIn: parent
        width: Math.min((parent ? parent.width : 360) - 48, 340)
        padding: 20
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 16
            color: "#FFFFFF"
            border.color: "#E5E7EB"
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Log out?")
                color: "#111827"
                font.pixelSize: 16
                font.bold: true
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Your saved session will be cleared from this device. You can sign in again at any time.")
                color: "#6B7280"
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    text: qsTr("Cancel")

                    contentItem: Label {
                        text: parent.text
                        color: "#111827"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: "transparent"
                        border.color: "#E5E7EB"
                        border.width: 1
                    }

                    onClicked: logoutDialog.close()
                }

                Button {
                    Layout.fillWidth: true
                    implicitHeight: 44
                    text: qsTr("Log out")

                    contentItem: Label {
                        text: parent.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: parent.down ? "#B91C1C" : "#DC2626"
                    }

                    onClicked: root.confirmLogout()
                }
            }
        }
    }

    Connections {
        target: AuthController

        function onUserLoggedOut() {
            root.pendingLogout = false
            NavUtils.resetToSignIn()
        }
    }
}
