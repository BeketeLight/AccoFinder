import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property string titleValue: ""
    property string districtValue: ""
    property string villageValue: ""
    property var amenitiesValue: []
    property string landlordValue: ""
    property string landlordPhoneValue: ""
    property real priceValue: 0
    property string descriptionValue: ""
    property var roomsModelRef: null
    property var photosModelRef: null

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal submitRequested
    signal draftRequested

    implicitHeight: layout.implicitHeight

    component ReviewField: ColumnLayout {
        id: reviewField
        property string labelText: ""
        property string valueText: ""
        property bool wrapValue: false

        Layout.fillWidth: true
        spacing: 2

        Label {
            text: reviewField.labelText
            color: root.mutedColor
            font.pixelSize: 11
            font.bold: true
        }

        Label {
            Layout.fillWidth: true
            text: reviewField.valueText.length > 0 ? reviewField.valueText : "-"
            color: root.textColor
            font.pixelSize: 13
            elide: reviewField.wrapValue ? Text.ElideNone : Text.ElideRight
            wrapMode: reviewField.wrapValue ? Text.WordWrap : Text.NoWrap
            maximumLineCount: reviewField.wrapValue ? 4 : 1
        }
    }

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Label {
            text: qsTr("Review & submit")
            color: root.textColor
            font.pixelSize: 22
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Confirm everything looks right before sending this property for verification.")
            color: root.mutedColor
            font.pixelSize: 13
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -8
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: reviewInfoCol.implicitHeight + 24
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: reviewInfoCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 8

                ReviewField {
                    labelText: qsTr("Title")
                    valueText: root.titleValue
                }
                ReviewField {
                    labelText: qsTr("District")
                    valueText: root.districtValue
                }
                ReviewField {
                    labelText: qsTr("Village / Area")
                    valueText: root.villageValue
                }
                ReviewField {
                    labelText: qsTr("Amenities")
                    valueText: root.amenitiesLabel()
                }
                ReviewField {
                    labelText: qsTr("Landlord")
                    valueText: root.landlordValue
                }
                ReviewField {
                    labelText: qsTr("Landlord phone (for verification)")
                    valueText: root.landlordPhoneValue
                }
                ReviewField {
                    labelText: qsTr("Price")
                    valueText: root.priceValue > 0
                               ? qsTr("MK %1 / month").arg(Number(root.priceValue).toLocaleString())
                               : qsTr("On request")
                }
                ReviewField {
                    labelText: qsTr("Description")
                    valueText: root.descriptionValue
                    wrapValue: true
                }
            }
        }

        Rectangle {
            visible: root.roomsModelRef && root.roomsModelRef.count > 0
            Layout.fillWidth: true
            implicitHeight: reviewRoomsCol.implicitHeight + 24
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: reviewRoomsCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Rooms (%1)").arg(root.roomsModelRef ? String(root.roomsModelRef.count) : "0")
                        color: root.textColor
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    StatusChip {
                        textValue: qsTr("%1 available").arg(String(root.availableRoomCount()))
                        variant: root.availableRoomCount() > 0 ? "success" : "neutral"
                    }
                }

                Repeater {
                    model: root.roomsModelRef

                    delegate: RowLayout {
                        required property var model
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Room %1 · %2").arg(model.roomId).arg(model.roomType)
                            color: root.textColor
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        Label {
                            text: qsTr("MK %1").arg(Number(model.price).toLocaleString())
                            color: root.mutedColor
                            font.pixelSize: 12
                        }

                        StatusChip {
                            textValue: model.available ? qsTr("Available") : qsTr("Unavailable")
                            variant: model.available ? "success" : "neutral"
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: reviewPhotosCol.implicitHeight + 24
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1
            clip: true

            ColumnLayout {
                id: reviewPhotosCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 8

                Label {
                    text: qsTr("Photos (%1)").arg(root.photosModelRef ? String(root.photosModelRef.count) : "0")
                    color: root.textColor
                    font.pixelSize: 14
                    font.bold: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: root.photosModelRef

                        delegate: RowLayout {
                            required property var model
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 52
                                Layout.preferredHeight: 52
                                radius: 8
                                color: root.surfaceColor
                                border.color: model.isPrimary ? "#16A34A" : root.borderColor
                                border.width: model.isPrimary ? 2 : 1
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: model.path
                                    sourceSize.width: 180
                                    sourceSize.height: 180
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    Layout.fillWidth: true
                                    text: root.photoFileName(model.path)
                                    color: root.textColor
                                    font.pixelSize: 12
                                    elide: Text.ElideMiddle
                                }

                                Label {
                                    text: root.roomLabelFor(model.roomId)
                                    color: root.primaryColor
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            StatusChip {
                                visible: model.isPrimary
                                textValue: qsTr("Cover")
                                variant: "success"
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: noticeRow.implicitHeight + 22
            radius: 12
            color: "#EFF6FF"
            border.color: "#BFDBFE"
            border.width: 1

            RowLayout {
                id: noticeRow
                anchors.fill: parent
                anchors.margins: 11
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 13
                    color: root.primaryColor

                    Label {
                        anchors.centerIn: parent
                        text: "i"
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                        font.italic: true
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Submitting sends this property for verification with status Pending. It becomes visible to clients only after approval.")
                    color: "#1E40AF"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Layout.topMargin: 6

            Button {
                id: draftButton
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                text: qsTr("Save as draft")

                contentItem: Text {
                    text: draftButton.text
                    color: root.primaryColor
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: draftButton.down ? "#DBEAFE" : "#FFFFFF"
                    border.color: root.primaryColor
                    border.width: 1
                }

                onClicked: root.draftRequested()
            }

            Button {
                id: submitButton
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                text: qsTr("Submit for verification")

                contentItem: Text {
                    text: submitButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: submitButton.down ? "#1D4ED8" : root.primaryColor
                }

                onClicked: root.submitRequested()
            }
        }
    }

    function amenitiesLabel() {
        var labels = {
            "WIFI": qsTr("Wi-Fi"), "PARKING": qsTr("Parking"), "SECURITY": qsTr("Security"),
            "WATER": qsTr("Water"), "ELECTRICITY": qsTr("Electricity"),
            "FURNISHED": qsTr("Furnished"), "AC": qsTr("A/C")
        }
        var parts = []
        var list = root.amenitiesValue ? root.amenitiesValue : []
        for (var i = 0; i < list.length; i++) {
            var token = list[i]
            parts.push(labels[token] !== undefined ? labels[token] : token)
        }
        return parts.length > 0 ? parts.join(", ") : ""
    }

    function availableRoomCount() {        if (!roomsModelRef)
            return 0
        var count = 0
        for (var i = 0; i < roomsModelRef.count; i++) {
            if (roomsModelRef.get(i).available)
                count++
        }
        return count
    }

    function roomLabelFor(roomId) {
        if (roomId === undefined || roomId < 0)
            return qsTr("Whole property / common areas")
        if (roomsModelRef) {
            for (var i = 0; i < roomsModelRef.count; i++) {
                var r = roomsModelRef.get(i)
                if (r.roomId === roomId)
                    return qsTr("Room %1 · %2").arg(r.roomId).arg(r.roomType)
            }
        }
        return qsTr("Whole property / common areas")
    }

    function photoFileName(path) {
        var s = String(path)
        var slash = Math.max(s.lastIndexOf("/"), s.lastIndexOf("\\"))
        return slash >= 0 ? s.substring(slash + 1) : s
    }
}
