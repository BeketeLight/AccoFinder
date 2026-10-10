// ClientBookinDetailsPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates" // Adjust path to where ClientBookingDetailDelegate.qml lives
import "../components"
Page {
    id: detailPage
    background: Rectangle{
        color: "#F8F9FB"
    }
    // Forward properties to the inner delegate
    property alias bookingId: detailDelegate.bookingId
    property alias status: detailDelegate.status
    property alias houseName: detailDelegate.houseName
    property alias ownerFirstName: detailDelegate.ownerFirstName
    property alias hostInitials: detailDelegate.hostInitials
    property alias hostName: detailDelegate.hostName
    property alias propertyLocation: detailDelegate.propertyLocation
    property alias propertyImage:detailDelegate.propertyImage
    property alias roomType: detailDelegate.roomType

    property alias clientName: detailDelegate.clientName
    property alias clientPhone: detailDelegate.clientPhone
    property alias clientEmail: detailDelegate.clientEmail
    //readonly property int guestCount: model.guestCount ?? 3

    property alias checkIn: detailDelegate.checkIn
    //property string checkOut:
    //readonly property int nightsCount: model.nightsCount ?? 3
    //readonly property string clientNotes: model.clientNotes ?? "Please provide an extra crib if available. Late check-in expected."
    property alias price: detailDelegate.price
    property alias paymentStatus: detailDelegate.paymentStatus
    property alias paymentMethod: detailDelegate.paymentMethod
    property alias paymentDate: detailDelegate.paymentDate
    property alias holdExpiresAt: detailDelegate.holdExpiresAt
    //----Binding header here
    property string pageTitle: detailPage.status
    property bool showHeader: true
    property bool showBack: true
    property bool isSearchBar: false
    property bool showBottomBorder: true

    // Status badge on the right side of AppHeader
        // property Component rightComponentAction: Component {
        //     Item {
        //         implicitWidth: badge.implicitWidth
        //         implicitHeight: 36
        //         Layout.rightMargin: 20

        //         Rectangle {
        //             id: badge
        //             anchors.verticalCenter: parent.verticalCenter
        //             implicitWidth: statusLabel.implicitWidth + 16
        //             implicitHeight: 28
        //             radius: 14
        //             color: detailPage.status === "Confirmed" ? "#DCFCE7"
        //                  : detailPage.status === "Pending" ? "#FEF3C7"
        //                  : detailPage.status === "Cancelled" ? "#FEE2E2"
        //                  : "#F1F5F9"

        //             Text {
        //                 id: statusLabel
        //                 anchors.centerIn: parent
        //                 text: detailPage.status
        //                 font.pixelSize: 12
        //                 font.bold: true
        //                 color: detailPage.status === "Confirmed" ? "#15803D"
        //                      : detailPage.status === "Pending" ? "#B45309"
        //                      : detailPage.status === "Cancelled" ? "#B91C1C"
        //                      : "#475569"
        //             }
        //         }
        //     }
        // }

    ScrollView {
        anchors.topMargin: 6
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        ClientBookingDetailsDelegate {
            id: detailDelegate
            //anchors.topMargin: 10
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width - 32, 600)

            onPayNowRequested: function(bId, amt, expiresAt) {
                        popUpPayment.bookingId = bId
                        popUpPayment.amount = amt
                        popUpPayment.holdExpiresAt = expiresAt
                        popUpPayment.selectedMethod = "" // Reset previous selection
                       popUpPayment.open() // Pops up the bottom sheet
            }
        }
    }
}