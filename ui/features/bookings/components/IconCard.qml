import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string iconSource: ""
    property string title: ""
    property string amount: ""
    property int  iconCardWidth: 0
    property int  iconCardHeight: 0
    property color  iconColor: "#64748B"

    signal clicked()

    width: iconCardWidth
    height: iconCardHeight
    MouseArea{
        anchors.fill: parent
        onClicked: root.clicked()
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: 2
        //Layout.alignment: Qt.AligHCenter
        ToolButton{
            icon.source: root.iconSource
            icon.width: 24
            icon.height: 24
            background: null
            icon.color: root.iconColor
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: root.title
            font.pixelSize: 12
            font.bold: true
            color: "#0F172A"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            text: root.amount
            font.pixelSize: 13
            font.bold: true
            color: "#0F172A"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
}