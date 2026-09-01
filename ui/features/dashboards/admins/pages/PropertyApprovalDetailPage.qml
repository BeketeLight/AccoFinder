import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../properties/models"
import "../../../../components/cards"
import "../../../../components/dialogs"
import "../../../../components/indicators"
import "../../../../utils/Utils.js" as Utils

// Dedicated review screen for a single property awaiting admin verification.
// Shows every detail the backend exposes (including photos, if any) so the
// admin can decide to Approve or Reject based on full information.
Item {
    id: root

    property var propertyPayload: null
    property string propertyId: ""
    property var listingsModel: null

    signal decisionMade(var propertyId, var title, var approved)
    signal goBackRequested()

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color pageColor: "#F8FAFC"
    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color dangerColor: "#DC2626"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color softRedColor: "#FEF2F2"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property string propTitle: propertyPayload ? (propertyPayload.title || "Untitled property") : ""
    property string propDescription: propertyPayload ? (propertyPayload.description || "") : ""
    property string propDistrict: propertyPayload && propertyPayload.physicalAddress ? (propertyPayload.physicalAddress.district || "") : ""
    property string propVillage: propertyPayload && propertyPayload.physicalAddress ? (propertyPayload.physicalAddress.village || "") : ""
    property real propPrice: propertyPayload && propertyPayload.price ? Number(propertyPayload.price) : 0
    property string propLandlord: propertyPayload ? (propertyPayload.landlord || "") : ""
    property string propLandlordPhone: propertyPayload ? (propertyPayload.landlordPhone || "") : ""
    property string propOwner: propertyPayload ? (propertyPayload.ownerName || "") : ""
    property string propOwnerPhone: propertyPayload ? (propertyPayload.ownerPhone || "") : ""
    property var propAmenities: []
    property var propRooms: []
    property var propPhotos: []
    property string propStatus: propertyPayload ? String(propertyPayload.verificationStatus || "").toUpperCase() : "PENDING"

    readonly property bool hasPrice: root.propPrice > 0

    // Rooms live in the separate /rooms/ collection keyed by propertyId, so
    // pull them from RoomViewModel (via C++) instead of the (room-less) payload
    // snapshot. This also reacts to rooms arriving late via the Connections below.
    function syncRooms() {
        root.propRooms = root.propertyId ? RoomViewModel.roomsForProperty(root.propertyId) : []
    }

    // Amenities come from the property document (via C++). Fetching them here
    // keeps them authoritative and avoids QML ListModel/Array.isArray fragility.
    function syncAmenities() {
        root.propAmenities = root.propertyId ? PropertyViewModel.propertyListModel.amenitiesFor(root.propertyId) : []
    }

    function loadMedia() {
        if (!root.propertyId || root.propertyId.length === 0)
            return
        var serverPhotos = MediaViewModel.mediaForProperty(root.propertyId)
        if (serverPhotos && serverPhotos.length > 0) {
            root.propPhotos = serverPhotos
        } else {
            MediaViewModel.getMediaByProperty(root.propertyId)
        }
    }

    Component.onCompleted: {
        root.syncRooms()
        root.syncAmenities()
        root.loadMedia()
        RoomViewModel.loadRooms()
    }

    Connections {
        target: RoomViewModel.roomListModel
        function onCountChanged() { root.syncRooms() }
        function onModelReset() { root.syncRooms() }
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onCountChanged() { root.syncAmenities() }
        function onModelReset() { root.syncAmenities() }
        function onDataChanged() { root.syncAmenities() }
    }

    Connections {
        target: MediaViewModel.mediaListModel
        function onCountChanged() { root.loadMedia() }
        function onModelReset() { root.loadMedia() }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 24
        clip: true

        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: contentColumn
            x: Math.max(12, (width - 520) / 2)
            width: Math.min(parent.width - 24, 520)
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: heroColumn.implicitHeight + 32
                radius: 14
                color: root.primaryColor

                ColumnLayout {
                    id: heroColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 8

                    Label {
                        Layout.fillWidth: true
                        text: root.propTitle
                        color: "#FFFFFF"
                        font.pixelSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        Layout.fillWidth: true
                        text: (root.propDistrict.length > 0 || root.propVillage.length > 0)
                              ? root.propDistrict + " · " + root.propVillage : qsTr("No location provided")
                        color: Qt.rgba(1, 1, 1, 0.85)
                        font.pixelSize: 13
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        implicitHeight: priceLine.implicitHeight + 20
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            id: priceLine
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Label {
                                text: root.hasPrice ? "MK " + Number(root.propPrice).toLocaleString() : qsTr("Rent on request")
                                color: "#FFFFFF"
                                font.pixelSize: 21
                                font.bold: true
                            }

                            Label {
                                visible: root.hasPrice
                                text: qsTr("/ month")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 13
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: {
                                    var s = root.propStatus
                                    if (s === "PENDING") return qsTr("PENDING")
                                    if (s === "VERIFIED") return qsTr("VERIFIED")
                                    if (s === "REJECTED") return qsTr("REJECTED")
                                    return s
                                }
                                color: Qt.rgba(1, 1, 1, 0.9)
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Photos")
                actionLabel: root.propPhotos.length > 0 ? qsTr("%1 shown").arg(root.propPhotos.length) : ""
            }

            Rectangle {
                visible: root.propPhotos.length === 0
                Layout.fillWidth: true
                implicitHeight: 120
                radius: 12
                color: root.softBlueColor
                border.color: "#BFDBFE"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No photos available for this listing")
                        color: root.textColor
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("The agent has not attached images to this property.")
                        color: root.mutedColor
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                visible: root.propPhotos.length > 0
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
                        model: root.propPhotos

                        delegate: Item {
                            required property var modelData
                            required property int index
                            readonly property string photoSource: {
                                if (typeof modelData === "string")
                                    return Utils.cachedImage(modelData)
                                return Utils.cachedImage(modelData.path || modelData.url || "")
                            }
                            readonly property bool isPrimary: typeof modelData === "object" && !!modelData.isPrimary

                            width: 110
                            height: 130

                            Rectangle {
                                width: 110
                                height: 110
                                radius: 10
                                color: root.softBlueColor
                                clip: true
                                border.color: isPrimary ? root.primaryColor : root.borderColor
                                border.width: isPrimary ? 2 : 1

                                Image {
                                    id: thumbImage
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: photoSource
                                    sourceSize.width: 280
                                    sourceSize.height: 280
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                }

                                AppSpinner {
                                    anchors.centerIn: parent
                                    size: 16
                                    lineWidth: 2
                                    color: root.mutedColor
                                    running: thumbImage.status === Image.Loading
                                    visible: running
                                }

                                Label {
                                    visible: thumbImage.status === Image.Error
                                    anchors.centerIn: parent
                                    text: qsTr("No preview")
                                    color: root.mutedColor
                                    font.pixelSize: 8
                                }

                                Rectangle {
                                    visible: isPrimary
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

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: photoViewer.openWithImages(root.propPhotos, index)
                                }
                            }

                            Label {
                                y: 114
                                width: parent.width
                                text: isPrimary ? qsTr("Cover") : qsTr("Photo %1").arg(index + 1)
                                color: root.mutedColor
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Property details")
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: aboutLabel.implicitHeight + 28
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Label {
                    id: aboutLabel
                    anchors.fill: parent
                    anchors.margins: 14
                    text: root.propDescription.length > 0 ? root.propDescription : qsTr("No description provided by the agent.")
                    color: root.textColor
                    font.pixelSize: 13
                    lineHeight: 1.25
                    wrapMode: Text.WordWrap
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Amenities")
                actionLabel: String(root.propAmenities.length)
            }

            Rectangle {
                visible: root.propAmenities.length === 0
                Layout.fillWidth: true
                implicitHeight: 64
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: qsTr("No amenities listed")
                    color: root.mutedColor
                    font.pixelSize: 12
                }
            }

            Rectangle {
                visible: root.propAmenities.length > 0
                Layout.fillWidth: true
                implicitHeight: amenFlow.implicitHeight + 24
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Flow {
                    id: amenFlow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Repeater {
                        model: root.propAmenities

                        delegate: Rectangle {
                            required property var modelData
                            readonly property string label: {
                                var labels = {
                                    "WIFI": qsTr("Wi-Fi"), "PARKING": qsTr("Parking"),
                                    "SECURITY": qsTr("Security"), "WATER": qsTr("Water"),
                                    "ELECTRICITY": qsTr("Electricity"), "FURNISHED": qsTr("Furnished"),
                                    "AC": qsTr("A/C")
                                }
                                return labels[String(modelData)] !== undefined ? labels[String(modelData)] : String(modelData)
                            }
                            width: labelChip.implicitWidth + 24
                            height: 28
                            radius: 14
                            color: root.softBlueColor

                            Label {
                                id: labelChip
                                anchors.centerIn: parent
                                text: parent.label
                                color: root.primaryColor
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Rooms")
                actionLabel: String(root.propRooms.length)
            }

            Rectangle {
                visible: root.propRooms.length === 0
                Layout.fillWidth: true
                implicitHeight: 64
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: qsTr("No rooms listed")
                    color: root.mutedColor
                    font.pixelSize: 12
                }
            }

            Repeater {
                model: root.propRooms

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    implicitHeight: roomRow.implicitHeight + 20
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
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
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
                                text: qsTr("Room %1 · %2").arg(index + 1).arg(modelData.roomType || modelData.type || "")
                                color: root.textColor
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Label {
                                text: {
                                    var rp = Number(modelData.price || 0)
                                    return rp > 0 ? "MK " + rp.toLocaleString() + qsTr("/mo") : qsTr("Price on request")
                                }
                                color: root.mutedColor
                                font.pixelSize: 11
                            }
                        }

                        StatusChip {
                            textValue: modelData.available === false ? qsTr("Unavailable") : qsTr("Available")
                            variant: modelData.available === false ? "neutral" : "success"
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Contacts")
            }

            ContactCard {
                title: qsTr("Listed by")
                name: root.propOwner
                phone: root.propOwnerPhone
                accentColor: root.primaryColor
                onCallRequested: function (number) {
                    if (number && number.length > 0)
                        Qt.openUrlExternally("tel:" + number)
                }
            }

            ContactCard {
                title: qsTr("Landlord")
                name: root.propLandlord
                phone: root.propLandlordPhone
                accentColor: root.successColor
                onCallRequested: function (number) {
                    if (number && number.length > 0)
                        Qt.openUrlExternally("tel:" + number)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: rejectButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    text: qsTr("Reject")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: rejectButton.text
                        color: "#B91C1C"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 23
                        color: rejectButton.down ? "#FEE2E2" : root.softRedColor
                        border.color: "#FECACA"
                        border.width: 1
                    }

                    onClicked: {
                        if (root.listingsModel)
                            root.listingsModel.setPropertyStatus(root.propertyId, "REJECTED")
                        // Persist the decision on the backend so it survives a
                        // refresh. setPropertyStatus only edits the local list.
                        PropertyViewModel.updatePropertyStatus(root.propertyId, "REJECTED")
                        console.log("Approval:", root.propertyId, "-> REJECTED")
                        root.decisionMade(root.propertyId, root.propTitle, false)
                        root.goBackRequested()
                    }
                }

                Button {
                    id: approveButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    text: qsTr("Approve")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: approveButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 23
                        color: approveButton.down ? "#15803D" : root.successColor
                    }

                    onClicked: {
                        if (root.listingsModel)
                            root.listingsModel.setPropertyStatus(root.propertyId, "VERIFIED")
                        // Persist the decision on the backend so it survives a
                        // refresh. setPropertyStatus only edits the local list.
                        PropertyViewModel.updatePropertyStatus(root.propertyId, "VERIFIED")
                        console.log("Approval:", root.propertyId, "-> VERIFIED")
                        root.decisionMade(root.propertyId, root.propTitle, true)
                        root.goBackRequested()
                    }
                }
            }
        }
    }

    AppImageLightbox {
        id: photoViewer
        anchors.fill: parent
        title: root.propTitle
        onClosed: { }
    }
}
