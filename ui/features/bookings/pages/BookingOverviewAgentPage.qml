import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../../../components/dialogs"
import "../../../components/indicators"
import "../models"
import "../components"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root
    property string  pendingApprovedId: ""
    readonly property bool busy: agentBookingsModel.loading
            || BookingViewModel.isLoading
    // Header Bar / Filter Selector
    background: Rectangle{
        color: "#F4F6F9"
    }
    header: FilterComponent {
        id: filterBar
        model: ["All", "Pending payment", "Confirmed", "Cancelled"]
        onFilterChanged: function(text) {
            agentBookingsModel.statusFilter = text
        }
    }
    BookingsModel {
        id: agentBookingsModel
    }

    ListView {
        id: statsListView
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        clip: true
        visible: !agentBookingsModel.loading
        model: agentBookingsModel.bookingsModel

        delegate: AgentStatsDelegate {
            bookingId: model.bookingId ?? ""
            houseName: model.houseName ?? ""
            imageUrl: model.propertyImage ?? ""
            status: model.status ?? ""
            clientName: model.clientName ?? ""
            clientPhone: model.clientPhone ?? ""
            dateRange: model.bookingDate ?? ""
            propertyLocation: (model.district && model.village) ? (model.district + ", " + model.village) : "N/A"
            roomType: model.roomType ?? ""
            clientEmail: model.clientEmail ?? ""
            clientInitial: model.clientInitial ?? ""
            commission: model.commissionAmount ?? 0.0
            price: model.amount
            onViewDetailsRequested: function(data){
                NavUtils.navigateToBookingsDetailsOwneByAgent({
                    //Data must come from Model to avoid suprises
                    bookingId: model.bookingId ?? "",
                    houseName: model.houseName ?? "",
                    imageUrl: model.propertyImage ?? "",
                    status: model.status ?? "",
                    clientName: model.clientName ?? "",
                    clientPhone: model.clientPhone ?? "",
                    landlord: model.landlord,
                    landlordInitials: model.landlordInitials,
                    landlordPhone: model.landlordPhone,
                    dateRange: model.bookingDate ?? "",
                    price: model.amount ? model.amount.toString() : "0",
                    propertyLocation: (model.district && model.village) ? (model.district + ", " + model.village) : "N/A",
                    roomType: model.roomType ?? "",
                    clientEmail: model.clientEmail ?? "",
                    clientInitial: model.clientInitial ?? "",
                    commission: model.commissionAmount ?? 0.0,
                })
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
        visible: !agentBookingsModel.loading && agentBookingsModel.resultCount === 0
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
        running: agentBookingsModel.loading
        color: "#2563EB"
        size: 36
        z: 100
    }
}