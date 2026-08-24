import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

    property color primaryColor: "#2563EB"
    property color primaryDarkColor: "#1D4ED8"
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
    property string pageTitle: "  Profile"
    property bool showHeader: true
    property bool showBottomBorder: false

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
                implicitHeight: heroContent.implicitHeight + 40
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.primaryColor }
                    GradientStop { position: 1.0; color: root.primaryDarkColor }
                }

                Rectangle {
                    x: parent.width - 70
                    y: -30
                    width: 140
                    height: 140
                    radius: 70
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                Rectangle {
                    x: parent.width - 150
                    y: 60
                    width: 90
                    height: 90
                    radius: 45
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                ColumnLayout {
                    id: heroContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Welcome back,")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 13
                            }

                            Label {
                                Layout.fillWidth: true
                                text: valueOr(root.profileName, "Your profile")
                                color: "#FFFFFF"
                                font.pixelSize: 20
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: 28
                            Layout.preferredWidth: roleChipLabel.implicitWidth + 20
                            radius: 14
                            color: Qt.rgba(1, 1, 1, 0.16)

                            Label {
                                id: roleChipLabel
                                anchors.centerIn: parent
                                text: prettyRole(AppSettings.userType())
                                color: "#FFFFFF"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 54
                            Layout.preferredHeight: 54
                            radius: 27
                            color: Qt.rgba(1, 1, 1, 0.18)

                            Text {
                                anchors.centerIn: parent
                                text: initials(root.profileName)
                                color: "#FFFFFF"
                                font.pixelSize: 19
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: valueOr(root.profileEmail, "No email saved")
                                color: Qt.rgba(1, 1, 1, 0.78)
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: valueOr(root.profilePhone, "No phone number yet")
                                color: Qt.rgba(1, 1, 1, 0.6)
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }

                        Button {
                            id: heroEditButton
                            Layout.preferredHeight: 38
                            text: root.editMode ? qsTr("Cancel") : qsTr("Edit profile")

                            contentItem: Label {
                                text: heroEditButton.text
                                color: root.primaryDarkColor
                                font.pixelSize: 13
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 19
                                color: heroEditButton.down ? "#DBEAFE" : "#FFFFFF"
                            }

                            onClicked: {
                                root.editMode = !root.editMode;
                                if (!root.editMode)
                                    loadProfile();
                            }
                        }
                    }
                }
            }

            Button {
                id: saveButton
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                visible: root.editMode
                text: qsTr("Save changes")

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
            NavUtils.resetToSignIn();
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
        property string placeholder: ""
        property bool editable: false
        property int floatingLabelTopMargin: 5
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
            id: fieldInput
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            text: field.value
            enabled: field.editable
            placeholderText: ""
            selectByMouse: true
            color: root.textColor
            font.pixelSize: 14
            onTextEdited: field.edited(text)

            readonly property bool isFloating: activeFocus || text.length > 0
            readonly property bool showNotSet: !field.editable && (field.value === "" || field.value === undefined || field.value === null)

            // Adjust padding to make room for floating label
            leftPadding: 12
            rightPadding: 12
            topPadding: isFloating ? floatingLabelTopMargin + 14 : 0
            bottomPadding: isFloating ? 8 : 0
            verticalAlignment: Text.AlignVCenter

            // Custom floating placeholder
            Text {
                id: floatingLabel
                text: field.placeholder
                visible: field.editable && field.placeholder.length > 0
                color: {
                    if (fieldInput.activeFocus)
                        return root.primaryColor
                    return root.mutedColor
                }
                font.pixelSize: fieldInput.isFloating ? 11 : 14
                font.weight: fieldInput.isFloating ? Font.Medium : Font.Normal

                x: 12
                width: parent.width - 24
                elide: Text.ElideRight

                y: fieldInput.isFloating
                   ? floatingLabelTopMargin
                   : Math.round((parent.height - height) / 2)

                Behavior on y {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on font.pixelSize {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 140
                    }
                }
            }

            // "Not set" text for read-only mode
            Text {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                text: "Not set"
                color: root.mutedColor
                font.pixelSize: 14
                visible: fieldInput.showNotSet
                elide: Text.ElideRight
            }

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

    function prettyRole(role) {
        var r = String(role || "client").toLowerCase();
        if (r === "admin" || r === "super_admin")
            return qsTr("Administrator");
        if (r === "agent")
            return qsTr("Agent");
        if (r === "landlord")
            return qsTr("Landlord");
        return qsTr("Client");
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
