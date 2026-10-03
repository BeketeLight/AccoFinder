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
    // Header Bar / Filter Selector
    background: Rectangle{
        color: "#F4F6F9"
    }
    header: FilterComponent {
        id: filterBar
        model: ["All", "Pending", "Confirmed", "Cancelled"]
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
            // Correct role mappings matching BookingsModel.qml append() payload:
            activeFilter: {
                    var t = filterBar.currentText
                    if (t === "Approved") return "Confirmed"
                    return t
                }
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
                    bookingId: model.bookingId ?? "",
                    houseName: model.houseName ?? "",
                    imageUrl: model.propertyImage ?? "",
                    status: model.status ?? "",
                    clientName: model.clientName ?? "",
                    clientPhone: model.clientPhone ?? "",
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
    AppSpinner{
        id: loadingSpinner
        anchors.centerIn: parent
        running: agentBookingsModel.loading
        color: "#2563EB"
        size: 36
        z: 100
    }
}