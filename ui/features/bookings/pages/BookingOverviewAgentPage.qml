import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

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
    Component.onCompleted: {
        if (typeof BookingViewModel !== "undefined" && BookingViewModel.fetchBookings) {
            console.log("Fetching bookings")
            BookingViewModel.fetchBookings()
        }
    }

    ListView {
        id: statsListView
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        clip: true
        model: agentBookingsModel.bookingsModel

        delegate: AgentStatsDelegate {
            // Correct role mappings matching BookingsModel.qml append() payload:
            bookingId: model.bookingId ?? ""
            houseName: model.houseName ?? ""
            imageUrl: model.propertyImage ?? ""
            status: model.status ?? ""
            clientName: model.clientName ?? ""
            clientPhone: model.clientPhone ?? ""
            dateRange: model.bookingDate ?? ""
            price: model.amount ? model.amount.toString() : "0"
            propertyLocation: (model.district && model.village) ? (model.district + ", " + model.village) : "N/A"
            roomType: model.roomType ?? ""
            clientEmail: model.clientEmail ?? ""
            baseAmount: model.amount ?? 0.0
            serviceFee: model.commissionAmount ?? 0.0

            onDetailsRequested: function(data) {
                console.log("Details data:", JSON.stringify(data))
                NavUtils.navigateToBookingsDetailsOwneByAgent(data)
            }
        }
    }
}