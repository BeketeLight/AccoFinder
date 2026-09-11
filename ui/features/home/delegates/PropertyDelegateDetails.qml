import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../components/inputs"
import "../components/"
import "../../../utils/NavigationUtils.js" as NavUtils

Page {
    id: root

    // ========== HEADER CONTROL ==========
    property string pageTitle: ""
    property bool isSearchBar: true
    property bool showBack: true
    property bool showHeader: true
    property bool searchReadOnly: false

    // ========== PROPERTY DATA ==========
    property string propertyId: ""
    property bool favouriteChecked: false
    property string propertyTitle: "Modern 2 Bedroom Apartment"
    property string location: "Area 47, Lilongwe"
    property real price: 450000
    property string status: "Available"
    property bool isVerified: true
    property string description: "Spacious and well-lit apartment located in a quiet neighborhood. Close to shops, schools and public transport. Ideal for small families or professionals."
    property int bedrooms: 2
    property int bathrooms: 1
    property string size: "85 m²"
    property string agentName: "John Banda"
    property string agentPhone: "+265 999 123 456"
    property string imageUrl: ""
    property string imageUrls: ""
    property var imageList: root.imageUrls ? root.imageUrls.split(",") : []
    property var amenities: []

    // ========== AGENT ==========
    property string agentFirstName: "John"
    property string agentLastName: "Banda"
    property real agentRating: 4.6
    property int agentReviewCount: 28

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
        // last-ditch fallback for QQmlListModel if any caller still passes one
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
        console.log("amenityLabel key if avaialabe");
        console.log(key);
        return map[key] !== undefined ? map[key] : key;
    }

    function amenityIcon(token) {
        var map = {
            "WIFI": "📶",
            "PARKING": "🅿️",
            "SECURITY": "🔒",
            "WATER": "💧",
            "ELECTRICITY": "⚡",
            "FURNISHED": "🛋️",
            "AC": "❄️",
            "GARDEN": "🌳",
            "BALCONY": "🌅",
            "BOREHOLE": "🚰",
            "COOKER": "🍳"
        };
        var key = String(token).toUpperCase();
        console.log("amenityIcon key if avaialabe");
        console.log(key);
        return map[key] !== undefined ? map[key] : "✓";
    }

    // ========== ROOMS DATA ==========
    property var roomsModel: [
        {
            roomId: "room1",
            type: "Master Bedroom",
            price: 250000,
            available: true,
            size: "20 m²",
            imageUrl: ""
        },
        {
            roomId: "room2",
            type: "Second Bedroom",
            price: 200000,
            available: true,
            size: "18 m²",
            imageUrl: ""
        },
        {
            roomId: "room3",
            type: "Single Room",
            price: 150000,
            available: false,
            size: "15 m²",
            imageUrl: ""
        }
    ]

    // ========== REVIEWS ==========
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
        // Emit signal with room data
        root.roomClicked(roomData.roomId, roomData);
        // Navigate to room details
        NavUtils.push(Qt.resolvedUrl("./QuartersDetailDelegate.qml"), {
            quarterId: roomData.roomId,
            quarterType: roomData.type,
            quarterPrice: roomData.price,
            isquarterAvailable: roomData.available,
            roomImage: roomData.imageUrl,
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

            // ===== PROPERTY THUMBNAIL CAROUSEL =====
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 300

                SwipeView {
                    id: imageSwipe
                    anchors.fill: parent
                    clip: true

                    Repeater {
                        model: root.imageList.length > 0 ? root.imageList : [root.imageUrl]

                        Item {
                            required property var modelData

                            // Main image
                            Image {
                                id: pageImage
                                anchors.fill: parent
                                source: modelData
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

                            // Skeleton + shimmer while loading
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

                // Image counter
                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    height: 24
                    radius: 12
                    color: "#80000000"
                    width: counterText.width + 16

                    Label {
                        id: counterText
                        anchors.centerIn: parent
                        text: (imageSwipe.currentIndex + 1) + " / " + Math.max(imageSwipe.count, 1)
                        color: "white"
                        font.pixelSize: 12
                    }
                }

                Image {
                    id: favouriteImg
                    source: root.favouriteChecked ? "qrc:/ui/assets/favorite-filled.svg" : "qrc:/ui/assets/favorite-outline.svg"
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
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

            // ===== AMENITIES SECTION =====
            ColumnLayout {
                id: amenitiesSection
                Layout.fillWidth: true
                Layout.margins: 10
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Amenities"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: "#1F2937"
                        Layout.fillWidth: true
                    }
                }

                // Amenities grid
                Flow {
                    id: amenitiesFlow
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: root.amenityTokens()

                        delegate: Rectangle {
                            required property string modelData          // ← the amenity token

                            width: (amenitiesFlow.width - amenitiesFlow.spacing * 2) / 3
                            height: 50
                            radius: 10
                            color: "#F0FDF4"
                            border.color: "#BBF7D0"
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Label {
                                    text: root.amenityIcon(modelData)
                                    font.pixelSize: 22
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Label {
                                    text: root.amenityLabel(modelData)
                                    font.pixelSize: 11
                                    color: "#166534"
                                    font.weight: Font.Medium
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.maximumWidth: parent.width
                                    // elide: Text.ElideRight
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
            }

            // ===== ROOMS GRID =====
            ColumnLayout {
                id: roomsSection
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
                        text: root.roomsModel.length + " rooms"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }
                }

                // Grid of room cards
                GridView {
                    id: roomsGridView
                    Layout.fillWidth: true
                    height: roomsGridView.contentHeight
                    cellWidth: (width - 8) / 2
                    cellHeight: 180
                    clip: true
                    interactive: false
                    model: root.roomsModel

                    delegate: QuartersComponent {
                        width: roomsGridView.cellWidth - 4
                        height: roomsGridView.cellHeight - 4
                        quartersId: modelData.roomId
                        quartersType: modelData.type
                        quartersPrice: modelData.price
                        isQuartersAvailable: modelData.available
                        imageUrl: modelData.imageUrl || root.imageList[0] || ""
                        imageUrls: root.imageList
                        quartersTitle: root.propertyTitle
                        location: root.location

                        onClicked: {
                            root.navigateToQuarters(modelData);
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
                                        text: modelData.name.charAt(0)
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

            // Space for footer
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

    // ========== HELPER COMPONENTS ==========
    component SpecItem: RowLayout {
        property string icon
        property string label
        spacing: 4
        Label {
            text: icon
            font.pixelSize: 14
        }
        Label {
            text: label
            font.pixelSize: 13
            color: "#4B5563"
        }
    }
}
