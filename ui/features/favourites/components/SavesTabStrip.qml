import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Two-tab strip that matches the app's palette. Emits `tabChanged(index)`
// whenever the user picks a tab. Counts are driven from outside so the strip
// stays dumb — SavesScreen re-reads them from AppSettings.
Item {
    id: root

    property int currentIndex: 0
    property int propertiesCount: 0
    property int roomsCount: 0

    signal tabChanged(int index)

    implicitHeight: 48

    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#E5E7EB"
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 4

        Repeater {
            model: [
                {
                    text: qsTr("Properties"),
                    count: root.propertiesCount
                },
                {
                    text: qsTr("Rooms"),
                    count: root.roomsCount
                }
            ]

            delegate: Item {
                required property var model
                required property int index
                Layout.fillWidth: true
                Layout.fillHeight: true

                readonly property bool selected: root.currentIndex === index

                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.bottomMargin: 4
                    anchors.leftMargin: 2
                    anchors.rightMargin: 2
                    radius: 10
                    color: parent.selected ? "#EFF6FF" : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Label {
                        text: model.text
                        font.pixelSize: 13
                        font.weight: parent.parent.selected ? Font.DemiBold : Font.Medium
                        color: parent.parent.selected ? "#2563EB" : "#6B7280"
                    }

                    Rectangle {
                        visible: model.count > 0
                        implicitWidth: countLabel.implicitWidth + 12
                        implicitHeight: 18
                        radius: 9
                        color: parent.parent.selected ? "#2563EB" : "#E5E7EB"

                        Label {
                            id: countLabel
                            anchors.centerIn: parent
                            text: model.count
                            font.pixelSize: 10
                            font.bold: true
                            color: parent.parent.selected ? "#FFFFFF" : "#4B5563"
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 2
                    color: parent.selected ? "#2563EB" : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.tabChanged(index)
                }
            }
        }
    }
}
