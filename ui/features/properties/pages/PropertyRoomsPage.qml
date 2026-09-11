import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/inputs"
import "../delegates"

Item {
    id: root

    readonly property alias roomsModel: roomsModelId

    property color primaryColor: "#2563EB"
    property color secondaryColor: "#22C55E"
    property color surfaceColor: "#F5F5F5"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"
    property color errorColor: "#EF4444"

    signal nextRequested

    implicitHeight: layout.implicitHeight

    property bool errorRoomType: false
    property bool errorRoomPrice: false
    property int roomEditingIndex: -1
    property int roomSeq: 0

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Label {
            text: qsTr("Add rooms")
            color: root.textColor
            font.pixelSize: 22
            font.bold: true
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Each room is bookable separately. Set the price and availability for every room.")
            color: root.mutedColor
            font.pixelSize: 13
            lineHeight: 1.15
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.topMargin: -8
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: roomEditorCol.implicitHeight + 24
            radius: 12
            color: root.surfaceColor
            border.color: roomEditingIndex >= 0 ? root.primaryColor : root.borderColor
            border.width: roomEditingIndex >= 0 ? 2 : 1

            ColumnLayout {
                id: roomEditorCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 12

                Label {
                    Layout.fillWidth: true
                    text: roomEditingIndex >= 0 ? qsTr("Edit room") : qsTr("Add a room")
                    color: root.textColor
                    font.pixelSize: 14
                    font.bold: true
                }

                AppDropdown {
                    id: roomTypeDropdown
                    Layout.fillWidth: true
                    label: qsTr("Room type")
                    placeholder: qsTr("Select room type...")
                    model: ["Single", "Double", "Shared", "Self-contained", "Bedsitter", "Suite"]
                    backgroundColor: "#FFFFFF"
                    borderColor: errorRoomType ? root.errorColor : root.borderColor
                    focusBorderColor: root.primaryColor
                    textColor: root.textColor
                    currentIndex: -1
                    onActivated: function (index) { errorRoomType = false }
                }

                AppTextInput {
                    id: roomPriceInput
                    label: qsTr("Room price (MK per month)")
                    placeholder: qsTr("e.g. 12000")
                    fieldHeight: 48
                    backgroundColor: "#FFFFFF"
                    textColor: root.textColor
                    labelColor: root.textColor
                    placeholderColor: "#9CA3AF"
                    borderColor: root.errorRoomPrice ? root.errorColor : root.borderColor
                    focusColor: root.primaryColor
                    errorColor: root.errorColor
                    error: root.errorRoomPrice
                    helperText: root.errorRoomPrice ? qsTr("Enter a valid price greater than 0") : ""
                    onTextEdited: {
                        if (root.errorRoomPrice && parseFloat(text) > 0)
                            root.errorRoomPrice = false
                    }
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Label {
                            text: qsTr("Available for booking")
                            color: root.textColor
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Label {
                            text: roomAvailabilitySwitch.checked
                                  ? qsTr("Clients can book this room")
                                  : qsTr("Hidden from clients until available")
                            color: root.mutedColor
                            font.pixelSize: 11
                        }
                    }

                    Switch {
                        id: roomAvailabilitySwitch
                        checked: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        id: saveRoomButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        text: roomEditingIndex >= 0 ? qsTr("Update room") : qsTr("+ Add room")

                        contentItem: Text {
                            text: saveRoomButton.text
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 12
                            color: saveRoomButton.down ? "#1D4ED8" : root.primaryColor
                        }

                        onClicked: root.saveRoom()
                    }

                    Button {
                        id: cancelEditButton
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 46
                        visible: roomEditingIndex >= 0
                        text: qsTr("Cancel")

                        contentItem: Text {
                            text: cancelEditButton.text
                            color: root.mutedColor
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 12
                            color: cancelEditButton.down ? root.surfaceColor : "#FFFFFF"
                            border.color: root.borderColor
                            border.width: 1
                        }

                        onClicked: root.resetRoomEditor()
                    }
                }
            }
        }

        ColumnLayout {
            visible: roomsModelId.count > 0
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: ListModel {
                    id: roomsModelId
                }

                delegate: RoomCardDelegate {
                    roomId: model.roomId
                    roomType: model.roomType
                    price: model.price
                    available: model.available
                    index: index
                    onEditRequested: (i) => root.editRoom(i)
                    onRemoveRequested: (i) => {
                        roomsModelId.remove(i)
                        if (roomEditingIndex === i)
                            root.resetRoomEditor()
                        else if (roomEditingIndex > i)
                            roomEditingIndex--
                    }
                }
            }
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

            onClicked: {
                if (roomsModelId.count === 0) {
                    errorText.text = qsTr("Add at least one room before continuing.")
                    return
                }
                errorText.text = ""
                root.nextRequested()
            }
        }
    }

    function availableRoomCount() {
        var count = 0
        for (var i = 0; i < roomsModelId.count; i++) {
            if (roomsModelId.get(i).available)
                count++
        }
        return count
    }

    function saveRoom() {
        var price = parseFloat(roomPriceInput.text)
        if (roomTypeDropdown.currentIndex < 0) {
            errorRoomType = true
            return
        }
        if (isNaN(price) || price <= 0) {
            errorRoomPrice = true
            return
        }

        if (roomEditingIndex >= 0) {
            roomsModelId.set(roomEditingIndex, {
                                 roomId: roomsModelId.get(roomEditingIndex).roomId,
                                 roomType: roomTypeDropdown.currentText,
                                 price: price,
                                 available: roomAvailabilitySwitch.checked
                             })
        } else {
            root.roomSeq++
            roomsModelId.append({
                                    roomId: root.roomSeq,
                                    roomType: roomTypeDropdown.currentText,
                                    price: price,
                                    available: roomAvailabilitySwitch.checked
                                })
        }
        resetRoomEditor()
    }

    function editRoom(index) {
        roomEditingIndex = index
        var it = roomsModelId.get(index)
        roomTypeDropdown.currentIndex = roomTypeDropdown.model.indexOf(it.roomType)
        roomPriceInput.text = String(it.price)
        roomAvailabilitySwitch.checked = it.available
    }

    function resetRoomEditor() {
        roomEditingIndex = -1
        roomTypeDropdown.currentIndex = -1
        roomPriceInput.text = ""
        roomAvailabilitySwitch.checked = true
        errorRoomType = false
        errorRoomPrice = false
    }
}
