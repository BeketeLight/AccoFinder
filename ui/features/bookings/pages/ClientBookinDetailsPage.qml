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
    // Component.onCompleted: {
    //     console.warn("1. DETAILS PAGE INITIALIZED")

    //     console.warn("2. Booking ID:", detailDelegate.bookingId)
    //     console.warn("3. Room ID:", detailDelegate.roomId)
    //     console.warn("4. Property ID passed:", propertyId)

    //     var pid = resolvePropertyId()

    //     console.warn("5. Resolved property ID:", pid)

    //     if (pid.length > 0) {
    //         propertyId = pid

    //         console.warn("6. Requesting media for:", pid)

    //         var media = MediaViewModel.mediaForProperty(pid)

    //         console.warn(
    //             "7. Media currently available:",
    //             media ? media.length : "undefined"
    //         )

    //         MediaViewModel.getMediaByProperty(pid)

    //         console.warn("8. Media request invoked")
    //     } else {
    //         console.warn(
    //             "ERROR: Property ID is empty; media request skipped"
    //         )
    //     }
    // }
    // Forward properties to the inner delegate
    property alias bookingId: detailDelegate.bookingId
    property alias status: detailDelegate.status
    property alias houseName: detailDelegate.houseName
    property alias ownerFirstName: detailDelegate.ownerFirstName
    property alias hostInitials: detailDelegate.hostInitials
    property alias hostName: detailDelegate.hostName
    property alias propertyLocation: detailDelegate.propertyLocation
    property alias propertyImage:detailDelegate.propertyImage
    property alias propertyId: detailDelegate.propertyId
    property alias roomType: detailDelegate.roomType
    property alias roomId: detailDelegate.roomId
    property alias clientName: detailDelegate.clientName
    property alias clientPhone: detailDelegate.clientPhone
    property alias clientEmail: detailDelegate.clientEmail

    property alias bookingDate: detailDelegate.bookingDate
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
    property bool collapsible: false
    property bool transparentHeader: true
    property real scrollY: scrollViewId.contentItem.contentY
    property bool mediaRequestStarted: false

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
       detailPage.applyCoverImage()
    }



    Component.onCompleted: { requestPropertyMedia()}

    Connections {
        target: MediaViewModel.mediaListModel

        function onRowsInserted() { detailPage.applyCoverImage()}
        function onModelReset()   { detailPage.applyCoverImage()}
        function onDataChanged()  { detailPage.applyCoverImage()}
        function onCountChanged() { detailPage.applyCoverImage()}
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
                status: detailPage.status
            }
        }
    }

    ScrollView {
        id: scrollViewId
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