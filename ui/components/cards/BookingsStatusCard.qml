import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Rectangle{
    id: root
    //anchors.fill: parent
    property string  title: "Status"
    property double values: 0
    property string iconSource: ""
    property color iconBgColor: "#2563EB"
    property color cardBgColor: "#FFFFFF"
    property bool isSelected: false
    property real  cardWidth: 0
    property real cardHeight: 0
    //signal
    signal clicked()

    width: cardWidth
    height: cardHeight

    radius: 10
    color: isSelected ? Qt.lighter(cardBgColor, 1.05) : cardBgColor
    border.color : "#FFFFFF"
    border.width: 2
    //animation
    scale: cardMouseArea.pressed ? 0.96 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
    MouseArea{
        id: cardMouseArea
        anchors.fill: root
        onClicked: root.clicked()
    }
    //Alignment in of componenets in cardBgColor:
    ColumnLayout{
        anchors.fill: parent
        anchors.leftMargin: 12
         anchors.rightMargin: 12
        anchors.topMargin: 0
        //anchors.bottomMargin: 10
        spacing: 2

        Rectangle{
            id: iconRect
            width: 34
            height: 34
            radius: 17
            color: "white"//root.iconBgColor
            Layout.alignment: Qt.AlignHCenter
            ToolButton{
                anchors.centerIn: parent
                icon.source: root.iconSource
                icon.height: 24
                icon.width: 24
                icon.color: "#6366F1"
                Layout.alignment: Qt.AlignHCenter
            }
        }
        //card Label
        ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 2

                    Text {
                        text: root.title
                        font.pixelSize: 12
                        color: "#64748B"
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: root.values
                        font.pixelSize: 16
                        font.bold: true
                        color: "#0F172A"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
            }
    }
}
