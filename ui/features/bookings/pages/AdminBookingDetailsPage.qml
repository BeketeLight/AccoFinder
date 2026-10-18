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

    // Identity of what was booked, used below to pull the room's photo when the
    // caller opened this page without an image (the admin bookings list has
    // no media column).
    property string propertyId: ""
    property string roomId: ""

    // Prefers the photo of the exact room that was booked, then the property's
    // primary photo, then any photo at all. Reads whatever the shared media
    // model already holds; never fetches on its own.
    function resolveCoverImage() {
        if (root.propertyImage.length > 0 || root.propertyId.length === 0)
            return
        var list = MediaViewModel.mediaForProperty(root.propertyId) || []
        if (list.length === 0)
            return

        var primaryUrl = ""
        var anyUrl = ""
        for (var i = 0; i < list.length; i++) {
            var url = String(list[i].url || list[i].path || "")
            if (url.length === 0)
                continue
            var mediaRoomId = (list[i].roomId !== undefined && list[i].roomId !== null)
                ? String(list[i].roomId) : ""
            if (root.roomId.length > 0 && mediaRoomId === root.roomId) {
                root.propertyImage = url
                return
            }
            if (primaryUrl.length === 0 && list[i].isPrimary)
                primaryUrl = url
            if (anyUrl.length === 0)
                anyUrl = url
        }
        root.propertyImage = primaryUrl.length > 0 ? primaryUrl : anyUrl
    }

    function requestCoverImage() {
        if (root.propertyImage.length > 0 || root.propertyId.length === 0)
            return
        MediaViewModel.getMediaByProperty(root.propertyId)
    }

    Component.onCompleted: {
        root.resolveCoverImage()
        root.requestCoverImage()
    }

    // The fetch above is async: apply the photo as soon as rows land.
    Connections {
        target: MediaViewModel.mediaListModel
        function onCountChanged() { root.resolveCoverImage() }
    }

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
