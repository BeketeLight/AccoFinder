import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../components/inputs"

Item {
    id: root

    property real scrollPosition: 0
    property real maxCollapse: 48

    readonly property real collapseProgress: Math.min(Math.max(scrollPosition / maxCollapse, 0), 1)

    // Fixed numbers → no binding loop
    readonly property real titleHeight: 48
    readonly property real searchHeight: 48

    width: parent ? parent.width : 360
    height: titleHeight * (1 - collapseProgress) + searchHeight

    clip: true

    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // ========== TITLE ROW ==========
        Item {
            id: titleRow
            width: parent.width
            height: root.titleHeight * (1 - root.collapseProgress)
            clip: true
            opacity: 1 - root.collapseProgress
            visible: height > 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                Label {
                    text: "AccoFinder"
                    color: "#1F2937"
                    font.pixelSize: 20
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Image {
                    source: "qrc:/ui/assets/notification.svg"
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    sourceSize.width: 48
                    sourceSize.height: 48
                    fillMode: Image.PreserveAspectFit
                    antialiasing: true
                    smooth: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: NavUtils.navigateToNotifications()
                    }
                }
            }
        }

        // ========== SEARCH BAR ==========
        Item {
            width: parent.width
            height: root.searchHeight

            AppSearchBar {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 12
            }
        }
    }
}
