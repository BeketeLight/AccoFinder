import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"

Item {
    id: root

    // Field names mirror the backend Property schema:
    // title / physicalAddress.district / physicalAddress.village /
    // verificationStatus (set on submit) / amenities[] / isActive
    readonly property string titleValue: nameInput.text.trim()
    readonly property string districtValue: districtDropdown.currentText
    readonly property string villageValue: villageInput.text.trim()
    property var selectedAmenities: []
    readonly property var amenitiesValue: selectedAmenities
    readonly property string landlordValue: landlordInput.text.trim()
    readonly property string landlordPhoneValue: landlordPhoneInput.text.trim()
    readonly property var listingTypes: [
        { label: qsTr("Whole Property"), value: "WHOLE" },
        { label: qsTr("Hostel"), value: "HOSTEL" },
        { label: qsTr("Quarter"), value: "QUARTER" }
    ]
    readonly property var typeLabels: {
        var arr = []
        for (var i = 0; i < root.listingTypes.length; i++)
            arr.push(root.listingTypes[i].label)
        return arr
    }
    readonly property string propertyTypeValue:
        typeDropdown.currentIndex < 0 ? "" : root.listingTypes[typeDropdown.currentIndex].value
    readonly property bool isWholeProperty: root.propertyTypeValue === "WHOLE"
    readonly property bool needsRooms:
        root.propertyTypeValue === "HOSTEL" || root.propertyTypeValue === "QUARTER"
    readonly property real priceValue: {
        var parsed = parseFloat(priceInput.text)
        return isNaN(parsed) ? 0 : parsed
    }
    readonly property string descriptionValue: descriptionArea.text.trim()

    function toggleAmenity(token) {
        var arr = selectedAmenities.slice()
        var idx = arr.indexOf(token)
        if (idx === -1)
            arr.push(token)
        else
            arr.splice(idx, 1)
        selectedAmenities = arr
    }

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
                id: districtDropdown
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                fieldHeight: 52
                label: qsTr("District")
                placeholder: qsTr("Select district...")
                model: ["Lilongwe", "Blantyre", "Mzuzu", "Zomba", "Kasungu", "Salima", "Mangochi"]
                backgroundColor: root.surfaceColor
                borderColor: districtError.visible ? root.errorColor : root.borderColor
                focusBorderColor: root.primaryColor
                textColor: root.textColor
            }
        }

        AppTextInput {
            id: villageInput
            label: qsTr("Village / Area")
            placeholder: qsTr("e.g. Area 47")
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
            spacing: 7

            Label {
                text: qsTr("Amenities")
                color: root.textColor
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { token: "WIFI", label: qsTr("Wi-Fi") },
                        { token: "PARKING", label: qsTr("Parking") },
                        { token: "SECURITY", label: qsTr("Security") },
                        { token: "WATER", label: qsTr("Water") },
                        { token: "ELECTRICITY", label: qsTr("Electricity") },
                        { token: "FURNISHED", label: qsTr("Furnished") },
                        { token: "AC", label: qsTr("A/C") }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        width: amenityLabel.implicitWidth + 28
                        height: 32
                        radius: 16
                        color: root.selectedAmenities.indexOf(modelData.token) !== -1
                               ? root.primaryColor : root.surfaceColor
                        border.color: root.selectedAmenities.indexOf(modelData.token) !== -1
                                      ? root.primaryColor : root.borderColor
                        border.width: 1

                        Label {
                            id: amenityLabel
                            anchors.centerIn: parent
                            text: modelData.label
                            color: root.selectedAmenities.indexOf(modelData.token) !== -1
                                   ? "#FFFFFF" : root.mutedColor
                            font.pixelSize: 12
                            font.bold: root.selectedAmenities.indexOf(modelData.token) !== -1
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleAmenity(modelData.token)
                        }
                    }
                }
            }
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

        AppDropdown {
            id: typeDropdown
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            fieldHeight: 52
            label: qsTr("Listing type")
            placeholder: qsTr("Select listing type...")
            model: root.typeLabels
            backgroundColor: root.surfaceColor
            borderColor: root.borderColor
            focusBorderColor: root.primaryColor
            textColor: root.textColor
        }

        AppTextInput {
            id: priceInput
            visible: root.isWholeProperty
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
            id: districtError
            visible: false
            text: qsTr("Select the district and enter the village or area")
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

        if (root.titleValue.length === 0) {
            errorText.text = qsTr("Enter the property name.")
            return
        }
        if (typeDropdown.currentIndex < 0) {
            errorText.text = qsTr("Select the listing type.")
            return
        }
        if (districtDropdown.currentIndex < 0 || root.villageValue.length === 0) {
            districtError.visible = true
            errorText.text = qsTr("Complete the highlighted fields to continue.")
            return
        }
        if (root.landlordValue.length === 0 || root.landlordPhoneValue.length < 7) {
            landlordError.visible = true
            errorText.text = qsTr("Complete the highlighted fields to continue.")
            return
        }
        if (root.descriptionValue.length < 10) {
            descriptionError.visible = true
            errorText.text = qsTr("Complete the highlighted fields to continue.")
            return
        }

        districtError.visible = false
        landlordError.visible = false
        descriptionError.visible = false
        root.nextRequested()
    }
}
