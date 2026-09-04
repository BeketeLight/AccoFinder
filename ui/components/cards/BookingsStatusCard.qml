import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Rectangle{
    id: root

    property string  title: "Status"
    property double values: 0
    property string iconSource: ""
    property color iconBgColor: "#2563EB"
    property color cardBgColor: "#F8FAFC"
    property bool isSelected: false

    //signal
    signal clicked()

    implicitWidth: 150
    implicitHeight: 96
    radius: 10
    color: isSelected ? Qt.lighter(cardBgColor, 1.05) : cardBgColor
    border.color : "#06B6D4"
    border.width: 1
    //animation
    scale: cardMouseArea.pressed ? 0.96 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
    MouseArea{
        id: cardMouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
    //Alignment in of componenets in cardBgColor:
    RowLayout{
        anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 12

        Rectangle{
            id: iconRect
            width: 34
            height: 34
            radius: 17
            color: root.iconBgColor
            Layout.alignment: Qt.AlignHCenter
            ToolButton{
                anchors.centerIn: parent
                icon.source: root.iconSource
                icon.height: 16
                icon.width: 16
            }
        }
        //card Label
        ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        text: root.title
                        font.pixelSize: 12
                        color: "#64748B"
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.values
                        font.pixelSize: 16
                        font.bold: true
                        color: "#0F172A"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
    }
}
