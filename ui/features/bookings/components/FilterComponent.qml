import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var model: ["All", "Pending Payment", "Confirmed", "Cancelled"]
    property int currentIndex: 0

    readonly property string currentText: {
        if (currentIndex >= 0 && currentIndex < model.length)
            return String(model[currentIndex])
        return "All"
    }

    signal filterChanged(string text)

    height: 40
    implicitHeight: 40
    Layout.fillWidth: true

    Row {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 8

        Repeater {
            model: root.model

            delegate: Rectangle {
                id: chip
                property bool active: index === root.currentIndex

                implicitWidth: label.implicitWidth + 28
                implicitHeight: 28
                radius: 16
                color: chip.active ? "#2563EB" : "transparent"

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 13
                    font.bold: chip.active
                    color: chip.active ? "#FFFFFF" : "#64748B"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.currentIndex === index)
                            return
                        root.currentIndex = index
                        root.filterChanged(String(modelData))
                    }
                }
            }
        }
    }
}