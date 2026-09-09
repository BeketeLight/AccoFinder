import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Horizontal stat summary: an equal-width value + caption column per entry,
// separated by 1px dividers. Shared by the admin and agent dashboards
// (disputes, users, agent bookings summary). UI-only; the entries are fed
// the already-computed values from the caller's view models.
Rectangle {
    id: root

    // List of { value, label, color } objects rendered left to right.
    property var model: []
    property color backgroundColor: "#FFFFFF"
    property color borderColor: "#E5E7EB"
    property color dividerColor: "#E5E7EB"
    property color labelColor: "#6B7280"
    property int valuePixelSize: 17
    property int labelPixelSize: 11
    property int margin: 12

    Layout.fillWidth: true
    implicitHeight: contentRow.implicitHeight + root.margin * 2
    radius: 12
    color: root.backgroundColor
    border.color: root.borderColor
    border.width: 1

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: root.margin
        spacing: 0

        Repeater {
            model: root.model

            delegate: Item {
                required property int index
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredHeight: statCell.implicitHeight

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    width: 1
                    height: parent.height - root.margin * 2
                    color: root.dividerColor
                    visible: index > 0
                }

                ColumnLayout {
                    id: statCell
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 2

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.value
                        font.pixelSize: root.valuePixelSize
                        font.bold: true
                        color: modelData.color
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.label
                        font.pixelSize: root.labelPixelSize
                        color: root.labelColor
                    }
                }
            }
        }
    }
}