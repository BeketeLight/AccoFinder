import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../components/inputs"
import "../../../components/navigations"

Item {
    id: root

    property real scrollPosition: 0
    property real maxCollapse: 48

    readonly property real collapseProgress: Math.min(Math.max(scrollPosition / maxCollapse, 0), 1)

    // Fixed numbers → no binding loop.
    readonly property real titleHeight: 48
    readonly property real searchHeight: 48

    readonly property color surfaceColor: "#FFFFFF"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    width: parent ? parent.width : 360
    height: titleHeight * (1 - collapseProgress) + searchHeight

    clip: true

    Rectangle {
        anchors.fill: parent
        color: root.surfaceColor

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: root.borderColor
        }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // ========== TITLE ROW (collapses) ==========
        Item {
            id: titleRow
            width: parent.width
            height: root.titleHeight * (1 - root.collapseProgress)
            clip: true
            opacity: 1 - root.collapseProgress
            visible: height > 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 8
                spacing: 8

                Label {
                    text: qsTr("AccoFinder")
                    color: root.textColor
                    font.pixelSize: 20
                    font.bold: true
                    Layout.fillWidth: true
                }

                AppNotificationBell {
                    notificationScreen: Qt.resolvedUrl("../../notifications/screens/NotificationsScreen.qml")
                }
            }
        }

        // ========== SEARCH BAR (always visible) ==========
        Item {
            width: parent.width
            height: root.searchHeight

            AppSearchBar {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                readOnly: true
                onSearchBarTapped: NavUtils.navigateToSearchScreen()
            }
        }
    }
}
