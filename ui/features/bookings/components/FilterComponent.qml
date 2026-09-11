import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property int count: 0
    property bool selected: false

    signal clicked()

    implicitWidth: chipRow.implicitWidth + 24
    implicitHeight: 38
    radius: 19
    color: "transparent"//root.selected ? "#2B62ED" : "#EAEFF7"

    Behavior on color { ColorAnimation { duration: 150 } }
    ColumnLayout{
        anchors.fill: parent
        spacing: 0

        RowLayout {
            id: chipRow
            //anchors.centerIn: parent
            spacing: 8
            Layout.leftMargin: 4
            Text {
                text: root.title
                color: root.selected ? "black" : "#5A6E85"
                font.bold: true
                font.pixelSize: 14
            }

            Rectangle {
                implicitWidth: badgeText.implicitWidth + 10
                implicitHeight: 20
                radius: 10
                color: root.selected ? "#5C88F7" : "#DDE4EE"

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: root.count
                    color: root.selected ? "white" : "#5A6E85"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }
        Rectangle {
                   id: underline
                   Layout.preferredWidth: 50
                   Layout.preferredHeight: 3
                   radius: 1.5
                   color: "#2B62ED"
                   visible: root.selected
                   opacity: root.selected ? 1 : 0
                Layout.alignment: Qt.AlignHCenter
                Layout.rightMargin: 20
                   Behavior on opacity { NumberAnimation { duration: 200 } }
               }
    }


    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
