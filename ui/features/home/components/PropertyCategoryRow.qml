import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property alias model: listView.model
    property int currentIndex: 0

    signal categoryClicked(int index, string categoryName)

    height: 48

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: 10
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        // Nice left & right padding
        header: Item {
            width: 16
        }
        footer: Item {
            width: 16
        }

        delegate: Item {
            id: delegateRoot
            width: chip.implicitWidth
            height: listView.height

            required property int index
            required property string name          // category name
            // required property string icon       // optional later

            readonly property bool isSelected: index === root.currentIndex

            Rectangle {
                id: chip
                anchors.verticalCenter: parent.verticalCenter
                height: 34
                radius: 18
                implicitWidth: categoryText.implicitWidth + 28

                color: delegateRoot.isSelected ? "#2563EB" : "#F5F5F5"   // Primary : Cards
                border.width: delegateRoot.isSelected ? 0 : 1
                border.color: "#E5E7EB"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Label {
                    id: categoryText
                    anchors.centerIn: parent
                    text: name
                    font.pixelSize: 13
                    font.weight: delegateRoot.isSelected ? Font.DemiBold : Font.Normal
                    color: delegateRoot.isSelected ? "#FFFFFF" : "#1F2937"  // White : Primary Text
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = index;
                        root.categoryClicked(index, name);
                    }
                }
            }
        }

        // Smooth scrolling
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOff
        }
    }
}
