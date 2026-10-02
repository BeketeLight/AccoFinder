import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/pages"

Item {
    id: root

    property string pageTitle: qsTr("Bookings")
    property bool showHeader: true
    // Pushed on top of the dashboard, so the header shows a back arrow.
    property bool showBack: true
    property bool showBottomBorder: true
    property int titleFontSize: 15

    function goBack() { NavUtils.pop() }

    signal bookingAction(var action, var bookingId)

    // True while a full re-fetch of the booking list is running (e.g. on
    // pull-to-refresh). Drives the pull-to-refresh strip in AppScrollablePage.
    property bool refreshing: false

    function refresh() {
        if (root.refreshing)
            return
        root.refreshing = true
        BookingViewModel.fetchBookings()
    }

    AppScrollablePage {
        anchors.fill: parent
        pullEnabled: true
        refreshing: root.refreshing
        onRefreshRequested: root.refresh()

        // Only show the centered spinner when there is no data on screen yet,
        // so role/pull refreshes do not flash over a populated list.
        loading: BookingViewModel.isLoading && page.bookingsModel.totalCount === 0

        AdminBookingsPage {
            id: page
            Layout.fillWidth: true
            onBookingAction: (action, bookingId) => root.bookingAction(action, bookingId)
        }
    }

    Connections {
        target: BookingViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshing = false
        }
    }

    Component.onCompleted: {
        // Seed the list from the shared model first, so the screen is useful
        // even before the network round-trip lands.
        page.bookingsModel.reload()
        root.refresh()
    }
}
