import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
import "../components"
import "../../../utils/NavigationUtils.js" as NavUtils
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
    property alias landlord: detailDelegate.landlord
    property alias landlordInitials: detailDelegate.landlordInitials
    property alias landlordPhone: detailDelegate.landlordPhone
    property alias price: detailDelegate.price
    property alias commission: detailDelegate.commission
    property alias checkIn: detailDelegate.checkIn
    property alias paymentStatus: detailDelegate.paymentStatus
    property alias paymentMethod: detailDelegate.paymentMethod
    property alias paymentDate: detailDelegate.paymentDate
    property bool showBottomBorder: false
    property Component leftComponentAction: Component {
        RowLayout {
            spacing: 4
            ToolButton {
                implicitWidth: 48
                implicitHeight: 48
                icon.source: "qrc:/ui/assets/back-icons.svg"
                icon.color: "#111111"
                icon.width: 10
                icon.height: 16
                onClicked: {
                    if (typeof NavUtils !== "undefined")
                        NavUtils.pop()
                }
            }
            BookingStatusBadge {
                Layout.alignment: Qt.AlignVCenter
                status: root.status
            }
        }
    }
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
