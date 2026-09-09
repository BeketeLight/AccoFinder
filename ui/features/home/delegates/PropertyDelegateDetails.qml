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

    // ========== AGENT ==========
    property string agentFirstName: "John"
    property string agentLastName: "Banda"
    property real agentRating: 4.6
    property int agentReviewCount: 28

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

    function navigateToRoom(roomData) {
        // Emit signal with room data
        root.roomClicked(roomData.roomId, roomData);
        // Navigate to room details
        NavUtils.push(Qt.resolvedUrl("./RoomDetailDelegate.qml"), {
            roomId: roomData.roomId,
            roomType: roomData.type,
            roomPrice: roomData.price,
            isRoomAvailable: roomData.available,
            roomSize: roomData.size,
            roomImage: roomData.imageUrl,
            propertyTitle: root.propertyTitle,
            roomLocation: root.location,
            description: root.description,
            agentPhone: root.agentPhone,
            agentFirstName: root.agentFirstName,
            agentLastName: root.agentLastName,
            agentRating: root.agentRating,
            agentReviewCount: root.agentReviewCount,
            reviewsModel: root.reviewsModel
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

                // Property favourite/save badge
                // Rectangle {
                //     anchors.top: parent.top
                //     anchors.right: parent.right
                //     anchors.margins: 16
                //     height: 28
                //     radius: 14
                //     width: statusText.width + 24
                //     color: root.status === "Available" ? "#22C55E" : "#EF4444"

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
                    // }

                    // Label {
                    //     id: statusText
                    //     anchors.centerIn: parent
                    //     text: root.status === "Available" ? "✓ Available" : "✗ Booked"
                    //     color: "white"
                    //     font.pixelSize: 13
                    //     font.bold: true
                    // }
                }
            }

            // ===== PROPERTY MAIN INFO =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 8

                Label {
                    text: root.propertyTitle
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 4
                    Label {
                        text: "📍"
                        font.pixelSize: 14
                    }
                    Label {
                        text: root.location
                        font.pixelSize: 14
                        color: "#6B7280"
                        Layout.fillWidth: true
                    }
                }

                Label {
                    text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
                    font.pixelSize: 26
                    font.bold: true
                    color: "#2563EB"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: "#F5F5F5"
            }

            // ===== PROPERTY DESCRIPTION =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 8

                Label {
                    text: "Description"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                }

                Label {
                    text: root.description
                    font.pixelSize: 14
                    color: "#4B5563"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    lineHeight: 1.35
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: "#F5F5F5"
            }

            // ===== AGENT =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 12

                Label {
                    text: "Listed by"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                }

                RowLayout {
                    spacing: 12

                    Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                        color: "#DBEAFE"

                        Label {
                            anchors.centerIn: parent
                            text: (root.agentFirstName.charAt(0) + root.agentLastName.charAt(0)).toUpperCase()
                            font.pixelSize: 16
                            font.bold: true
                            color: "#2563EB"
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Label {
                            text: root.agentFirstName + " " + root.agentLastName
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            color: "#1F2937"
                        }

                        RowLayout {
                            spacing: 6
                            Label {
                                text: "Property Agent"
                                font.pixelSize: 13
                                color: "#6B7280"
                            }
                            Label {
                                text: "★ " + root.agentRating.toFixed(1)
                                font.pixelSize: 13
                                font.bold: true
                                color: "#F59E0B"
                            }
                            Label {
                                text: "(" + root.agentReviewCount + ")"
                                font.pixelSize: 12
                                color: "#9CA3AF"
                            }
                        }
                    }

                    Button {
                        text: "Contact"
                        onClicked: {
                            if (root.agentPhone.length > 0)
                                Qt.openUrlExternally("tel:" + root.agentPhone);
                        }
                        background: Rectangle {
                            radius: 8
                            color: "#EFF6FF"
                            border.color: "#2563EB"
                        }
                        contentItem: Label {
                            text: parent.text
                            color: "#2563EB"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
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

                    delegate: RoomComponent {
                        width: roomsGridView.cellWidth - 4
                        height: roomsGridView.cellHeight - 4
                        roomId: modelData.roomId
                        roomType: modelData.type
                        price: modelData.price
                        isRoomAvailable: modelData.available
                        roomSize: modelData.size
                        imageUrl: modelData.imageUrl || root.imageList[0] || ""
                        propertyTitle: root.propertyTitle
                        location: root.location

                        onClicked: {
                            root.navigateToRoom(modelData);
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
                Layout.preferredWidth: 120
                Layout.fillHeight: true
                text: "Contact"
                background: Rectangle {
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#2563EB"
                    border.width: 1.5
                }
                contentItem: Label {
                    text: parent.text
                    color: "#2563EB"
                    font.pixelSize: 15
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    if (root.agentPhone.length > 0)
                        Qt.openUrlExternally("tel:" + root.agentPhone);
                }
            }

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
