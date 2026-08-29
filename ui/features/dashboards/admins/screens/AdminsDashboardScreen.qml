import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../components/indicators"
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

    property bool refreshing: false

    // True while any of the dashboard's backing requests are in flight, so a
    // loading indicator is shown instead of a blank screen.
    readonly property bool loading: DashboardController.isLoading || PropertyViewModel.isLoading

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

    property bool pullArmed: false

    function armIfPulled() {
        if (flick.dragging && flick.contentY <= -56)
            root.pullArmed = true
    }

    function handlePullRelease() {
        if (root.pullArmed && !root.refreshing) {
            root.refresh()
            flick.returnToBounds()
        }
        root.pullArmed = false
    }

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
                onClicked: NavUtils.push(Qt.resolvedUrl("../../../notifications/screens/NotificationsScreen.qml"))
            }

            // Unread badge: a small circle in the top-right corner showing the
            // number of unread notifications for the logged-in admin.
            Rectangle {
                visible: NotificationViewModel.notificationListModel.unreadCount > 0
                width: 16
                height: 16
                radius: 8
                anchors.top: parent.top
                anchors.right: parent.right
                color: "#DC2626"
                border.color: "#FFFFFF"
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: NotificationViewModel.notificationListModel.unreadCount > 99
                          ? "99+"
                          : String(NotificationViewModel.notificationListModel.unreadCount)
                    color: "#FFFFFF"
                    font.pixelSize: 9
                    font.bold: true
                }
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

            onContentYChanged: root.armIfPulled()
            onDragEnded: root.handlePullRelease()

            // Pull-to-refresh indicator: a small strip shown at the top while
            // the content is dragged down (or while a refresh is running).
            ColumnLayout {
                id: pullIndicator
                z: 10
                anchors.horizontalCenter: parent.horizontalCenter
                y: -40 + Math.abs(Math.min(0, flick.contentY))
                spacing: 4
                visible: root.refreshing || flick.contentY < -2
                opacity: Math.min(1, Math.abs(Math.min(0, flick.contentY)) / 56)

                AppSpinner {
                    Layout.alignment: Qt.AlignHCenter
                    size: 20
                    lineWidth: 2
                    color: "#9CA3AF"
                    running: root.refreshing
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.refreshing ? qsTr("Refreshing…") : qsTr("Pull to refresh")
                    color: "#9CA3AF"
                    font.pixelSize: 11
                }
            }

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

        // Loading indicator: a small, non-blocking spinner centered on the page
        // so the user knows a request is in flight without blocking navigation.
        AppSpinner {
            visible: root.loading
            anchors.centerIn: parent
            z: 20
            size: 32
            lineWidth: 3
            color: "#2563EB"
            running: root.loading
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
