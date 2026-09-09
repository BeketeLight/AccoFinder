import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: root

    property string roomId: ""
    property string roomType: ""
    property real price: 0
    property bool available: true
    property int index: -1

    property color primaryColor: "#2563EB"
    property color textColor: "#1F2937"
    property color errorColor: "#EF4444"

    signal editRequested(int index)
    signal removeRequested(int index)

    Layout.fillWidth: true
    implicitHeight: roomCardCol.implicitHeight + 22
    radius: 12
    color: "#EFF6FF"
    border.color: "#BFDBFE"
    border.width: 1

    ColumnLayout {
        id: roomCardCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 11
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Room %1 · %2").arg(root.roomId).arg(root.roomType) + (root.available ? "" : qsTr(" · unavailable"))
                    color: root.textColor
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Label {
                    text: qsTr("MK %1 / month").arg(Number(root.price).toLocaleString())
                    color: root.primaryColor
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            StatusChip {
                textValue: root.available ? qsTr("Available") : qsTr("Unavailable")
                variant: root.available ? "success" : "neutral"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Item { Layout.fillWidth: true }

            Button {
                id: editRoomButton
                Layout.preferredHeight: 32

                contentItem: Label {
                    text: qsTr("Edit")
                    color: editRoomButton.pressed ? "#1D4ED8" : root.primaryColor
                    font.pixelSize: 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8
                    color: editRoomButton.pressed ? "#DBEAFE" : "transparent"
                }

                onClicked: root.editRequested(root.index)
            }

            Button {
                id: removeRoomButton
                Layout.preferredHeight: 32

                contentItem: Label {
                    text: removeRoomButton.down ? qsTr("Sure?") : qsTr("Remove")
                    color: root.errorColor
                    font.pixelSize: 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8
                    color: removeRoomButton.down ? "#FEE2E2" : "transparent"
                    border.color: "#FECACA"
                    border.width: removeRoomButton.down ? 1 : 0
                }

                onClicked: {
                    if (!removeRoomButton.down) {
                        removeRoomButton.down = true
                        roomRemoveTimer.restart()
                    } else {
                        root.removeRequested(root.index)
                    }
                }

                Timer {
                    id: roomRemoveTimer
                    interval: 2500
                    onTriggered: removeRoomButton.down = false
                }
            }
        }
    }
}