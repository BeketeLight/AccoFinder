import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: headerId
    height: 56
    padding: 0
    spacing: 0

    // Force background
    background: Rectangle {
        anchors.fill: parent
        color: "#ADD8E6"
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        Label {
            text: qsTr("Sign in/Register")
            color: "black"
            font.bold: true
            font.pointSize: 18
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }

        ToolButton {
            icon.source: "qrc:/ui/assets/settings.svg"
            icon.width: 24
            icon.height: 24
            icon.color: "black"
            background: null
            padding: 0
            implicitWidth: 40
            implicitHeight: 40
        }

        ToolButton {
            icon.source: "qrc:/ui/assets/notification.svg"
            icon.width: 24
            icon.height: 24
            icon.color: "black"
            background: null
            padding: 0
            implicitWidth: 40
            implicitHeight: 40
        }
    }
}