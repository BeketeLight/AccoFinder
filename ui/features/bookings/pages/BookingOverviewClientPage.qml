import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
import "../components"
import "../../../components/indicators"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: overviewPage
    title: "My Bookings"
    background: Rectangle{
        color: "#F8F9FB"
    }
    property bool refreshing: false
    property bool loading: false
    property double _refreshStart: 0
    property int _minVisible: 600

    readonly property bool busy: clientBookingModel.loading
            || BookingViewModel.isLoading

    function refresh() {
            if (overviewPage.refreshing || overviewPage.loading)
                return

            overviewPage._refreshStart = Date.now()
            overviewPage.refreshing = true
            overviewPage.loading = true

            // Same data the model needs for joins
            RoomViewModel.loadRooms()
            PropertyViewModel.getProperties("")
            BookingViewModel.fetchBookings()
            // BookingsModel Connections will call reload() when models update
        }

        function onRequestsSettled() {
            if (overviewPage.busy)
                return

            overviewPage.refreshing = false
            var elapsed = Date.now() - overviewPage._refreshStart
            var remain = overviewPage._minVisible - elapsed
            if (remain > 0) {
                hideLoaderTimer.interval = remain
                hideLoaderTimer.restart()
            } else {
                hideLoaderTimer.stop()
                overviewPage.loading = false
            }
        }

        Timer {
            id: hideLoaderTimer
            interval: overviewPage._minVisible
            repeat: false
            onTriggered: overviewPage.loading = false
        }

        Connections {
            target: BookingViewModel
            function onIsLoadingChanged() { overviewPage.onRequestsSettled() }
        }
        Component.onCompleted: overviewPage.refresh()

    header: FilterComponent {
        id: filterBar
        model: ["All", "Pending payment", "Confirmed", "Cancelled"]
        onFilterChanged: function(text) {
            clientBookingModel.statusFilter = text
        }
    }

    // ---real Model
    BookingsModel {
        id: clientBookingModel
    }
    // Main Listview
    ListView {
        id: statsListView
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        clip: true
        visible: !clientBookingModel.loading
        model: clientBookingModel.bookingsModel

        delegate: ClientStatsDelegate {
            bookingId: model.bookingId ?? ""
            houseName: model.houseName ?? ""
            ownerFirstName: model.ownerFirstName ?? ""
            //propertyImage: model.propertyImage ?? ""
            status: model.status ?? ""
            clientName: model.clientName ?? ""
            clientPhone: model.clientPhone ?? ""
            bookingDate: model.bookingDate ?? ""
            price: model.amount
            propertyLocation: (model.district && model.village) ? (model.district + ", " + model.village) : "N/A"
            propertyId: model.propertyId ?? ""
            roomType: model.roomType ?? ""
            roomId: model.roomId ?? ""
            clientEmail: model.clientEmail ?? ""
            baseAmount: model.amount ?? 0.0
            serviceFee: model.commissionAmount ?? 0.0
            holdExpiresAt: model.holdExpiresAt ?? ""
            // Action Signals
            onRemoveRequested: {
                console.log("Action requested for booking:", model.bookingId)
            }

            onViewDetailsRequested:{
                NavUtils.navigateToBookingsDetailsClient({
                    bookingId: model.bookingId || "",
                    status: model.status || "Pending",
                    houseName: model.houseName || "",
                    ownerFirstName: model.ownerFirstName,
                    hostInitials: model.hostInitials,
                    hostName: model.hostName,
                    propertyImage: model.propertyImage || "",
                    propertyId: model.propertyId || "",
                    propertyLocation: (model.district && model.village)
                        ? (model.district + ", " + model.village)
                        : (model.location || ""),
                    roomType: model.roomType || "",
                    roomId: model.roomId || "",
                    bookingDate: model.bookingDate || "",
                    landlordName: model.landlord || "",
                    landlordPhone: model.landlordPhone || "",
                    paymentStatus: model.paymentStatus || "Unpaid",
                   // price: model.amount,
                    price: Number(model.amount ?? 0),
                    holdExpiresAt: model.holdExpiresAt ?? ""
                });
            }
            // onPayNowRequested:  function(bId, amt, expiresAt){
            //     NavUtils.navigateToPayments(
            //             bId || model.bookingId || "",
            //             amt || model.amount || 0,
            //             expiresAt || model.holdExpiresAt || ""
            //     )
            // }
            onPayNowRequested: function(bId, amt, expiresAt) {
                var id = (bId && String(bId).length) ? String(bId) : String(model.bookingId || "")
                var payAmount = (amt !== undefined && amt !== null && !isNaN(Number(amt)))
                    ? Number(amt)
                    : Number(model.amount || 0)
                var expires = (expiresAt !== undefined && expiresAt !== null && String(expiresAt).length)
                    ? expiresAt
                    : (model.holdExpiresAt || null)

                console.log("navigateToPayments", id, payAmount, expires)

                NavUtils.navigateToPayments(id, payAmount, expires)
            }
        }
    }
    AppEmptyState {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.topMargin: 80
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        visible: !clientBookingModel.loading && clientBookingModel.resultCount === 0
        iconSource: "qrc:/ui/assets/bookings-icon.svg"
        title: {
            switch (String(filterBar.currentText || "All")) {
            case "Pending payment":
                return qsTr("No pending bookings")
            case "Confirmed":
                return qsTr("No confirmed bookings")
            case "Cancelled":
                return qsTr("No cancelled bookings")
            default:
                return qsTr("No bookings yet")
            }
        }
        subtitle: {
            switch (String(filterBar.currentText || "All")) {
            case "Pending payment":
                return qsTr("Bookings waiting for payment will show up here.")
            case "Confirmed":
                return qsTr("Confirmed bookings will appear here after payment succeeds.")
            case "Cancelled":
                return qsTr("Cancelled or expired bookings will appear here.")
            default:
                return qsTr("Book a property to see your bookings here.")
            }
        }
    }
    AppSpinner{
        id: loadingSpinner
        anchors.centerIn: parent
        running: clientBookingModel.loading
        color: "#2563EB"
        size: 36
        z: 50
    }
}