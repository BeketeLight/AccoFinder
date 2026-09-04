import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../components/inputs"
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

    // ========== REVIEWS (dummy) ==========
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

    function onSearchBarTapped() {
        root.searchRequested();
    }
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

            // ===== IMAGE CAROUSEL =====
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 300

                SwipeView {
                    id: imageSwipe
                    anchors.fill: parent
                    clip: true

                    Repeater {
                        model: root.imageList.length > 0 ? root.imageList : [root.imageUrl]

                        Image {
                            required property var modelData
                            source: modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true

                            Rectangle {
                                anchors.fill: parent
                                color: "#F5F5F5"
                                visible: parent.status !== Image.Ready
                                Label {
                                    anchors.centerIn: parent
                                    text: "🏠"
                                    font.pixelSize: 40
                                    opacity: 0.3
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
            }

            // ===== MAIN INFO =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                spacing: 8

                Label {
                    text: root.propertyTitle
                    font.pixelSize: 20
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
                    }
                }

                Label {
                    text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
                    font.pixelSize: 24
                    font.bold: true
                    color: "#2563EB"
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
                        label: root.size
                    }

                    Label {
                        visible: root.isVerified
                        text: "✓ Verified"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#22C55E"
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
                text: "Book Now"
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
