import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string label: ""
    property string valueText: ""
    property color accentColor: "#2563EB"
    property string actionHint: ""
    property int lableFontSize: 22
    property bool clickable: false
    signal clicked()

    implicitWidth: 160
    implicitHeight: contentCol.implicitHeight + 26
    radius: 12
    color: mouseArea.pressed ? "#F8FAFC" : "#FFFFFF"
    border.color: "#E5E7EB"
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
            // Stat values are long currency figures and long counts. Keep them
            // on one line but let them wrap to a second line before anything is
            // truncated, so a wide value is never silently cut off.
            wrapMode: Text.WordWrap
            maximumLineCount: 2
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
            visible: root.actionHint.length > 0 && root.clickable
            text: root.actionHint + " \u203A"
            font.pixelSize: 11
            font.bold: true
            color: root.accentColor
            Layout.bottomMargin: 10
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
