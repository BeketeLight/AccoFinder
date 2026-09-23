import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
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
                text: "View all"
                width: implicitWidth
            }
            TabButton {
                text: "Approved"
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
        }
    }

    // --- UNIFIED DUMMY MODEL ---
    BookingModel {
        id: bookingModel
    }

    // --- MAIN LIST VIEW ---
    ListView {
        id: statsListView
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        clip: true

        model: bookingModel

        delegate: ClientStatsDelegate {
            // Map Model Roles -> Delegate Properties
            bookingId: model.bookingId
            status: model.status
            landlordName: model.landlordName
            houseName: model.houseName
            imageUrl: model.imageUrl ? model.imageUrl : ""
            dates: model.checkIn
            details: "Standard Reservation"
            totalPrice: "MWK" + (model.roomPrice - model.discount).toFixed(2)


            // Dynamic filter binding tied to active tab text
            activeFilter: filterTabBar.currentItem ? filterTabBar.currentItem.text : "View all"

            // Action Signals
            onRemoveRequested: {
                console.log("Action requested for booking:", model.bookingId)
            }

            onViewDetailsRequested: {
                NavUtils.navigateToBookingsDetailsClient({
                    "bookingId": model.bookingId,
                    "status": model.status,
                    "statusNote": model.statusNote,
                    "houseName": model.houseName,
                    "landlordName": model.landlordName,
                    "imageUrl": model.imageUrl ? model.imageUrl : "",
                    "checkIn": model.checkIn,
                    "checkOut": model.checkOut,
                    "specialRequests": model.specialRequests ? model.specialRequests : "",
                    "roomPrice": model.roomPrice,
                    "discount": model.discount,
                    "paymentStatus": model.paymentStatus,
                    "paymentMethod": model.paymentMethod ? model.paymentMethod : "",
                    "paymentDate": model.paymentDate ? model.paymentDate : "",
                    "keyInstructions": model.keyInstructions ? model.keyInstructions : "",
                    "cancellationPolicy": model.cancellationPolicy
                });
            }
        }
    }
}