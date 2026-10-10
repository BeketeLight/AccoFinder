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

    //--- TOOLBAR & TABBAR HEADER ---
    header: FilterComponent {
        id: filterBar
        model: ["All", "Pending Payment", "Confirmed", "Cancelled"]
        onFilterChanged: function(text) {
            clientBookingModel.statusFilter = text
        }
    }

    // ---real Model
    BookingsModel {
        id: clientBookingModel
    }
    // PopUpPaymentSheet{
    //     id: popUpPayment
    //     onPaymentSubmitted: function(bookingId, amount, method) {
    //             console.log("Processing payment for booking:", bookingId, "via:", method)
    //             // Call your payment controller here:
    //             PaymentController.processPayment(bookingId, amount, method)
    //         }
    // }
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
            // activeFilter: {
            //         var t = filterBar.currentText
            //         if (t === "Approved") return "Confirmed"
            //         return t
            //     }
            // Map Model Roles -> Delegate Properties
            // onPayNowRequested: function(bId, amt, expiresAt) {
            //             popUpPayment.bookingId = bId
            //             popUpPayment.amount = amt
            //             popUpPayment.holdExpiresAt = expiresAt
            //             popUpPayment.selectedMethod = "" // Reset previous selection
            //            popUpPayment.open() // Pops up the bottom sheet
            //         }
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
            holdExpiresAt: model.holdExpiresAt ?? ""

            // Dynamic filter binding tied to active tab text
            // activeFilter: filterTabBar.currentItem ? filterTabBar.currentItem.text : "All"

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
                    propertyLocation: (model.district && model.village)
                        ? (model.district + ", " + model.village)
                        : (model.location || ""),
                    roomType: model.roomType || "",
                    checkIn: model.bookingDate || "",
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
    AppSpinner{
        id: loadingSpinner
        anchors.centerIn: parent
        running: clientBookingModel.loading
        color: "#2563EB"
        size: 36
        z: 100
    }
}