import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string label: ""
    property string valueText: ""
    property color accentColor: "#2563EB"
    property string hint: ""
    property int lableFontSize: 22
    property bool clickable: false
    signal clicked()

    implicitWidth: 160
    implicitHeight: contentCol.implicitHeight + 26
    radius: 12
    color: mouseArea.pressed ? "#F8FAFC" : "#FFFFFF"
    border.color: clickable ? "#BFDBFE" : "#E5E7EB"
    border.width: 1

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        width: 4
        height: parent.height - 28
        radius: 2
        color: root.accentColor
    }

    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 13
        anchors.leftMargin: 26
        spacing: 3

        Label {
            Layout.fillWidth: true
            text: root.valueText
            font.pixelSize: root.lableFontSize
            font.bold: true
            color: "#1F2937"
            elide: Text.ElideRight
        }

        Label {
            Layout.fillWidth: true
            text: root.label
            font.pixelSize: 12
            color: "#6B7280"
            wrapMode: Text.WordWrap
        }

        Label {
            Layout.fillWidth: true
            text: root.hint
            font.pixelSize: 11
            font.bold: true
            color: root.accentColor
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
