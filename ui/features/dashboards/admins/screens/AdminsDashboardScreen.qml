import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Admin Dashboard")
    property bool showHeader: true
    property bool showBack: false
    property bool showBottomBorder: false

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
    signal menuRequested()

    property Component rightComponentAction: Component {
        Item {
            implicitWidth: 36
            implicitHeight: 36

            ToolButton {
                anchors.centerIn: parent
                icon.color: "#1F2937"
                icon.height: 24
                icon.width: 24
                icon.source: "qrc:/ui/assets/notification.svg"
                onClicked: NavUtils.push("../features/dashboards/admins/screens/SystemNotificationsScreen.qml")
            }
        }
    }

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
                y: 20
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
