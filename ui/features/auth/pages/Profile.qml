import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

    property color primaryColor: "#2563EB"
    property color successColor: "#16A34A"
    property color warningColor: "#D97706"
    property color pageColor: "#F8FAFC"
    property color surfaceColor: "#FFFFFF"
    property color softBlueColor: "#EFF6FF"
    property color softGreenColor: "#ECFDF5"
    property color softAmberColor: "#FFFBEB"
    property color textColor: "#111827"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    property bool editMode: false
    property string profileName: ""
    property string profileEmail: ""
    property string profilePhone: ""
    property string profileLocation: ""
    property string profileBank: ""
    property string profileAccount: ""
    property string profilePaymentMethod: "Mobile money"

    anchors.fill: parent

    background: Rectangle {
        color: root.pageColor
    }

    Component.onCompleted: {
        if (!AppSettings.isLoggedIn()) {
            NavUtils.navigateToCreateAccount();
            return;
        }

        loadProfile();
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 36
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        ColumnLayout {
            id: contentColumn
            width: Math.min(parent.width - 28, 520)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: headerContent.implicitHeight + 30
                radius: 8
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                ColumnLayout {
                    id: headerContent
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 58
                            Layout.preferredHeight: 58
                            radius: 29
                            color: root.softBlueColor
                            border.color: "#BFDBFE"

                            Text {
                                anchors.centerIn: parent
                                text: initials(root.profileName)
                                color: root.primaryColor
                                font.pixelSize: 20
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                Layout.fillWidth: true
                                text: valueOr(root.profileName, "Your profile")
                                color: root.textColor
                                font.pixelSize: 22
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: valueOr(root.profileEmail, "No email saved")
                                color: root.mutedColor
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 78
                            Layout.preferredHeight: 30
                            radius: 15
                            color: root.softGreenColor

                            Label {
                                anchors.centerIn: parent
                                text: valueOr(AppSettings.userType(), "client")
                                color: "#166534"
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.width - 14
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            id: editButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            text: root.editMode ? "Cancel" : "Edit profile"

                            contentItem: Text {
                                text: editButton.text
                                color: root.primaryColor
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 8
                                color: editButton.down ? "#DBEAFE" : root.softBlueColor
                                border.color: "#BFDBFE"
                            }

                            onClicked: {
                                root.editMode = !root.editMode;
                                if (!root.editMode)
                                    loadProfile();
                            }
                        }

                        Button {
                            id: saveButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            visible: root.editMode
                            text: "Save"

                            contentItem: Text {
                                text: saveButton.text
                                color: "#FFFFFF"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 8
                                color: saveButton.down ? "#1D4ED8" : root.primaryColor
                            }

                            onClicked: saveProfile()
                        }
                    }
                }
            }

            ProfileSection {
                title: "Personal information"

                FieldRow {
                    label: "Full name"
                    value: root.profileName
                    editable: root.editMode
                    onEdited: function(value) { root.profileName = value }
                }
                FieldRow {
                    label: "Email"
                    value: root.profileEmail
                    editable: root.editMode
                    onEdited: function(value) { root.profileEmail = value }
                }
                FieldRow {
                    label: "Phone"
                    value: root.profilePhone
                    placeholder: "Add phone number"
                    editable: root.editMode
                    onEdited: function(value) { root.profilePhone = value }
                }
            }

            ProfileSection {
                title: "Location"

                FieldRow {
                    label: "Preferred area"
                    value: root.profileLocation
                    placeholder: "Add your location"
                    editable: root.editMode
                    onEdited: function(value) { root.profileLocation = value }
                }
            }

            ProfileSection {
                title: "Banking details"

                FieldRow {
                    label: "Bank"
                    value: root.profileBank
                    placeholder: "Add bank name"
                    editable: root.editMode
                    onEdited: function(value) { root.profileBank = value }
                }
                FieldRow {
                    label: "Account"
                    value: root.profileAccount
                    placeholder: "Add account number"
                    editable: root.editMode
                    onEdited: function(value) { root.profileAccount = value }
                }
            }

            ProfileSection {
                title: "Payment method"

                ComboBox {
                    id: paymentCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    enabled: root.editMode
                    model: ["Mobile money", "Bank transfer", "Card", "Cash"]
                    currentIndex: Math.max(0, model.indexOf(root.profilePaymentMethod))
                    onActivated: root.profilePaymentMethod = currentText
                }

                Label {
                    Layout.fillWidth: true
                    text: root.editMode ? "Choose the method you prefer for accommodation payments." : "Preferred: " + root.profilePaymentMethod
                    color: root.mutedColor
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }

            ProfileSection {
                title: "Bookings"

                BookingProgressRow {
                    propertyName: "No active booking"
                    status: "Not started"
                    progress: 0.0
                    statusColor: root.mutedColor
                    detail: "Your booked items and booking progress will appear here after you make a booking."
                }

                Button {
                    id: bookingButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    text: "View bookings"

                    contentItem: Text {
                        text: bookingButton.text
                        color: root.primaryColor
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 8
                        color: bookingButton.down ? "#DBEAFE" : root.softBlueColor
                        border.color: "#BFDBFE"
                    }

                    onClicked: NavUtils.navigateToBookings()
                }
            }

            Button {
                id: logoutButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.topMargin: 2
                text: AuthController.isLoading ? "Signing out..." : "Sign out"
                enabled: !AuthController.isLoading

                contentItem: Text {
                    text: logoutButton.text
                    color: "#B91C1C"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8
                    color: logoutButton.down ? "#FEE2E2" : "#FEF2F2"
                    border.color: "#FECACA"
                }

                onClicked: AuthController.logOut()
            }
        }
    }

    Connections {
        target: AuthController

        function onUserLoggedOut() {
            NavUtils.navigateToCreateAccount();
        }
    }

    component ProfileSection: Rectangle {
        id: section
        property string title: ""
        default property alias content: sectionBody.data

        Layout.fillWidth: true
        Layout.preferredHeight: sectionColumn.implicitHeight + 28
        radius: 8
        color: root.surfaceColor
        border.color: root.borderColor
        border.width: 1

        ColumnLayout {
            id: sectionColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: section.title
                color: root.textColor
                font.pixelSize: 16
                font.bold: true
            }

            ColumnLayout {
                id: sectionBody
                Layout.fillWidth: true
                spacing: 10
            }
        }
    }

    component FieldRow: ColumnLayout {
        id: field
        property string label: ""
        property string value: ""
        property string placeholder: "Not set"
        property bool editable: false
        signal edited(string value)

        Layout.fillWidth: true
        spacing: 5

        Label {
            Layout.fillWidth: true
            text: field.label
            color: root.mutedColor
            font.pixelSize: 12
            font.bold: true
        }

        TextField {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            text: field.value
            enabled: field.editable
            placeholderText: field.placeholder
            selectByMouse: true
            color: root.textColor
            font.pixelSize: 14
            onTextEdited: field.edited(text)

            background: Rectangle {
                radius: 8
                color: field.editable ? "#FFFFFF" : "#F9FAFB"
                border.color: field.editable && parent.activeFocus ? root.primaryColor : root.borderColor
                border.width: field.editable && parent.activeFocus ? 2 : 1
            }
        }
    }

    component BookingProgressRow: Rectangle {
        id: bookingRow
        property string propertyName: ""
        property string status: ""
        property string detail: ""
        property real progress: 0
        property color statusColor: root.primaryColor

        Layout.fillWidth: true
        Layout.preferredHeight: bookingColumn.implicitHeight + 24
        radius: 8
        color: "#F9FAFB"
        border.color: root.borderColor

        ColumnLayout {
            id: bookingColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    Layout.fillWidth: true
                    text: bookingRow.propertyName
                    color: root.textColor
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                }

                Rectangle {
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 26
                    radius: 13
                    color: root.softAmberColor

                    Label {
                        anchors.centerIn: parent
                        width: parent.width - 10
                        text: bookingRow.status
                        color: bookingRow.statusColor
                        font.pixelSize: 11
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 1
                value: bookingRow.progress
            }

            Label {
                Layout.fillWidth: true
                text: bookingRow.detail
                color: root.mutedColor
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }
    }

    function loadProfile() {
        root.profileName = AppSettings.userName();
        root.profileEmail = AppSettings.email();
        root.profilePhone = AppSettings.phone();
        root.profileLocation = AppSettings.preferredLocation();
        root.profileBank = AppSettings.bankName();
        root.profileAccount = AppSettings.bankAccountNumber();
        root.profilePaymentMethod = AppSettings.paymentMethod();
    }

    function saveProfile() {
        AppSettings.setUserName(root.profileName.trim());
        AppSettings.setEmail(root.profileEmail.trim());
        AppSettings.setPhone(root.profilePhone.trim());
        AppSettings.setPreferredLocation(root.profileLocation.trim());
        AppSettings.setFilterLocation(root.profileLocation.trim());
        AppSettings.setBankName(root.profileBank.trim());
        AppSettings.setBankAccountNumber(root.profileAccount.trim());
        AppSettings.setPaymentMethod(root.profilePaymentMethod);
        root.editMode = false;
        loadProfile();
    }

    function valueOr(value, fallback) {
        return value && value.length > 0 ? value : fallback;
    }

    function initials(name) {
        if (!name || name.trim().length === 0)
            return "AF";

        var parts = name.trim().split(/\s+/);
        var result = parts[0].charAt(0);
        if (parts.length > 1)
            result += parts[1].charAt(0);
        return result.toUpperCase();
    }
}
