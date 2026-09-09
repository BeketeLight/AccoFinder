import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Page {
    id: root

    // ========== PROPERTY DATA ==========
    property string roomId: ""
    property string propertyTitle: "Modern 2 Bedroom Apartment"
    property string roomType: "Master Bedroom"
    property string roomLocation: "Area 47, Lilongwe"
    property real roomPrice: 250000
    property bool roomAvailable: true
    property string description: "Spacious master bedroom with en-suite bathroom and walk-in closet. Features large windows with natural light and a beautiful view of the garden."
    property int bedrooms: 2
    property int bathrooms: 1
    property string roomSize: "85 m²"

    // Agent information
    property string agentFirstName: "Banda"
    property string agentLastName: ""
    property string agentPhone: "+265 999 123 456"
    property string agentEmail: "john.banda@realtor.mw"
    property real agentRating: 4.6
    property int agentReviewCount: 28
    // property var reviewsModel

    // Media - images and videos
    property string roomImage: ""
    property var mediaList: ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop,https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop"]

    // Reviews
    property var reviewsModel: [
        {
            name: "Mary Phiri",
            rating: 5,
            comment: "Very clean and well maintained room. Agent was helpful.",
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

    function goBack() {
        root.backRequested();
        NavUtils.pop();
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

            // ===== MEDIA CAROUSEL =====
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 300

                SwipeView {
                    id: mediaSwipe
                    anchors.fill: parent
                    clip: true

                    Repeater {
                        id: mediaModel
                        model: root.mediaList.length > 0 ? root.mediaList : []

                        Item {
                            required property var modelData

                            // Check if it's a video URL (contains .mp4, .mov, etc.)
                            property bool isVideo: modelData.match(/\.(mp4|mov|avi|mkv|webm)$/i) !== null

                            Image {
                                id: pageImage
                                anchors.fill: parent
                                source: isVideo ? "" : modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: !isVideo

                                Rectangle {
                                    anchors.fill: parent
                                    color: "#F5F5F5"
                                    visible: parent.status !== Image.Ready
                                    Label {
                                        anchors.centerIn: parent
                                        text: "🖼️"
                                        font.pixelSize: 40
                                        opacity: 0.3
                                    }
                                }
                            }
                            // Shimmer while photo loads
                            Rectangle {
                                id: skeleton
                                anchors.fill: parent
                                visible: !isVideo && pageImage.status !== Image.Ready
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

                            // Video placeholder
                            Rectangle {
                                anchors.fill: parent
                                color: "#1A1A1A"
                                visible: isVideo

                                Label {
                                    anchors.centerIn: parent
                                    text: "▶️"
                                    font.pixelSize: 60
                                    color: "white"
                                }

                                Label {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.margins: 20
                                    text: "Video"
                                    color: "white"
                                    font.pixelSize: 14
                                    opacity: 0.7
                                }
                            }
                        }
                    }
                }

                // Media counter
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
                        text: (mediaSwipe.currentIndex + 1) + " / " + Math.max(mediaSwipe.count, 1)
                        color: "white"
                        font.pixelSize: 12
                    }
                }

                // Media type indicator
                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    height: 24
                    radius: 12
                    color: "#80000000"
                    width: mediaTypeText.width + 16

                    Label {
                        id: mediaTypeText
                        anchors.centerIn: parent
                        text: mediaSwipe.currentItem ? (mediaSwipe.currentItem.isVideo ? "🎥 Video" : "📷 Photo") : "📷 Photo"
                        color: "white"
                        font.pixelSize: 12
                    }
                }
            }

            // ===== MAIN INFO =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 8

                Label {
                    text: root.roomType
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: root.propertyTitle
                    font.pixelSize: 15
                    color: "#6B7280"
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
                        text: root.roomLocation
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

                // Availability badge
                Rectangle {
                    height: 28
                    radius: 14
                    width: availabilityText.width + 24
                    color: root.isAvailable ? "#22C55E" : "#EF4444"

                    Label {
                        id: availabilityText
                        anchors.centerIn: parent
                        text: root.isAvailable ? "✓ Available Now" : "✗ Currently Booked"
                        color: "white"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                RowLayout {
                    spacing: 16
                    Layout.topMargin: 4

                    SpecItem {
                        icon: "🛏"
                        label: root.bedrooms + " Beds"
                    }
                    SpecItem {
                        icon: "🛁"
                        label: root.bathrooms + " Baths"
                    }
                    SpecItem {
                        icon: "📐"
                        label: root.roomSize
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: "#F5F5F5"
            }

            // ===== DESCRIPTION =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 8

                Label {
                    text: "About This Room"
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
                        width: 56
                        height: 56
                        radius: 28
                        color: "#DBEAFE"

                        Label {
                            anchors.centerIn: parent
                            text: root.agentFirstName.toUpperCase() + "" + root.agentLastName.toUpperCase()
                            font.pixelSize: 18
                            font.bold: true
                            color: "#2563EB"
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Label {
                            text: root.agentFirstName + " " + root.agentLastName
                            font.pixelSize: 16
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
                                text: "(" + root.agentReviewCount + " reviews)"
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
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: "#E0E7FF"
                                    Label {
                                        anchors.centerIn: parent
                                        text: modelData.name.charAt(0)
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#4338CA"
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Label {
                                        text: modelData.name
                                        font.pixelSize: 14
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

            // Bottom spacer
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
                text: root.roomAvailable ? "Book Now" : "Notify Me"
                background: Rectangle {
                    radius: 12
                    color: root.roomAvailable ? "#2563EB" : "#6B7280"
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

    // ========== HELPER ==========
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
