import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
import "../../../components/indicators"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: overviewPage
    title: "My Bookings"

    //--- TOOLBAR & TABBAR HEADER ---
    header: ColumnLayout {
        spacing: 0

        // Top Toolbar Title
        ToolBar {
            Layout.fillWidth: true
            background: Rectangle { color: "#FFFFFF" }

            // RowLayout {
            //     anchors.fill: parent
            //     anchors.leftMargin: 16
            //     anchors.rightMargin: 16

            //     Text {
            //         text: "My Bookings"
            //         font.bold: true
            //         font.pixelSize: 18
            //         color: "#0F172A"
            //         Layout.fillWidth: true
            //     }
            // }
        }

        // Status Filter Tabs
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

            TabButton {
                text: "All"
                width: implicitWidth
            }
            TabButton {
                text: "Confirmed"  //approved
                width: implicitWidth
            }
            TabButton {
                text: "Pending"
                width: implicitWidth
            }
            TabButton {
                text: "Cancelled"
                width: implicitWidth
            }
            onCurrentIndexChanged: {
                if (!currentItem)
                    return
                var t = currentItem.text
                // Map UI label → model statusFilter
                if (t === "Approved")
                    t = "Confirmed"
                clientBookingModel.statusFilter = t
            }
        }
    }

    // ---real Model
    BookingsModel {
        id: clientBookingModel
    }

    // --- MAIN LIST VIEW ---
    ListView {
        id: statsListView
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        clip: true
        visible: !clientBookingModel.loading
        model: clientBookingModel.bookingsModel

        delegate: ClientStatsDelegate {
            activeFilter: {
                    var t = filterTabBar.currentItem ? filterTabBar.currentItem.text : "All"
                    if (t === "Approved") return "Confirmed"
                    return t
                }
            // Map Model Roles -> Delegate Properties
            bookingId: model.bookingId ?? ""
            houseName: model.houseName ?? ""
            ownerFirstName: model.ownerFirstName ?? ""
            imageUrl: model.propertyImage ?? ""
            status: model.status ?? ""
            clientName: model.clientName ?? ""
            clientPhone: model.clientPhone ?? ""
            dateRange: model.bookingDate ?? ""
            price: model.amount
            propertyLocation: (model.district && model.village) ? (model.district + ", " + model.village) : "N/A"
            roomType: model.roomType ?? ""
            clientEmail: model.clientEmail ?? ""
            baseAmount: model.amount ?? 0.0
            serviceFee: model.commissionAmount ?? 0.0

            // Dynamic filter binding tied to active tab text
            // activeFilter: filterTabBar.currentItem ? filterTabBar.currentItem.text : "All"

            // Action Signals
            onRemoveRequested: {
                console.log("Action requested for booking:", model.bookingId)
            }

            onViewDetailsRequested: {
                NavUtils.navigateToBookingsDetailsClient({
                    bookingId: model.bookingId || "",
                    status: model.status || "Pending",
                    houseName: model.houseName || "",
                    ownerFirstName: model.ownerFirstName,
                    hostInitials: model.hostInitials,
                    hostName: model.hostName,
                    propertyImage: model.propertyImage || "",
                    propertyLocation: (model.district && model.village)
                        ? (model.district + ", " + model.village)
                        : (model.location || ""),
                    roomType: model.roomType || "",
                    checkIn: model.bookingDate || "",
                    landlordName: model.landlord || "",
                    landlordPhone: model.landlordPhone || "",
                    paymentStatus: model.paymentStatus || "Unpaid",
                    price: model.amount
                });
            }
        }
    }
    AppSpinner{
        id: loadingSpinner
        anchors.centerIn: parent
        running: clientBookingModel.loading
        color: "#2563EB"
        size: 36
        z: 100
    }
}