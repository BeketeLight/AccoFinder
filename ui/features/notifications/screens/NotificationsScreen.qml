import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../screens"
import "../../home/components"
import "../../../utils/NavigationUtils.js" as NavUtils
Page{
    id: root
    // anchors.fill: parent
    // ===== HEADER WITH BACK BUTTON =====
header: ToolBar {
    background: Rectangle {
        color: "white"
    }
    contentHeight: 56

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 16

        spacing: 30
        ToolButton{
            display: AbstractButton.TextBesideIcon
                //icon.name: "back-icon"
            icon.source:"qrc:/ui/assets/back-icon.svg"
            icon.height: 24
            icon.width: 24
            icon.color: "black"
            //icon.color: currentIndex === 2 ? "blue" : "black"
            //                background: null
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40

            onClicked: {
                console.log("Back button tapped! Attempting pop...")
                NavUtils.pop()

            }
        }
    }
 }

    ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Label {
                text: "Notifications"
                color: "black"
                font.pixelSize: 20
                font.bold: true
            }

    }
}
