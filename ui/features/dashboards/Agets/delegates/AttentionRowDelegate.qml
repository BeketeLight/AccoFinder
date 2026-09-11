import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    property string reason: ""
    property string actionLabel: ""
    property string kind: ""
    property string targetId: ""
    property bool showSeparator: true

    property color softAmberColor: "#FFFBEB"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    signal clicked(var kind, var targetId)

    Layout.fillWidth: true
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: attnRow.implicitHeight + 20
        color: attnMouse.pressed ? root.softAmberColor : "transparent"

        RowLayout {
            id: attnRow
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 4
                Layout.preferredHeight: 36
                radius: 2
                color: "#F59E0B"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    Layout.fillWidth: true
                    text: root.title
                    color: root.textColor
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: root.reason
                    color: root.mutedColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
            }

            Button {
                id: attnActionButton
                Layout.preferredHeight: 30
                text: root.actionLabel

                contentItem: Label {
                    text: attnActionButton.text
                    color: "#B45309"
                    font.pixelSize: 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 15
                    color: attnActionButton.down ? "#FEF3C7" : "transparent"
                    border.color: "#FDE68A"
                    border.width: 1
                }

                onClicked: root.clicked(root.kind, root.targetId)
            }
        }

        MouseArea {
            id: attnMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked(root.kind, root.targetId)
        }
    }

    Rectangle {
        visible: root.showSeparator
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        Layout.leftMargin: 16
        color: root.borderColor
    }
}