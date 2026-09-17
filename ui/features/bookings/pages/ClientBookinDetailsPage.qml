// ClientBookinDetailsPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates" // Adjust path to where ClientBookingDetailDelegate.qml lives

Page {
    id: detailPage

    // Forward properties to the inner delegate
    property alias bookingId: detailDelegate.bookingId
    property alias status: detailDelegate.status
    property alias statusNote: detailDelegate.statusNote
    property alias houseName: detailDelegate.houseName
    property alias landlordName: detailDelegate.landlordName
    property alias imageUrl: detailDelegate.imageUrl
    property alias checkIn: detailDelegate.checkIn
    property alias checkOut: detailDelegate.checkOut
    property alias specialRequests: detailDelegate.specialRequests
    property alias roomPrice: detailDelegate.roomPrice
    property alias discount: detailDelegate.discount
    property alias paymentStatus: detailDelegate.paymentStatus
    property alias paymentMethod: detailDelegate.paymentMethod
    property alias paymentDate: detailDelegate.paymentDate
    property alias keyInstructions: detailDelegate.keyInstructions
    property alias cancellationPolicy: detailDelegate.cancellationPolicy

    // header: ToolBar {
    //     background: Rectangle { color: "#FFFFFF" }
    //     RowLayout {
    //         anchors.fill: parent
    //         anchors.leftMargin: 8

    //         ToolButton {
    //             text: "‹ Back"
    //             font.bold: true
    //             font.pixelSize: 16
    //             onClicked: NavUtils.pop()
    //         }

    //         Text {
    //             text: "Booking Details"
    //             font.bold: true
    //             font.pixelSize: 16
    //             color: "#0F172A"
    //             Layout.fillWidth: true
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
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width - 32, 600)

            onPayNowRequested: {
                console.log("Processing payment for booking:", bookingId)
            }
        }
    }
}