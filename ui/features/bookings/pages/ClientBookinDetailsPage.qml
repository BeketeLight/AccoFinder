// ClientBookinDetailsPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../components"
import "../../../utils/NavigationUtils.js" as NavUtils

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

    property alias checkIn: detailDelegate.checkIn
    property alias price: detailDelegate.price
    property alias paymentStatus: detailDelegate.paymentStatus
    property alias paymentMethod: detailDelegate.paymentMethod
    property alias paymentDate: detailDelegate.paymentDate
    property alias holdExpiresAt: detailDelegate.holdExpiresAt
    //property string pageTitle: detailPage.status
    property bool showHeader: true
    property bool showBack: false
    property bool isSearchBar: false
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
                status: detailPage.status
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