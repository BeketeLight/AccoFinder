import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"

Item {
    id: root

    property string pageTitle: qsTr("Admin Dashboard")
    property bool showHeader: true
    property bool showBack: false

    signal quickActionTriggered(var actionTitle)
    signal usersRequested()
    signal agentsRequested()
    signal propertiesRequested()
    signal approvalsRequested()
    signal bookingsRequested()
    signal paymentsRequested()
    signal disputesRequested()
    signal notificationsRequested()
    signal activityTriggered(var kind)

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: adminPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            AdminsDashboardPage {
                id: adminPage
                x: Math.max(12, (flick.width - width) / 2)
                y: 24
                width: Math.min(flick.width - 24, 520)

                onQuickActionTriggered: (actionTitle) => root.quickActionTriggered(actionTitle)
                onUsersRequested: root.usersRequested()
                onAgentsRequested: root.agentsRequested()
                onPropertiesRequested: root.propertiesRequested()
                onApprovalsRequested: root.approvalsRequested()
                onBookingsRequested: root.bookingsRequested()
                onPaymentsRequested: root.paymentsRequested()
                onDisputesRequested: root.disputesRequested()
                onNotificationsRequested: root.notificationsRequested()
                onActivityTriggered: (kind) => root.activityTriggered(kind)
            }
        }
    }
}
