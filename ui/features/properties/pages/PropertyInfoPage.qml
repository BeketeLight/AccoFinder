import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"

Item {
    id: root

    readonly property string propertyNameValue: nameInput.text.trim()
    readonly property string propertyTypeValue: typeDropdown.currentText
    readonly property string propertyLocationValue: locationInput.text.trim()
    readonly property string landlordValue: landlordInput.text.trim()
    readonly property string landlordPhoneValue: landlordPhoneInput.text.trim()
    readonly property real priceValue: {
        var parsed = parseFloat(priceInput.text)
        return isNaN(parsed) ? 0 : parsed
    }
    readonly property string descriptionValue: descriptionArea.text.trim()

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal nextRequested

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Label {
            text: qsTr("Tell us about the property")
            color: root.textColor
            font.pixelSize: 22
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("These details appear on the client listing once the property is verified.")
            color: root.mutedColor
            font.pixelSize: 13
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -8
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            spacing: 7

            AppTextInput {
                id: nameInput
                label: qsTr("Property name")
                placeholder: qsTr("e.g. Sunview Apartments")
                required: true
                fieldHeight: 52
                backgroundColor: root.surfaceColor
                textColor: root.textColor
                labelColor: root.textColor
                placeholderColor: "#9CA3AF"
                borderColor: root.borderColor
                focusColor: root.primaryColor
                errorColor: root.errorColor
                Layout.fillWidth: true
                Layout.preferredHeight: 76
            }

            AppDropdown {
                id: typeDropdown
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                fieldHeight: 52
                label: qsTr("Property type")
                placeholder: qsTr("Select property type...")
                model: ["Hostel", "Room","Quaties"]
                backgroundColor: root.surfaceColor
                borderColor: typeError.visible ? root.errorColor : root.borderColor
                focusBorderColor: root.primaryColor
                textColor: root.textColor
            }
        }

        AppTextInput {
            id: locationInput
            label: qsTr("Location")
            placeholder: qsTr("e.g. Area 47, Lilongwe")
            required: true
            fieldHeight: 52
            backgroundColor: root.surfaceColor
            textColor: root.textColor
            labelColor: root.textColor
            placeholderColor: "#9CA3AF"
            borderColor: root.borderColor
            focusColor: root.primaryColor
            errorColor: root.errorColor
            Layout.fillWidth: true
            Layout.preferredHeight: 76
        }

        AppTextInput {
            id: landlordInput
            label: qsTr("Landlord")
            placeholder: qsTr("e.g. Thokozani Banda")
            required: true
            fieldHeight: 52
            backgroundColor: root.surfaceColor
            textColor: root.textColor
            labelColor: root.textColor
            placeholderColor: "#9CA3AF"
            borderColor: landlordError.visible ? root.errorColor : root.borderColor
            focusColor: root.primaryColor
            errorColor: root.errorColor
            Layout.fillWidth: true
            Layout.preferredHeight: 76
        }

        AppTextInput {
            id: landlordPhoneInput
            label: qsTr("Landlord phone number")
            placeholder: qsTr("e.g. +265 999 123 456")
            required: true
            fieldHeight: 52
            backgroundColor: root.surfaceColor
            textColor: root.textColor
            labelColor: root.textColor
            placeholderColor: "#9CA3AF"
            borderColor: landlordError.visible ? root.errorColor : root.borderColor
            focusColor: root.primaryColor
            errorColor: root.errorColor
            Layout.fillWidth: true
            Layout.preferredHeight: 76
        }

        AppTextInput {
            id: priceInput
            label: qsTr("Price (MK per month)")
            placeholder: qsTr("e.g. 25000")
            required: true
            fieldHeight: 52
            backgroundColor: root.surfaceColor
            textColor: root.textColor
            labelColor: root.textColor
            placeholderColor: "#9CA3AF"
            borderColor: root.borderColor
            focusColor: root.primaryColor
            errorColor: root.errorColor
            Layout.fillWidth: true
            Layout.preferredHeight: 76
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Label {
                text: qsTr("Description *")
                color: root.textColor
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            TextArea {
                id: descriptionArea
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                placeholderText: ""
                color: root.textColor
                font.pixelSize: 14
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                leftPadding: 14
                rightPadding: 14
                topPadding: descriptionArea.activeFocus || descriptionArea.text.length > 0 ? 26 : 14
                bottomPadding: descriptionArea.activeFocus || descriptionArea.text.length > 0 ? 8 : 14

                background: Item {
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: root.surfaceColor
                        border.width: descriptionArea.activeFocus || descriptionError.visible ? 2 : 1
                        border.color: descriptionError.visible ? root.errorColor
                                     : descriptionArea.activeFocus ? root.primaryColor
                                     : root.borderColor
                    }

                    Text {
                        id: descriptionFloating
                        readonly property bool isFloating: descriptionArea.activeFocus || descriptionArea.text.length > 0
                        text: qsTr("Describe the property, amenities and rules...")
                        color: descriptionError.visible ? root.errorColor
                               : descriptionArea.activeFocus ? root.primaryColor
                               : "#9CA3AF"
                        font.pixelSize: isFloating ? 11 : 14
                        font.weight: isFloating ? Font.Medium : Font.Normal
                        x: 14
                        width: parent.width - 28
                        elide: Text.ElideRight

                        y: isFloating ? 7 : Math.round((parent.height - height) / 2)

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
                }
            }
        }

        Label {
            id: typeError
            visible: false
            text: qsTr("Select the property type")
            color: root.errorColor
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Label {
            id: landlordError
            visible: false
            text: qsTr("Enter the landlord name and a valid phone number")
            color: root.errorColor
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Label {
            id: descriptionError
            visible: false
            text: qsTr("Add a short description of at least 10 characters")
            color: root.errorColor
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Label {
            id: errorText
            visible: text.length > 0
            text: ""
            color: root.errorColor
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Button {
            id: continueButton
            text: qsTr("Continue")
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            Layout.topMargin: 6

            contentItem: Text {
                text: continueButton.text
                color: "#FFFFFF"
                font.pixelSize: 15
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 12
                color: continueButton.down ? "#1D4ED8" : root.primaryColor
            }

            onClicked: root.validateAndContinue()
        }
    }

    function validateAndContinue() {
        errorText.text = ""

        if (root.propertyNameValue.length === 0) {
            errorText.text = qsTr("Enter the property name.")
            return
        }
        if (typeDropdown.currentIndex < 0) {
            typeError.visible = true
            errorText.text = qsTr("Complete the highlighted fields to continue.")
            return
        }
        if (root.propertyLocationValue.length === 0) {
            errorText.text = qsTr("Enter the property location.")
            return
        }
        if (root.landlordValue.length === 0 || root.landlordPhoneValue.length < 7) {
            landlordError.visible = true
            errorText.text = qsTr("Complete the highlighted fields to continue.")
            return
        }
        if (root.priceValue <= 0) {
            errorText.text = qsTr("Enter a valid price greater than 0.")
            return
        }
        if (root.descriptionValue.length < 10) {
            descriptionError.visible = true
            errorText.text = qsTr("Complete the highlighted fields to continue.")
            return
        }

        typeError.visible = false
        landlordError.visible = false
        descriptionError.visible = false
        root.nextRequested()
    }
}
