import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string detail: ""
    property string kind: ""

    property color surfaceColor: "#FFFFFF"
    property color softAmberColor: "#FFFBEB"
    property color borderColor: "#E5E7EB"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"

    signal clicked(var kind)

    Layout.fillWidth: true
    implicitHeight: activityContent.implicitHeight + 16
    radius: 12
    color: mouseArea.pressed ? root.softAmberColor : root.surfaceColor
    border.color: root.borderColor
    border.width: 1

    RowLayout {
        id: activityContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 4
            Layout.preferredHeight: 34
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
                text: root.detail
                color: root.mutedColor
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked(root.kind)
    }
}