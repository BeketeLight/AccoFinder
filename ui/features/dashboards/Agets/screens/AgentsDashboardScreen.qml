import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"

Item {
    id: root

    property string pageTitle: qsTr("Agent Dashboard")
    property bool showHeader: true
    property bool showBack: true

    signal goBack()
    signal addPropertyRequested()
    signal attentionClicked(var propertyTitle)
    signal bookingClicked()
    signal notificationClicked()
    signal disputeClicked()

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }

        header: ToolBar {
            background: Rectangle { color: "#FFFFFF" }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 16
                spacing: 4

                ToolButton {
                    visible: root.showBack
                    text: qsTr("←")
                    font.pixelSize: 20
                    onClicked: root.goBack()
                }

                Label {
                    Layout.fillWidth: true
                    text: root.pageTitle
                    font.pixelSize: 18
                    font.bold: true
                    color: "#1F2937"
                }
            }
        }

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: dashPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            AgentsDashboardPage {
                id: dashPage
                x: Math.max(12, (flick.width - width) / 2)
                y: 24
                width: Math.min(flick.width - 24, 520)

                onAddPropertyRequested: root.addPropertyRequested()
                onAttentionClicked: (propertyTitle) => root.attentionClicked(propertyTitle)
                onBookingClicked: root.bookingClicked()
                onNotificationClicked: root.notificationClicked()
                onDisputeClicked: root.disputeClicked()
            }
        }
    }
}
