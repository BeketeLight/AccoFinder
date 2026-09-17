import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
import "../../../utils/NavigationUtils.js" as NavUtils
Page{
    id: root

    // Header Bar / Filter Selector
    header: RowLayout{
        TabBar {
            id: filterTabBar
            Layout.fillWidth: true
            background: Rectangle{
                color: "#FFFFFF"
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#E2E8F0"
                }
            }
            TabButton { text: "View all" }
            TabButton { text: "Pending" }
            TabButton { text: "Approved" }
            TabButton { text: "Rejected" }
        }
    }

    BookingModel{
        id: agentBookingsModel
    }
    // ListView Binding
    ListView {
        //d: listView
        id: statsListView
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        clip: true
        model: agentBookingsModel

        delegate: AgentStatsDelegate {
            bookingId: model.bookingId ?? ""
            houseName: model.houseName ?? ""
            imageUrl: model.imageUrl
            status: model.status ?? ""
            clientName: model.clientName ?? ""
            clientPhone: model.clientPhone ?? ""
            dateRange: model.checkIn ?? ""
            price: model.roomPrice ?? ""
            propertyLocation: model.propertyLocation ?? ""
                roomType: model.roomType ?? ""
                clientEmail: model.clientEmail ?? ""
                guestCount: model.guestCount ?? 0
                checkOut: model.checkOut ?? ""
                nightsCount: model.nightsCount ?? 0
                clientNotes: model.clientNotes ?? ""
                baseAmount: model.baseAmount ?? ""
                serviceFee: model.serviceFee ?? ""
                paymentStatus: model.paymentStatus ?? ""
                paymentMethod: model.paymentMethod ?? ""
                paymentDate: model.paymentDate ?? ""
            activeFilter: filterTabBar.currentItem ? filterTabBar.currentItem.text : "View all"

            onDetailsRequested: function(data){
                console.log("Details data:", JSON.stringify(data))
                NavUtils.navigateToBookingsDetailsOwneByAgent(data)
            }
        }
    }
}
