import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
Page{
    id: root
    property alias bookingId: detailDelegate.bookingId
    property alias status: detailDelegate.status
    property alias houseName: detailDelegate.houseName
    property alias propertyLocation: detailDelegate.propertyLocation
    property alias propertyImage:detailDelegate.propertyImage
    property alias roomType: detailDelegate.roomType

    property alias clientName: detailDelegate.clientName
    property alias clientPhone: detailDelegate.clientPhone
    property alias clientEmail: detailDelegate.clientEmail
    property alias clientInitial: detailDelegate.clientInitial
    property alias price: detailDelegate.price
    property alias commission: detailDelegate.commission
    property alias checkIn: detailDelegate.checkIn
    property alias paymentStatus: detailDelegate.paymentStatus
    property alias paymentMethod: detailDelegate.paymentMethod
    property alias paymentDate: detailDelegate.paymentDate
    property string pageTitle: root.houseName

    // Status badge on the right side of AppHeader
        property Component rightComponentAction: Component {
            Item {
                implicitWidth: badge.implicitWidth
                implicitHeight: 36
                Layout.rightMargin: 20

                Rectangle {
                    id: badge
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: statusLabel.implicitWidth + 16
                    implicitHeight: 28
                    radius: 14
                    color: root.status === "Confirmed" ? "#DCFCE7"
                         : root.status === "Pending" ? "#FEF3C7"
                         : root.status === "Cancelled" ? "#FEE2E2"
                         : "#F1F5F9"

                    Text {
                        id: statusLabel
                        anchors.centerIn: parent
                        text: root.status
                        font.pixelSize: 12
                        font.bold: true
                        color: root.status === "Confirmed" ? "#15803D"
                             : root.status === "Pending" ? "#B45309"
                             : root.status === "Cancelled" ? "#B91C1C"
                             : "#475569"
                    }
                }
            }
        }

    //readonly property string createdTime: model.createdTime ?? "Oct 10, 2026 at 10:15 AM"
    //readonly property string paidTime: model.paidTime ?? "Oct 10, 2026 at 10:18 AM"
    //readonly property string approvedTime: model.approvedTime ?? "Oct 11, 2026 at 09:00 AM"

    ScrollView {
        anchors.topMargin: 6
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        AgentBookingDetailsDelegate {
            id: detailDelegate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            width: Math.min(parent.width - 32, 600)

            // onPayNowRequested: {
            //     console.log("Processing payment for booking:", bookingId)
            // }
        }
    }
}
