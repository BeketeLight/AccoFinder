import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string title: ""
    property string actionLabel: ""
    signal actionTriggered()

    implicitWidth: 300
    implicitHeight: 30

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 4
            Layout.preferredHeight: 18
            radius: 2
            color: "#2563EB"
        }

        Label {
            Layout.fillWidth: true
            text: root.title
            font.pixelSize: 16
            font.bold: true
            color: "#111827"
            elide: Text.ElideRight
        }

        Label {
            visible: root.actionLabel.length > 0
            text: root.actionLabel
            color: "#2563EB"
            font.pixelSize: 13
            font.bold: true

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: root.actionTriggered()
            }
        }
    }
}
