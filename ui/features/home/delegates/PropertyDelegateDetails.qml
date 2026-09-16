import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../components/inputs"
import "../components/"
import "../models"
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../../utils/ImageUtils.js" as ImageUtils

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

    // ========== AGENT ==========
    property string agentFirstName: ""
    property string agentLastName: ""
    property real agentRating: 0
    property int agentReviewCount: 0

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

    function amenityIcon(token) {
        var map = {
            "WIFI": "qrc:/ui/assets/amenities/wifi.svg",
            "PARKING": "qrc:/ui/assets/amenities/parking.svg",
            "SECURITY": "qrc:/ui/assets/amenities/security.svg",
            "WATER": "qrc:/ui/assets/amenities/water.svg",
            "ELECTRICITY": "qrc:/ui/assets/amenities/electricity.svg",
            "FURNISHED": "qrc:/ui/assets/amenities/furnished.svg",
            "AC": "qrc:/ui/assets/amenities/ac.svg",
            "GARDEN": "qrc:/ui/assets/amenities/garden.svg",
            "BALCONY": "qrc:/ui/assets/amenities/balcony.svg",
            "BOREHOLE": "qrc:/ui/assets/amenities/borehole.svg",
            "COOKER": "qrc:/ui/assets/amenities/cooker.svg"
        };
        var key = String(token).toUpperCase();
        return map[key] !== undefined ? map[key] : "";
    }

    // ========== REVIEWS (placeholder until API exists) ==========
    property var reviewsModel: [
        {
            name: "Mary Phiri",
            rating: 5,
            comment: "Very clean and well maintained. Agent was helpful.",
            date: "2 weeks ago"
        },
        {
            name: "James Banda",
            rating: 4,
            comment: "Good location, peaceful area. Would recommend.",
            date: "1 month ago"
        },
        {
            name: "Grace Mwale",
            rating: 5,
            comment: "Excellent experience. Fast response from the agent.",
            date: "1 month ago"
        }
    ]

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
            quarterPrice: roomData.price,
            isquarterAvailable: roomData.available,
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

                Image {
                    id: favouriteImg
                    source: root.favouriteChecked ? "qrc:/ui/assets/favorite-filled.svg" : "qrc:/ui/assets/favorite-outline.svg"
                    width: 22
                    height: 22
                    sourceSize.width: 48
                    sourceSize.height: 48
                    fillMode: Image.PreserveAspectFit
                    antialiasing: true
                    smooth: true
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 8

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.favoriteToggled();
                            root.favouriteChecked = !root.favouriteChecked;
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
                Layout.margins: 10
                spacing: 12
                visible: root.amenityTokens().length > 0

                Label {
                    text: "Amenities"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                }

                Flow {
                    id: amenitiesFlow
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: root.amenityTokens()

                        Rectangle {
                            required property string modelData
                            width: (amenitiesFlow.width - amenitiesFlow.spacing * 2) / 3
                            height: 50
                            radius: 10
                            color: "#F0FDF4"
                            border.color: "#BBF7D0"
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    source: root.amenityIcon(modelData)
                                    width: 18
                                    height: 18
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    fillMode: Image.PreserveAspectFit
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Label {
                                    text: root.amenityLabel(modelData)
                                    font.pixelSize: 11
                                    color: "#166534"
                                    font.weight: Font.Medium
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
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

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Available Rooms"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: "#1F2937"
                        Layout.fillWidth: true
                    }

                    Label {
                        text: detailsModel.roomCount + " rooms"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }
                }

                Label {
                    visible: detailsModel.roomCount === 0
                    text: detailsModel.loading ? "Loading rooms…" : "No rooms listed"
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
                            // Not signed in → route to auth instead of details.
                            if (!AppSettings.isLoggedIn()) {
                                NavUtils.navigateToAccount();
                                return;
                            }
                            root.navigateToQuarters({
                                roomId: model.roomId,
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

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Reviews"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: "#1F2937"
                        Layout.fillWidth: true
                    }

                    Label {
                        text: root.agentReviewCount + " reviews"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }
                }

                Repeater {
                    model: root.reviewsModel

                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        radius: 12
                        color: "#F9FAFB"
                        border.color: "#E5E7EB"
                        border.width: 1
                        height: reviewCol.height + 24

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
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: "#E0E7FF"
                                    Label {
                                        anchors.centerIn: parent
                                        text: String(modelData.name).charAt(0)
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: "#4338CA"
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Label {
                                        text: modelData.name
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: "#1F2937"
                                    }
                                    Label {
                                        text: modelData.date
                                        font.pixelSize: 11
                                        color: "#9CA3AF"
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: "★".repeat(modelData.rating)
                                    font.pixelSize: 12
                                    color: "#F59E0B"
                                }
                            }

                            Label {
                                text: modelData.comment
                                font.pixelSize: 13
                                color: "#4B5563"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                lineHeight: 1.3
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
            }
        }
    }

    // ========== FOOTER ==========
    footer: ToolBar {
        height: 72
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
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Check Reviews"
                background: Rectangle {
                    radius: 12
                    color: "#2563EB"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: root.bookRequested()
            }
        }
    }
}
