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

    //----Binding header here
    property string pageTitle: detailPage.bookingId
    property bool showHeader: true
    property bool showBack: true
    property bool isSearchBar: false
    property bool showBottomBorder: true

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
                    color: detailPage.status === "Approved" ? "#DCFCE7"
                         : detailPage.status === "Pending" ? "#FEF3C7"
                         : detailPage.status === "Cancelled" ? "#FEE2E2"
                         : "#F1F5F9"

                    Text {
                        id: statusLabel
                        anchors.centerIn: parent
                        text: detailPage.status
                        font.pixelSize: 12
                        font.bold: true
                        color: detailPage.status === "Approved" ? "#15803D"
                             : detailPage.status === "Pending" ? "#B45309"
                             : detailPage.status === "Cancelled" ? "#B91C1C"
                             : "#475569"
                    }
                }
            }
        }

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