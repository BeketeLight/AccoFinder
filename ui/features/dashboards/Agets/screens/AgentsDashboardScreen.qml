import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../components/pages"
import "../../../../components/navigations"
import "../../../../utils/Utils.js" as Utils
import "../pages"

Item {
    id: root

    property string pageTitle: qsTr("Agent Dashboard")
    property bool showHeader: true
    property bool showBack: true

    // Header bell (mirrors the admin dashboard): opens the account-level
    // notification list scoped to the viewer's role, so an agent sees
    // agent-addressed notifications and an admin using this dashboard sees
    // admin-targeted ones (never an empty AGENT-filtered feed).
    property Component rightComponentAction: Component {
        AppNotificationBell {
            notificationScreen: Qt.resolvedUrl("../../../notifications/screens/NotificationsScreen.qml")
            notificationRole: Utils.notificationRoleForViewer()
        }
    }

    signal goBack()
    signal addPropertyRequested()
    signal attentionClicked(var kind, var targetId)
    signal bookingClicked()
    signal notificationClicked()
    signal disputeClicked()

    // Drives the centered loader. Set true whenever a backend request starts
    // (page entry or pull-to-refresh) and cleared once the requests finish but
    // held for a minimum visible time so the loader is always noticeable.
    property bool loading: false
    property bool refreshing: false
    property double _refreshStart: 0
    property int _minVisible: 600

    // Request activity: true while the dashboard's backing requests are in
    // flight. Used to know when everything has completed.
    readonly property bool busy: PropertyViewModel.isLoading
                                 || RoomViewModel.isLoading
                                 || BookingViewModel.isLoading
                                 || DisputesListViewModel.isLoading

    Timer {
        id: hideLoaderTimer
        interval: root._minVisible
        repeat: false
        onTriggered: root.loading = false
    }

    function refresh() {
        if (root.refreshing || root.loading)
            return
        root._refreshStart = Date.now()
        root.refreshing = true
        root.loading = true
        dashPage.dashboardModel.refreshAll()
        AgentViewModel.getMyCommission()
    }

    // Called from each view model's onIsLoadingChanged once nothing is in
    // flight: clear the loader but only after the minimum visible time.
    function onRequestsSettled() {
        if (root.busy)
            return
        root.refreshing = false
        var elapsed = Date.now() - root._refreshStart
        var remain = root._minVisible - elapsed
        if (remain > 0) {
            hideLoaderTimer.interval = remain
            hideLoaderTimer.restart()
        } else {
            hideLoaderTimer.stop()
            root.loading = false
        }
    }

    AppScrollablePage {
        anchors.fill: parent
        pullEnabled: true
        refreshing: root.refreshing
        loading: root.loading || root.refreshing
        onRefreshRequested: root.refresh()

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

        AgentsDashboardPage {
            id: dashPage
            Layout.fillWidth: true

            onAddPropertyRequested: root.addPropertyRequested()
            onAttentionClicked: (kind, targetId) => root.attentionClicked(kind, targetId)
            onBookingClicked: root.bookingClicked()
            onNotificationClicked: root.notificationClicked()
            onDisputeClicked: root.disputeClicked()
        }
    }

    // Fetch fresh data on entry. The centered loader is shown immediately and
    // held for a minimum duration so it is always visible.
    Component.onCompleted: root.refresh()

    Connections {
        target: PropertyViewModel
        function onIsLoadingChanged(loading) { root.onRequestsSettled() }
    }

    Connections {
        target: RoomViewModel
        function onIsLoadingChanged(loading) { root.onRequestsSettled() }
    }

    Connections {
        target: BookingViewModel
        function onIsLoadingChanged(loading) { root.onRequestsSettled() }
    }

    Connections {
        target: DisputesListViewModel
        function onIsLoadingChanged(loading) { root.onRequestsSettled() }
    }
}