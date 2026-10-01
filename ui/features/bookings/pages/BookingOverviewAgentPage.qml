import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../../../components/dialogs"
import "../../../components/indicators"
import "../models"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root
    property string  pendingApprovedId: ""
    // Header Bar / Filter Selector
    header: RowLayout {
        TabBar {
            id: filterTabBar
            Layout.fillWidth: true
            background: Rectangle {
                color: "#FFFFFF"
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#E2E8F0"
                }
            }
            TabButton { text: "All" }        // <-- Change "View all" to "All"
            TabButton { text: "Pending" }
            TabButton { text: "Confirmed" }  // <-- Change "Approved" to "Confirmed"
            TabButton { text: "Cancelled" }

            onCurrentIndexChanged: {
                if (currentItem) {
                    agentBookingsModel.statusFilter = currentItem.text
                }
            }
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
                    var t = filterTabBar.currentItem ? filterTabBar.currentItem.text : "All"
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