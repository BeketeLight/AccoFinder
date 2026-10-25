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
    property alias propertyId: detailDelegate.propertyId
    property alias roomType: detailDelegate.roomType
    property alias roomId: detailDelegate.roomId
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
    //property bool showBottomBorder: false
    property bool mediaRequestStarted: false

    property bool showHeader: true
    property bool showBack: false
    property bool isSearchBar: false
    property bool showBottomBorder: false
    property bool collapsible: false
    property bool transparentHeader: true
    property real scrollY: scrollViewId.contentItem.contentY

    //Pick url from Media using propertyId
    //if it matches pick booked image
    //if not booked image then Primary one
    function coverImageFor(propertyId, roomId) {
        if (!propertyId || typeof MediaViewModel === "undefined")
            return ""

        var list = MediaViewModel.mediaForProperty(propertyId)

        if (!list || list.length === 0) {
            console.log("No media available for property:", propertyId)
            return ""
        }

        // 1. Prefer the image belonging to the booked room.
        if (roomId) {
            var want = String(roomId).trim()

            for (var i = 0; i < list.length; i++) {
                var mRoom = String(
                    list[i].roomId !== null ? list[i].roomId : ""
                ).trim()

                var url = list[i].url || list[i].path || ""

                if (mRoom.length > 0 &&
                    mRoom !== "-1" &&
                    mRoom === want &&
                    url) {
                    return url
                }
            }
        }

        // 2. Fall back to the primary image.
        for (var j = 0; j < list.length; j++) {
            if (list[j].isPrimary) {
                var primaryUrl = list[j].url || list[j].path || ""
                if (primaryUrl)
                    return primaryUrl
            }
        }

        // 3. Fall back to property-level media.
        for (var k = 0; k < list.length; k++) {
            var rid = String(
                list[k].roomId !== null ? list[k].roomId : ""
            ).trim()

            if (rid === "" || rid === "-1") {
                var propertyUrl = list[k].url || list[k].path || ""
                if (propertyUrl)
                    return propertyUrl
            }
        }

        // 4. Final fallback: first available image.
        return list[0].url || list[0].path || ""
    }

    //Calls CoverImageFor function
    //Sets then sets propertyimage
    function applyCoverImage() {
        var pid = resolvePropertyId()
        var rid = String(detailDelegate.roomId || "").trim()

        if (!pid.length) {
            console.log("Cannot load image: property ID is empty")
            return
        }

        var imageUrl = coverImageFor(pid, rid)

        if (imageUrl.length > 0) {
            detailDelegate.propertyImage = imageUrl
            console.log("Selected property image:", imageUrl)
        } else {
            console.log("No image available yet for property:", pid)
        }
    }

    //Get propertyId from the Page
    //if not passed
    function resolvePropertyId() {
        if (propertyId.length > 0)
            return propertyId

        var rid = String(detailDelegate.roomId || "").trim()
        if (!rid.length)
            return ""

        var room = RoomViewModel.getRoomById(rid) || {}

        // Support either a string propertyId or an object containing _id.
        var pid = room.propertyId || ""

        if (typeof pid === "object")
            pid = pid._id || pid.id || ""

        return String(pid)
    }


    //Resolves property Id by calling MediaRequest
    //Then calls applyCoverImage for cach
    function requestPropertyMedia() {
        var pid = resolvePropertyId()

        console.log("Booking ID:", bookingId)
        console.log("Room ID:", roomId)
        console.log("Property ID:", pid)

        if (!pid.length) {
            console.warn("Property ID is empty; cannot request media")
            return
        }
        // 1) Paint immediately from MediaListModel if already loaded
        applyCoverImage()
        if (detailDelegate.propertyImage.length > 0) {
            console.log("Image from media cache:", detailDelegate.propertyImage)
            return   // optional: still refresh in background if you want
        }

        // 2) Miss → network once
        if (!mediaRequestStarted) {
            mediaRequestStarted = true
            console.log("Media cache miss, fetching:", pid)
            MediaViewModel.getMediaByProperty(pid)
        }

        // Use cached media if it already exists.
       root.applyCoverImage()
    }

    Component.onCompleted: { requestPropertyMedia()}

    Connections {
        target: MediaViewModel.mediaListModel

        function onRowsInserted() { root.applyCoverImage()}
        function onModelReset()   { root.applyCoverImage()}
        function onDataChanged()  { root.applyCoverImage()}
        function onCountChanged() { root.applyCoverImage()}
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
        id: scrollViewId
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

            onReleaseRequested: releaseDialog.open()

            // onPayNowRequested: {
            //     console.log("Processing payment for booking:", bookingId)
            // }
        }
    }

    // Refunding frees the room, so require a deliberate confirmation before the
    // release call goes out.
    Dialog {
        id: releaseDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent ? parent.width - 40 : 320, 340)
        title: qsTr("Refund & relist room")

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("This refunds the client and returns the room to the market so it can be booked again. This cannot be undone.")
                color: "#64748B"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    onClicked: releaseDialog.reject()
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Refund & relist")
                    onClicked: {
                        if (String(root.bookingId).length > 0)
                            BookingController.releaseBooking(root.bookingId)
                        releaseDialog.accept()
                    }
                }
            }
        }
    }
}
