import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../components/pages"
import "../../../../components/navigations"

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

    property bool refreshing: false

    // True while any of the dashboard's backing requests are in flight, so a
    // loading indicator is shown instead of a blank screen.
    readonly property bool loading: DashboardController.isLoading || PropertyViewModel.isLoading

    // Header bell: opens the account-level notification list so announcements
    // broadcast to ALL are visible from the admin dashboard too.
    property Component rightComponentAction: Component {
        AppNotificationBell {
            notificationScreen: Qt.resolvedUrl("../../notifications/screens/NotificationsScreen.qml")
        }
    }

    // Re-fetch dashboard data from the C++ view models so the cards reflect
    // the latest API state. Result flows back through the view-model signals.
    function refresh() {
        if (root.refreshing)
            return
        root.refreshing = true
        DashboardController.refreshStats()
        PropertyViewModel.getProperties()
        RoomViewModel.loadRooms()
        BookingViewModel.fetchBookings()
        NotificationViewModel.getNotifications()
        DisputesListViewModel.getDisputes()
    }

    AppScrollablePage {
        anchors.fill: parent
        pullEnabled: true
        refreshing: root.refreshing
        loading: root.loading
        contentTopMargin: 20
        onRefreshRequested: root.refresh()

        AdminsDashboardPage {
            id: adminPage
            Layout.fillWidth: true

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

    Component.onCompleted: {
        root.refresh()
    }

    Connections {
        target: DashboardController
        function onStatsUpdated() {
            root.refreshing = false
        }
    }

    Connections {
        target: PropertyViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshing = false
        }
    }
}
