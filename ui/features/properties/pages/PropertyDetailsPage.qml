import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../../../utils" as UtilsModule

Page {
    id: root

    readonly property color pageColor: "#F8FAFC"
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color secondaryColor: "#22C55E"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color softRedColor: "#FEF2F2"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property string propertyTitleName: qsTr("Sunset Apartments")
    property string propertyDistrictValue: qsTr("Lilongwe")
    property string propertyVillageValue: qsTr("Area 47")
    property real monthlyPrice: 85000
    // verificationStatus mirrors the backend enum: PENDING / VERIFIED / REJECTED ("" = local draft)
    property string verificationStatus: "PENDING"
    property string descriptionTextValue: qsTr("Modern three-bedroom house with spacious rooms, tiled floors and a perimeter fence. Close to shops and public transport.")
    property string landlordName: qsTr("Bryan Phiri")
    property string landlordPhone: qsTr("+265 999 123 456")

    property var amenitiesList: []
    property var roomsList: []
    property var photosList: []

    readonly property string prettyStatus: {
        var s = String(root.verificationStatus).toUpperCase()
        if (s === "VERIFIED") return qsTr("Verified")
        if (s === "PENDING") return qsTr("Pending")
        if (s === "REJECTED") return qsTr("Rejected")
        if (s === "DRAFT") return qsTr("Draft")
        return s.length > 0 ? s : qsTr("Draft")
    }

    readonly property bool agentMode: AppSettings.userType() === "AGENT"
                                      || AppSettings.userType() === "ADMIN"
                                      || AppSettings.userType() === "SUPER_ADMIN"
    property bool editMode: false

    property string editNameValue: ""
    property string editDistrictValue: ""
    property string editVillageValue: ""
    property string editMonthlyPriceValue: ""
    property string editDescriptionValue: ""
    property string editLandlordNameValue: ""
    property string editLandlordPhoneValue: ""

    signal propertyUpdated(var data)
    signal propertyDeleted()

    function applyPayload(p) {
        if (!p) return
        if (p.title) root.propertyTitleName = p.title
        if (p.description) root.descriptionTextValue = p.description
        if (p.physicalAddress) {
            if (p.physicalAddress.district) root.propertyDistrictValue = p.physicalAddress.district
            if (p.physicalAddress.village) root.propertyVillageValue = p.physicalAddress.village
        }
        if (p.price !== undefined && Number(p.price) > 0) root.monthlyPrice = Number(p.price)
        if (p.landlord) root.landlordName = p.landlord
        if (p.landlordPhone) root.landlordPhone = p.landlordPhone
        if (p.amenities) root.amenitiesList = p.amenities
        root.roomsList = p.rooms ? p.rooms : []
        root.photosList = p.photos ? p.photos : []
        if (p.verificationStatus !== undefined)
            root.verificationStatus = String(p.verificationStatus)
    }

    function startEditing() {
        root.editNameValue = root.propertyTitleName
        root.editDistrictValue = root.propertyDistrictValue
        root.editVillageValue = root.propertyVillageValue
        root.editMonthlyPriceValue = String(Math.round(root.monthlyPrice))
        root.editDescriptionValue = root.descriptionTextValue
        root.editLandlordNameValue = root.landlordName
        root.editLandlordPhoneValue = root.landlordPhone
        root.editMode = true
    }

    function cancelEditing() {
        root.editMode = false
    }

    function saveChanges() {
        if (root.editNameValue.trim().length === 0) return
        root.propertyTitleName = root.editNameValue.trim()
        if (root.editDistrictValue.trim().length > 0)
            root.propertyDistrictValue = root.editDistrictValue.trim()
        if (root.editVillageValue.trim().length > 0)
            root.propertyVillageValue = root.editVillageValue.trim()
        var parsedPrice = Number(root.editMonthlyPriceValue.replace(/[^0-9.]/g, ""))
        if (!isNaN(parsedPrice) && parsedPrice > 0)
            root.monthlyPrice = parsedPrice
        if (root.editDescriptionValue.trim().length > 0)
            root.descriptionTextValue = root.editDescriptionValue.trim()
        if (root.editLandlordNameValue.trim().length > 0)
            root.landlordName = root.editLandlordNameValue.trim()
        if (root.editLandlordPhoneValue.trim().length > 0)
            root.landlordPhone = root.editLandlordPhoneValue.trim()
        root.editMode = false
        // Same shape the backend Property model expects
        root.propertyUpdated({
            title: root.propertyTitleName,
            description: root.descriptionTextValue,
            physicalAddress: {
                district: root.propertyDistrictValue,
                village: root.propertyVillageValue
            },
            verificationStatus: root.verificationStatus,
            isActive: true,
            price: root.monthlyPrice,
            landlord: root.landlordName,
            landlordPhone: root.landlordPhone
        })
    }

    background: Rectangle { color: root.pageColor }

    header: ToolBar {
        background: Rectangle { color: "#FFFFFF" }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16

            ToolButton {
                id: backButton

                contentItem: Item {
                    implicitWidth: 24
                    implicitHeight: 24

                    Rectangle {
                        width: 12
                        height: 2
                        radius: 1
                        color: root.textColor
                        rotation: 45
                        transformOrigin: Item.Right
                        x: 0
                        y: 4.5
                    }

                    Rectangle {
                        width: 12
                        height: 2
                        radius: 1
                        color: root.textColor
                        rotation: -45
                        transformOrigin: Item.Right
                        x: 0
                        y: 17.5
                    }
                }

                onClicked: {
                    if (root.editMode) {
                        root.cancelEditing()
                        return
                    }
                    UtilsModule.NavigationUtils.pop()
                }
            }

            Label {
                Layout.fillWidth: true
                text: root.agentMode && root.editMode ? qsTr("Edit property") : qsTr("Property details")
                font.pixelSize: 17
                font.bold: true
                color: root.textColor
                elide: Text.ElideRight
            }

            Button {
                id: editToggleButton
                visible: root.agentMode
                Layout.preferredWidth: 74
                Layout.preferredHeight: 32
                text: root.editMode ? qsTr("Done") : qsTr("Edit")

                contentItem: Label {
                    text: editToggleButton.text
                    color: root.primaryColor
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 16
                    color: root.softBlueColor
                    border.color: root.primaryColor
                    border.width: 1
                }

                onClicked: root.editMode ? root.saveChanges() : root.startEditing()
            }

            StatusChip {
                visible: !(root.agentMode && root.editMode)
                textValue: root.prettyStatus
                variant: {
                    var s = String(root.verificationStatus).toUpperCase()
                    if (s === "VERIFIED") return "success"
                    if (s === "PENDING") return "warning"
                    if (s === "REJECTED") return "danger"
                    return "neutral"
                }
            }
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: detailsColumn.implicitHeight + 32
        clip: true

        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: detailsColumn
            x: Math.max(16, (flick.width - 520) / 2)
            y: 20
            width: Math.min(flick.width - 32, 520)
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: heroColumn.implicitHeight + 40
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.primaryColor }
                    GradientStop { position: 1.0; color: root.primaryDarkColor }
                }

                ColumnLayout {
                    id: heroColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 8

                    Label {
                        visible: !root.editMode
                        Layout.fillWidth: true
                        text: root.propertyTitleName
                        color: "#FFFFFF"
                        font.pixelSize: 21
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        visible: root.editMode
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.14)
                        border.color: nameField.activeFocus ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.4)
                        border.width: 1

                        TextField {
                            id: nameField
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            text: root.editNameValue
                            onTextChanged: root.editNameValue = text
                            placeholderText: qsTr("Property name")
                            color: "#FFFFFF"
                            placeholderTextColor: Qt.rgba(1, 1, 1, 0.55)
                            font.pixelSize: 15
                            font.bold: true
                            background: null
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }

                    RowLayout {
                        visible: !root.editMode
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 5
                            Layout.preferredHeight: 5
                            radius: 2.5
                            color: Qt.rgba(1, 1, 1, 0.85)
                        }

                        Label {
                            text: root.propertyDistrictValue + " · " + root.propertyVillageValue
                            color: Qt.rgba(1, 1, 1, 0.85)
                            font.pixelSize: 13
                        }

                        Item { Layout.fillWidth: true }
                    }

                    Rectangle {
                        visible: root.editMode
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.14)
                        border.color: districtField.activeFocus ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.4)
                        border.width: 1

                        TextField {
                            id: districtField
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            text: root.editDistrictValue
                            onTextChanged: root.editDistrictValue = text
                            placeholderText: qsTr("District")
                            color: "#FFFFFF"
                            placeholderTextColor: Qt.rgba(1, 1, 1, 0.55)
                            font.pixelSize: 13
                            background: null
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }

                    Rectangle {
                        visible: root.editMode
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.14)
                        border.color: villageField.activeFocus ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.4)
                        border.width: 1

                        TextField {
                            id: villageField
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            text: root.editVillageValue
                            onTextChanged: root.editVillageValue = text
                            placeholderText: qsTr("e.g. Area 47")
                            color: "#FFFFFF"
                            placeholderTextColor: Qt.rgba(1, 1, 1, 0.55)
                            font.pixelSize: 13
                            background: null
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        implicitHeight: priceRow.implicitHeight + 24
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            id: priceRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Label {
                                visible: !root.editMode
                                text: "MK " + Number(root.monthlyPrice).toLocaleString()
                                color: "#FFFFFF"
                                font.pixelSize: 22
                                font.bold: true
                            }

                            Label {
                                visible: !root.editMode
                                text: qsTr("/ month")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 13
                            }

                            Label {
                                visible: root.editMode
                                text: "MK"
                                color: "#FFFFFF"
                                font.pixelSize: 17
                                font.bold: true
                            }

                            TextField {
                                id: priceField
                                visible: root.editMode
                                Layout.preferredWidth: 130
                                text: root.editMonthlyPriceValue
                                onTextChanged: root.editMonthlyPriceValue = text
                                placeholderText: qsTr("Rent per month")
                                color: "#FFFFFF"
                                placeholderTextColor: Qt.rgba(1, 1, 1, 0.55)
                                font.pixelSize: 15
                                font.bold: true
                                inputMethodHints: Qt.ImhDigitsOnly
                                background: Rectangle {
                                    radius: 8
                                    color: Qt.rgba(1, 1, 1, 0.14)
                                    border.color: priceField.activeFocus ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.4)
                                    border.width: 1
                                }
                                verticalAlignment: TextInput.AlignVCenter
                                leftPadding: 10
                                rightPadding: 10
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                visible: !root.editMode
                                text: qsTr("Rent per room")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Photos")
                actionLabel: root.photosList.length > 0 ? qsTr("%1 attached").arg(root.photosList.length) : ""
            }

            Rectangle {
                visible: root.photosList.length === 0
                Layout.fillWidth: true
                implicitHeight: photosPlaceholder.implicitHeight + 24
                radius: 14
                color: root.softBlueColor
                border.color: "#BFDBFE"
                border.width: 1

                ColumnLayout {
                    id: photosPlaceholder
                    anchors.centerIn: parent
                    spacing: 10

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 34

                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: "transparent"
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: -5
                            width: 16
                            height: 9
                            radius: 3
                            color: root.softBlueColor
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 15
                            height: 15
                            radius: 7.5
                            color: "transparent"
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 3
                            color: root.primaryColor
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.agentMode ? qsTr("Manage photos from Add Property") : qsTr("No photos uploaded yet")
                        color: root.primaryDarkColor
                        font.pixelSize: 12
                    }
                }
            }

            Rectangle {
                visible: root.photosList.length > 0
                Layout.fillWidth: true
                implicitHeight: photosFlow.implicitHeight + 24
                radius: 14
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Flow {
                    id: photosFlow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Repeater {
                        model: root.photosList

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: 88
                            height: 108

                            Rectangle {
                                width: 88
                                height: 88
                                radius: 10
                                color: root.softBlueColor
                                clip: true
                                border.color: modelData.isPrimary ? root.primaryColor : root.borderColor
                                border.width: modelData.isPrimary ? 2 : 1

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: modelData.path
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }

                                Rectangle {
                                    visible: !!modelData.isPrimary
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 6
                                    width: coverLabel.implicitWidth + 12
                                    height: 18
                                    radius: 9
                                    color: root.primaryColor

                                    Label {
                                        id: coverLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Cover")
                                        color: "#FFFFFF"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }
                            }

                            Label {
                                y: 92
                                width: parent.width
                                text: modelData.isPrimary ? qsTr("Cover photo") : qsTr("Photo %1").arg(index + 1)
                                color: root.mutedColor
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                visible: root.roomsList.length > 0
                Layout.fillWidth: true
                spacing: 10

                SectionHeader {
                    Layout.fillWidth: true
                    title: qsTr("Rooms")
                    actionLabel: qsTr("%1 listed").arg(root.roomsList.length)
                }

                Repeater {
                    model: root.roomsList

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        implicitHeight: roomRow.implicitHeight + 24
                        radius: 12
                        color: root.surfaceColor
                        border.color: root.borderColor
                        border.width: 1

                        RowLayout {
                            id: roomRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 38
                                Layout.preferredHeight: 38
                                radius: 10
                                color: root.softBlueColor

                                Label {
                                    anchors.centerIn: parent
                                    text: String(index + 1)
                                    color: root.primaryColor
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    Layout.fillWidth: true
                                    text: qsTr("Room %1 · %2").arg(index + 1).arg(modelData.roomType)
                                    color: root.textColor
                                    font.pixelSize: 13
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Label {
                                    text: "MK " + Number(modelData.price).toLocaleString() + qsTr("/mo")
                                    color: root.mutedColor
                                    font.pixelSize: 11
                                }
                            }

                            StatusChip {
                                textValue: modelData.available ? qsTr("Available") : qsTr("Unavailable")
                                variant: modelData.available ? "success" : "neutral"
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("About this property")
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: root.editMode ? Math.max(descriptionArea.implicitHeight + 24, 120) : aboutLabel.implicitHeight + 28
                radius: 12
                color: root.surfaceColor
                border.color: root.editMode ? root.primaryColor : root.borderColor
                border.width: 1

                Label {
                    id: aboutLabel
                    visible: !root.editMode
                    anchors.fill: parent
                    anchors.margins: 14
                    text: root.descriptionTextValue
                    color: root.textColor
                    font.pixelSize: 13
                    lineHeight: 1.25
                    wrapMode: Text.WordWrap
                }

                ScrollView {
                    visible: root.editMode
                    anchors.fill: parent
                    anchors.margins: 10

                    TextArea {
                        id: descriptionArea
                        text: root.editDescriptionValue
                        onTextChanged: root.editDescriptionValue = text
                        color: root.textColor
                        placeholderText: qsTr("Describe this property")
                        placeholderTextColor: root.mutedColor
                        font.pixelSize: 13
                        wrapMode: TextArea.Wrap
                        background: null
                    }
                }
            }

            SectionHeader {
                visible: root.amenitiesList.length > 0
                Layout.fillWidth: true
                title: qsTr("Amenities")
            }

            Rectangle {
                visible: root.amenitiesList.length > 0
                Layout.fillWidth: true
                implicitHeight: amenitiesFlow.implicitHeight + 24
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Flow {
                    id: amenitiesFlow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Repeater {
                        model: root.amenitiesList

                        delegate: Rectangle {
                            required property var modelData
                            readonly property string amenityLabel: {
                                var labels = {
                                    "WIFI": qsTr("Wi-Fi"), "PARKING": qsTr("Parking"),
                                    "SECURITY": qsTr("Security"), "WATER": qsTr("Water"),
                                    "ELECTRICITY": qsTr("Electricity"), "FURNISHED": qsTr("Furnished"),
                                    "AC": qsTr("A/C")
                                }
                                return labels[String(modelData)] !== undefined
                                       ? labels[String(modelData)] : String(modelData)
                            }
                            width: amenityChipLabel.implicitWidth + 24
                            height: 28
                            radius: 14
                            color: root.softBlueColor

                            Label {
                                id: amenityChipLabel
                                anchors.centerIn: parent
                                text: parent.amenityLabel
                                color: root.primaryDarkColor
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Rooms")
                    valueText: String(root.roomsList.length)
                    accentColor: root.primaryColor
                }

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Monthly rent")
                    valueText: "MK " + Number(root.monthlyPrice).toLocaleString()
                    accentColor: root.successColor
                }

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Verification")
                    valueText: root.prettyStatus
                    accentColor: root.warningColor
                }

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Amenities")
                    valueText: String(root.amenitiesList.length)
                    accentColor: root.primaryDarkColor
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr(root.editMode ? "Landlord details" : "Listed by")
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: root.editMode ? landlordEditColumn.implicitHeight + 26 : ownerRow.implicitHeight + 26
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                RowLayout {
                    id: ownerRow
                    visible: !root.editMode
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: root.softBlueColor

                        Label {
                            anchors.centerIn: parent
                            text: root.landlordName.charAt(0)
                            color: root.primaryColor
                            font.pixelSize: 18
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            text: root.landlordName
                            color: root.textColor
                            font.pixelSize: 14
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.landlordPhone
                            color: root.mutedColor
                            font.pixelSize: 12
                        }
                    }

                    Button {
                        id: callButton
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: 78
                        text: qsTr("Call")

                        contentItem: Label {
                            text: callButton.text
                            color: root.primaryColor
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 18
                            color: callButton.down ? root.softBlueColor : "transparent"
                            border.color: root.primaryColor
                            border.width: 1
                        }

                        onClicked: console.log("Call landlord:", root.landlordPhone)
                    }
                }

                ColumnLayout {
                    id: landlordEditColumn
                    visible: root.editMode
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 13
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 46
                        radius: 10
                        color: root.pageColor
                        border.color: landlordNameField.activeFocus ? root.primaryColor : root.borderColor
                        border.width: 1

                        TextField {
                            id: landlordNameField
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            text: root.editLandlordNameValue
                            onTextChanged: root.editLandlordNameValue = text
                            placeholderText: qsTr("Landlord name")
                            color: root.textColor
                            placeholderTextColor: root.mutedColor
                            font.pixelSize: 13
                            background: null
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 46
                        radius: 10
                        color: root.pageColor
                        border.color: landlordPhoneField.activeFocus ? root.primaryColor : root.borderColor
                        border.width: 1

                        TextField {
                            id: landlordPhoneField
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            text: root.editLandlordPhoneValue
                            onTextChanged: root.editLandlordPhoneValue = text
                            placeholderText: qsTr("+265 999 123 456")
                            color: root.textColor
                            placeholderTextColor: root.mutedColor
                            font.pixelSize: 13
                            inputMethodHints: Qt.ImhDialableCharactersOnly
                            background: null
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }
                }
            }

            Rectangle {
                visible: root.agentMode
                Layout.fillWidth: true
                implicitHeight: deleteRow.implicitHeight + 28
                radius: 12
                color: root.softRedColor
                border.color: "#FECACA"
                border.width: 1

                RowLayout {
                    id: deleteRow
                    visible: root.agentMode
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: qsTr("Delete property")
                            color: root.dangerColor
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Permanently remove this listing and all its rooms.")
                            color: root.mutedColor
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                        }
                    }

                    Button {
                        id: deleteButton
                        Layout.preferredHeight: 38
                        Layout.preferredWidth: 92
                        text: qsTr("Delete")

                        contentItem: Label {
                            text: deleteButton.text
                            color: "#FFFFFF"
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 19
                            color: deleteButton.down ? "#B91C1C" : root.dangerColor
                        }

                        onClicked: deleteDialog.open()
                    }
                }
            }

            Item { Layout.preferredHeight: 8; Layout.fillWidth: true }
        }
    }

    Dialog {
        id: deleteDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 340)
        padding: 20

        background: Rectangle {
            radius: 16
            color: root.surfaceColor
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Delete this property?")
                color: root.textColor
                font.pixelSize: 16
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("\"%1\" will be permanently removed. This action cannot be undone.").arg(root.propertyTitleName)
                color: root.mutedColor
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 10

                Button {
                    id: keepButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Keep")

                    contentItem: Label {
                        text: keepButton.text
                        color: root.textColor
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: "transparent"
                        border.color: root.borderColor
                        border.width: 1
                    }

                    onClicked: deleteDialog.close()
                }

                Button {
                    id: confirmDeleteButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Delete")

                    contentItem: Label {
                        text: confirmDeleteButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: confirmDeleteButton.down ? "#B91C1C" : root.dangerColor
                    }

                    onClicked: {
                        deleteDialog.close()
                        root.propertyDeleted()
                        UtilsModule.NavigationUtils.pop()
                    }
                }
            }
        }
    }

    footer: Rectangle {
        implicitHeight: footerBarRow.implicitHeight + 24
        color: root.surfaceColor

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: root.borderColor
        }

        RowLayout {
            id: footerBarRow
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    text: "MK " + Number(root.monthlyPrice).toLocaleString()
                    color: root.textColor
                    font.pixelSize: 17
                    font.bold: true
                }

                Label {
                    text: root.agentMode ? qsTr("monthly rent") : qsTr("per month")
                    color: root.mutedColor
                    font.pixelSize: 11
                }
            }

            Button {
                id: agentFooterButton
                visible: root.agentMode
                Layout.preferredWidth: 170
                Layout.preferredHeight: 48
                text: root.editMode ? qsTr("Save changes") : qsTr("Edit property")

                contentItem: Label {
                    text: agentFooterButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 24
                    color: agentFooterButton.down ? root.primaryDarkColor : root.primaryColor
                }

                onClicked: root.editMode ? root.saveChanges() : root.startEditing()
            }

            Button {
                id: bookNowButton
                visible: !root.agentMode
                Layout.preferredWidth: 160
                Layout.preferredHeight: 48
                text: qsTr("Book now")

                contentItem: Label {
                    text: bookNowButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 24
                    color: bookNowButton.down ? root.primaryDarkColor : root.primaryColor
                }

                onClicked: UtilsModule.NavigationUtils.navigateToPayments()
            }
        }
    }
}
