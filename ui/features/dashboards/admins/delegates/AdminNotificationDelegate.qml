import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string message: ""
    property string audience: ""
    property string date: ""
    property var delivered: ""

    property color primaryColor: "#2563EB"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    Layout.fillWidth: true
    implicitHeight: historyContent.implicitHeight + 20
    radius: 12
    color: "#FFFFFF"
    border.color: root.borderColor
    border.width: 1

    ColumnLayout {
        id: historyContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: root.title
                color: "#111827"
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }

            Rectangle {
                implicitHeight: 20
                implicitWidth: audienceLabel.implicitWidth + 14
                radius: 10
                color: "#EFF6FF"

                Label {
                    id: audienceLabel
                    anchors.centerIn: parent
                    text: root.audience
                    color: root.primaryColor
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.message
            color: root.mutedColor
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }

        Label {
            Layout.fillWidth: true
            text: root.date + " \u00B7 " + qsTr("delivered to %1 users").arg(root.delivered)
            color: "#9CA3AF"
            font.pixelSize: 10
        }
    }
}