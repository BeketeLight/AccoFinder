import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../models"
import "../components"
import "../../../utils/NavigationUtils.js" as NavUtils

Page{
    id: root
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
    property alias hostEmail: detailDelegate.hostEmail
    property alias hostPhone: detailDelegate.hostPhone
    property alias propertyLocation: detailDelegate.propertyLocation
    property alias propertyImage:detailDelegate.propertyImage
    property alias propertyId: detailDelegate.propertyId
    property alias roomId: detailDelegate.roomId
    property alias roomType: detailDelegate.roomType

    property alias clientName: detailDelegate.clientName
    property alias clientPhone: detailDelegate.clientPhone
    property alias clientEmail: detailDelegate.clientEmail
    property alias clientInitial: detailDelegate.clientInitial

    property alias landlord: detailDelegate.landlord
    property alias landlordPhone: detailDelegate.landlordPhone
    property alias landlordInitials: detailDelegate.landlordInitials
    property alias bookingDate: detailDelegate.bookingDate
    property alias price: detailDelegate.price
    property alias commission: detailDelegate.commission
    property alias paymentStatus: detailDelegate.paymentStatus
    property alias paymentMethod: detailDelegate.paymentMethod
    property alias paymentDate: detailDelegate.paymentDate


    property bool showHeader: true
    property bool showBack: false
    property bool isSearchBar: false
    property bool showBottomBorder: false
    property bool collapsible: false
    property bool transparentHeader: true
    property real scrollY: scrollViewId.contentItem.contentY
    property Component leftComponentAction: Component {
        RowLayout {
            spacing: 12
            ToolButton {
                Layout.leftMargin: 4
                implicitWidth: 28
                implicitHeight: 28
                icon.source: "qrc:/ui/assets/back-icons.svg"
                icon.color: "#111111"
                icon.width: 10
                icon.height: 16
                onClicked: {
                    if (typeof NavUtils !== "undefined")
                        NavUtils.pop()
                }
                background: Rectangle{
                    radius: 14
                    color: "#FFFFFF"
                }
            }
            BookingStatusBadge {
                Layout.alignment: Qt.AlignVCenter
                status: root.status
            }
        }
    }

    ScrollView {
        id: scrollViewId
        anchors.topMargin: 6
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        AdminBookingDetailsDelegate {
            id: detailDelegate
            //anchors.topMargin: 10
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width - 32, 600)
        }
    }
}

