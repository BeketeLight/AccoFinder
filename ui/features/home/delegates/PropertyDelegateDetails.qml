import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../components/inputs"
import "../components/"
import "../../properties/components"
import "../models"
import "../../reviews/screens"
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../utils/ImageUtils.js" as ImageUtils
import "../../../utils/Utils.js" as Utils

Page {
    id: root

    // ========== HEADER CONTROL ==========
    property string pageTitle: ""
    property bool isSearchBar: true
    property bool showBack: true
    property bool showHeader: true
    property bool searchReadOnly: false

    // ========== PROPERTY DATA (from navigation) ==========
    property string propertyId: ""
    property bool favouriteChecked: false
    property string propertyTitle: ""
    property string propertyType: ""
    property string location: ""
    property real price: 0
    property string status: ""
    property bool isVerified: true
    property string description: ""
    property int bedrooms: 0
    property int bathrooms: 0
    property string size: ""
    property string agentName: ""
    property string agentPhone: ""
    property var amenities: []

    // Whole-house booking state — the equivalent of the room page's
    // isquarterAvailable / isOnHold, but for the property itself.
    property bool isPropertyAvailable: true
    property bool isPropertyOnHold: false
    property var propertyHoldExpiresAt: null

    readonly property bool canBookProperty: root.propertyType === "WHOLE" && root.isPropertyAvailable && !root.isPropertyOnHold

    // The booking fee is the entire amount due for a whole-property booking.
    // Same admin-set value the room page uses.
    readonly property real bookingFee: AppSettings.bookingFee()

    // ========== AGENT ==========
    property string agentFirstName: ""
    property string agentLastName: ""
    property real agentRating: 0
    property int agentReviewCount: 0
    property bool propertyFavourite: AppSettings.isPropertyFavorite(root.propertyId)

    Connections {
        target: AppSettings
        function onFavoritePropertyIdsChanged() {
            root.propertyFavourite = AppSettings.isPropertyFavorite(root.propertyId);
        }
    }

    // ========== DETAILS MODEL (media + rooms) ==========
    PropertyDetailsModel {
        id: detailsModel
        propertyId: root.propertyId
    }

    // ========== AMENITIES HELPERS ==========
    function amenityTokens() {
        var src = root.amenities;
        if (!src)
            return [];
        if (Array.isArray(src))
            return src;
        if (typeof src === "string")
            return src.split("|").filter(function (s) {
                return s.length > 0;
            });
        if (src.count !== undefined && typeof src.get === "function") {
            var out = [];
            for (var i = 0; i < src.count; i++) {
                var row = src.get(i);
                var v = (row && row.modelData !== undefined) ? row.modelData : row;
                if (v !== null && v !== undefined && String(v).length > 0)
                    out.push(String(v));
            }
            return out;
        }
        return [];
    }

    function amenityLabel(token) {
        var map = {
            "WIFI": "Wi-Fi",
            "PARKING": "Parking",
            "SECURITY": "Security",
            "WATER": "Water",
            "ELECTRICITY": "Electricity",
            "FURNISHED": "Furnished",
            "AC": "A/C",
            "GARDEN": "Garden",
            "BALCONY": "Balcony",
            "BOREHOLE": "Borehole",
            "COOKER": "Cooker"
        };
        var key = String(token).toUpperCase();
        return map[key] !== undefined ? map[key] : key;
    }

    // ========== SIGNALS ==========
    signal backRequested
    signal bookRequested
    signal contactRequested
    signal favoriteToggled
    signal searchRequested
    signal roomClicked(string roomId, var roomData)

    function onSearchBarTapped() {
        root.searchRequested();
    }

    function goBack() {
        root.backRequested();
        NavUtils.pop();
    }

    function navigateToQuarters(roomData) {
        root.roomClicked(roomData.roomId, roomData);

        // Extract images list from model, falling back to single imageUrl
        var mediaArray = [];
        if (roomData.images && roomData.images.count !== undefined) {
            // If passed as QML ListModel/ListElement
            for (var i = 0; i < roomData.images.count; i++) {
                mediaArray.push(roomData.images.get(i).modelData || roomData.images.get(i));
            }
        } else if (Array.isArray(roomData.images) && roomData.images.length > 0) {
            mediaArray = roomData.images;
        } else if (roomData.imageUrl) {
            mediaArray = [roomData.imageUrl];
        }

        NavUtils.push(Qt.resolvedUrl("./QuartersDetailDelegate.qml"), {
            quarterId: roomData.roomId,
            quarterType: roomData.type,
            propertyId: root.propertyId,
            quarterPrice: roomData.price,
            isquarterAvailable: roomData.available,
            // Provisional hold state from GET /rooms. A held room still comes
            // back with available === true (only a CONFIRMED booking sets it
            // false), so these have to travel with the payload or the detail
            // page would show "Book Now" on a room that is already spoken for.
            isOnHold: roomData.holdActive === true,
            holdExpiresAt: roomData.holdExpiresAt ?? null,
            roomImage: roomData.imageUrl || "",
            mediaList: mediaArray // <--- Forward room images array
            ,
            quarterTitle: root.propertyTitle,
            location: root.location,
            description: root.description
        });
    }

    background: Rectangle {
        color: "#FFFFFF"
    }

    // ========== CONTENT ==========
    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: contentColumn
            width: flickable.width
            spacing: 0

            // ===== PROPERTY GALLERY =====
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 300

                SwipeView {
                    id: imageSwipe
                    anchors.fill: parent
                    clip: true

                    Repeater {
                        model: detailsModel.imageListModel

                        Item {
                            // ListModel roles injected as required properties
                            required property string url
                            required property int index

                            Image {
                                id: pageImage
                                anchors.fill: parent
                                source: ImageUtils.cachedSource(url)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                opacity: status === Image.Ready ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }
                            }

                            Rectangle {
                                id: skeleton
                                anchors.fill: parent
                                visible: pageImage.status !== Image.Ready
                                color: "#E5E7EB"
                                clip: true

                                Rectangle {
                                    id: shimmer
                                    width: parent.width * 0.45
                                    height: parent.height
                                    color: "#F9FAFB"
                                    opacity: 0.7
                                    x: -width
                                    SequentialAnimation on x {
                                        loops: Animation.Infinite
                                        running: skeleton.visible
                                        NumberAnimation {
                                            from: -shimmer.width
                                            to: skeleton.width
                                            duration: 1000
                                            easing.type: Easing.InOutQuad
                                        }
                                        PauseAnimation {
                                            duration: 200
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty gallery placeholder
                Rectangle {
                    anchors.fill: parent
                    color: "#F3F4F6"
                    visible: detailsModel.imageCount === 0
                    Label {
                        anchors.centerIn: parent
                        text: detailsModel.loading ? "Loading photos…" : "No photos"
                        color: "#9CA3AF"
                        font.pixelSize: 14
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    height: 24
                    radius: 12
                    color: "#80000000"
                    width: counterText.width + 16
                    visible: detailsModel.imageCount > 0

                    Label {
                        id: counterText
                        anchors.centerIn: parent
                        text: (imageSwipe.currentIndex + 1) + " / " + Math.max(detailsModel.imageCount, 1)
                        color: "white"
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    id: favouriteButton
                    width: 40
                    height: 40
                    radius: 20
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 12
                    color: "#CCFFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: root.propertyFavourite ? "qrc:/ui/assets/favorite-filled.svg" : "qrc:/ui/assets/favorite-outline.svg"
                        sourceSize.width: 22
                        sourceSize.height: 22
                        width: 22
                        height: 22
                        fillMode: Image.PreserveAspectFit
                        antialiasing: true
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("propertyType from saved button", root.propertyType);
                            if (!AppSettings.isLoggedIn()) {
                                NavUtils.navigateToAccount();
                                return;
                            }
                            AppSettings.toggleFavoriteProperty(root.propertyId);
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: "#F5F5F5"
            }

            // ===== AMENITIES =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                Layout.topMargin: 16
                spacing: 10
                visible: root.amenityTokens().length > 0

                SectionHeader {
                    title: qsTr("Amenities")
                }

                Flow {
                    id: amenitiesFlow
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: root.amenityTokens()

                        Rectangle {
                            required property string modelData
                            width: amenityText.width + 18
                            height: 26
                            radius: 13
                            color: "#2563EB"

                            Label {
                                id: amenityText
                                text: root.amenityLabel(modelData)
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: "white"
                                anchors.centerIn: parent
                            }
                        }
                    }
                }
            }

            // Divider above the price/availability section.
            // Show it whenever there is *something* above it (amenities or the gallery).
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 16
                height: 8
                color: "#F5F5F5"
            }

            // ===== PRICE + LOCATION + AVAILABILITY =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 12

                // ---- Location ----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Image {
                        width: 16
                        height: 16
                        source: "qrc:/ui/assets/location-2955.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        text: root.location
                        font.pixelSize: 14
                        color: "#6B7280"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // ---- Price block (whole-house only) ----
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    spacing: 6
                    visible: root.propertyType === "WHOLE"

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: qsTr("Rental Fee")
                            font.pixelSize: 13
                            color: "#6B7280"
                            Layout.fillWidth: true
                        }
                        Label {
                            text: Utils.formatCurrency(root.price)
                            font.pixelSize: 20
                            font.bold: true
                            color: "#2563EB"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: root.bookingFee > 0

                        Label {
                            text: qsTr("Booking Fee")
                            font.pixelSize: 13
                            color: "#6B7280"
                            Layout.fillWidth: true
                        }
                        Label {
                            text: Utils.formatCurrency(root.bookingFee)
                            font.pixelSize: 16
                            font.bold: true
                            color: "#111827"
                        }
                    }
                }

                // ---- Availability badge ----
                Rectangle {
                    Layout.topMargin: 4
                    height: 28
                    radius: 14
                    width: availabilityText.width + 24
                    color: root.isPropertyAvailable && !root.isPropertyOnHold ? "#22C55E" : (root.isPropertyOnHold ? "#F59E0B" : "#EF4444")

                    Label {
                        id: availabilityText
                        anchors.centerIn: parent
                        text: !root.isPropertyAvailable ? qsTr("Currently Booked") : (root.isPropertyOnHold ? qsTr("On Hold") : qsTr("Available Now"))
                        color: "white"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: "#F5F5F5"
                visible: root.amenityTokens().length > 0
            }

            // ===== ROOMS =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 12

                SectionHeader {
                    Layout.fillWidth: true
                    title: qsTr("Available Rooms")
                    actionLabel: detailsModel.roomCount + " rooms"
                }

                Label {
                    visible: detailsModel.roomCount === 0
                    text: detailsModel.roomsSettled ? "No rooms listed" : "Loading rooms…"
                    font.pixelSize: 13
                    color: "#9CA3AF"
                }

                GridView {
                    id: roomsGridView
                    Layout.fillWidth: true
                    height: Math.ceil(Math.max(detailsModel.roomCount, 0) / 2) * cellHeight
                    cellWidth: (width - 8) / 2
                    cellHeight: 180
                    clip: true
                    interactive: false
                    model: detailsModel.roomsModel

                    // ListModel roles via model.* — avoids required-property clash
                    // with QuartersComponent's own imageUrl property
                    delegate: QuartersComponent {
                        width: roomsGridView.cellWidth - 4
                        height: roomsGridView.cellHeight - 4

                        quartersId: model.roomId
                        quartersType: model.type
                        quartersPrice: model.price
                        isQuartersAvailable: model.available
                        imageUrl: ImageUtils.cachedSource(model.imageUrl)
                        quartersTitle: root.propertyTitle
                        location: root.location

                        onClicked: {
                            root.navigateToQuarters({
                                roomId: model.roomId,
                                propertyId: root.propertyId,
                                type: model.type,
                                price: model.price,
                                available: model.available,
                                imageUrl: model.imageUrl,
                                mediaList: imageUrl
                            });
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: "#F5F5F5"
            }

            // ===== REVIEWS =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 12

                // Header row: title + average + count
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: qsTr("Reviews")
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: "#1F2937"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 4
                        visible: ReviewViewModel.reviewCount > 0

                        Label {
                            text: "★"
                            color: "#F59E0B"
                            font.pixelSize: 14
                        }
                        Label {
                            text: ReviewViewModel.averageRating.toFixed(1)
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: "#1F2937"
                        }
                        Label {
                            text: "(" + ReviewViewModel.reviewCount + ")"
                            font.pixelSize: 12
                            color: "#6B7280"
                        }
                    }
                }

                // "Write a review" button — only when eligible
                Button {
                    Layout.fillWidth: true
                    visible: ReviewViewModel.canReview
                    text: qsTr("Write a review")
                    onClicked: writeReviewSheet.open()
                }

                // Why can't they review?
                Label {
                    Layout.fillWidth: true
                    visible: ReviewViewModel.canReviewReason === "already-reviewed"
                    text: qsTr("You've already reviewed this property")
                    color: "#6B7280"
                    font.pixelSize: 12
                }
                Label {
                    Layout.fillWidth: true
                    visible: ReviewViewModel.canReviewReason === "no-booking"
                    text: qsTr("Book this property to leave a review")
                    color: "#6B7280"
                    font.pixelSize: 12
                }

                // Loading spinner while reviews are being fetched
                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: ReviewViewModel.loading
                    visible: ReviewViewModel.loading
                }

                // Empty state
                Label {
                    Layout.fillWidth: true
                    visible: !ReviewViewModel.loading && ReviewViewModel.reviewCount === 0
                    text: qsTr("No reviews yet. Be the first to review this property.")
                    color: "#9CA3AF"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }

                // The review list — reuse the C++ ReviewListModel directly.
                Repeater {
                    model: ReviewViewModel.model

                    delegate: Rectangle {
                        required property var model
                        Layout.fillWidth: true
                        radius: 12
                        color: "#F9FAFB"
                        border.color: "#E5E7EB"
                        border.width: 1
                        implicitHeight: reviewCol.implicitHeight + 24

                        ColumnLayout {
                            id: reviewCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 6

                            RowLayout {
                                spacing: 8

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: "#E0E7FF"
                                    Label {
                                        anchors.centerIn: parent
                                        text: "?" // no user avatar yet; use a generic char
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#4338CA"
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Label {
                                        text: qsTr("Client review")
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: "#1F2937"
                                    }
                                    Label {
                                        text: model.createdAt
                                        font.pixelSize: 11
                                        color: "#9CA3AF"
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: "★".repeat(model.rating)
                                    font.pixelSize: 12
                                    color: "#F59E0B"
                                }
                            }

                            Label {
                                text: model.comment
                                font.pixelSize: 13
                                color: "#4B5563"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                lineHeight: 1.3
                            }
                        }
                    }
                }

                // "See all reviews" — pushes a dedicated screen for large lists
                Button {
                    Layout.fillWidth: true
                    visible: ReviewViewModel.reviewCount > 3
                    text: qsTr("See all " + ReviewViewModel.reviewCount + " reviews")
                    flat: true
                    onClicked: NavUtils.push("qrc:/ui/features/reviews/screens/ReviewListScreen.qml", {
                        propertyId: root.propertyId
                    })
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
            }
        }
    }

    // ========== FOOTER (whole-house booking only) ==========
    footer: ToolBar {
        id: bookingBar
        height: root.propertyType === "WHOLE" ? 72 : 0
        visible: root.propertyType === "WHOLE"

        background: Rectangle {
            color: "#FFFFFF"
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Button {
                id: bookButton
                Layout.fillWidth: true
                Layout.fillHeight: true
                enabled: !BookingController.isLoading && root.canBookProperty

                text: {
                    if (BookingController.isLoading)
                        return qsTr("Booking…");
                    if (!root.isPropertyAvailable)
                        return qsTr("Currently Booked");
                    if (root.isPropertyOnHold)
                        return qsTr("On Hold");
                    return qsTr("Book Now");
                }

                background: Rectangle {
                    radius: 12
                    color: bookButton.enabled ? "#2563EB" : "#9CA3AF"
                }

                contentItem: Label {
                    text: bookButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (!AppSettings.isLoggedIn()) {
                        NavUtils.navigateToAccount();
                        return;
                    }

                    if (!root.canBookProperty) {
                        errorDialog.errorText = root.isPropertyOnHold ? qsTr("This property is currently on hold by another user.") : qsTr("This property is no longer available.");
                        errorDialog.open();
                        return;
                    }

                    if (root.bookingFee <= 0) {
                        errorDialog.errorText = qsTr("Booking is not available right now. Please try again later.");
                        errorDialog.open();
                        return;
                    }

                    var commission = root.bookingFee * (AppSettings.platformCommissionRate() / 100);

                    // Whole-property booking: send propertyId instead of roomId.
                    // BookingController needs a createPropertyBooking(...) entry
                    // point that hits POST /bookings with { propertyId, … }.
                    BookingController.createPropertyBooking(root.propertyId, root.bookingFee, commission);
                }
            }
        }
    }

    Dialog {
        id: errorDialog
        property string errorText: ""
        anchors.centerIn: parent
        title: qsTr("Booking Failed")
        modal: true
        standardButtons: Dialog.Ok
        width: Math.min(parent ? parent.width - 48 : 320, 360)

        contentItem: Label {
            text: errorDialog.errorText
            wrapMode: Text.WordWrap
        }
    }

    Connections {
        target: BookingController

        function onBookingCreated(booking) {
            NavUtils.navigateToPayments(booking.id, booking.amount, booking.holdExpiresAt !== undefined ? booking.holdExpiresAt : null);
        }

        function onPropertyBookingError(error) {
            errorDialog.errorText = error;
            errorDialog.open();
        }
    }
    Component.onCompleted: {
        if (root.propertyId.length > 0) {
            ReviewViewModel.loadForProperty(root.propertyId);
            ReviewViewModel.loadSummary(root.propertyId);
            if (AppSettings.isLoggedIn()) {
                ReviewViewModel.checkCanReview(root.propertyId);
            }
        }
    }

    Component.onDestruction: {
        ReviewViewModel.model.clear();
    }
}
