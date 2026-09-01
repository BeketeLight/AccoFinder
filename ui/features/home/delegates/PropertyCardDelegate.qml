import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    // Model properties
    property string propertyId: ""
    property string title: ""
    property string location: ""
    property real price: 0
    property string imageUrl: ""
    property string imageUrls: ""
    property string status: "PENDING"      // Available, Booked, Pending
    property bool isVerified: false

    signal clicked
    signal favoriteClicked

    width: 180
    height: 265

    // Card background
    Rectangle {
        id: cardBackground
        anchors.fill: parent
        radius: 14
        color: "#FFFFFF"                    // Background
        border.color: "#E5E7EB"
        border.width: 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#1A000000"
            shadowBlur: 0.7
            shadowVerticalOffset: 3
            shadowHorizontalOffset: 0
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ===================== IMAGE =====================
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: "#F5F5F5"            // Cards color
                clip: true

                // Squared bottom so only top is rounded
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 14
                    color: parent.color
                }

                Image {
                    id: propertyImage
                    anchors.fill: parent
                    source: root.imageUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    // Placeholder
                    Rectangle {
                        anchors.fill: parent
                        color: "#F5F5F5"
                        visible: propertyImage.status !== Image.Ready

                        Label {
                            anchors.centerIn: parent
                            text: "🏠"
                            font.pixelSize: 34
                            opacity: 0.35
                        }
                    }
                }

                // Status badge
                Rectangle {
                    visible: root.status.length > 0
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 30
                    anchors.topMargin: 5
                    height: 22
                    radius: 6
                    color: {
                        switch (root.status.toLocaleLowerCase()) {
                        case "VERIFIED":
                            return "#DCFCE7";
                        case "PENDING":
                            return "#FEF3C7";
                        case "REJECTED":
                            return "#FEE2E2";
                        case "DRAFT":
                            return "#F3F4F6";
                        default:
                            return "#F3F4F6";
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        font.pixelSize: 11
                        font.bold: true
                        leftPadding: 8
                        rightPadding: 8
                        text: root.status === "VERIFIED" ? "Verified" : root.status === "PENDING" ? "Pending" : root.status === "REJECTED" ? "Rejected" : "Draft"
                        color: {
                            switch (root.status.toLocaleLowerCase()) {
                            case "VERIFIED":
                                return "#16A34A";
                            case "PENDING":
                                return "#D97706";
                            case "REJECTED":
                                return "#DC2626";
                            default:
                                return "#6B7280";
                            }
                        }
                    }
                }

                // Favorite button
                RoundButton {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.margins: 8
                    width: 32
                    height: 22
                    flat: true

                    background: Rectangle {
                        radius: width / 2
                        color: "#FFFFFF"
                        opacity: 0.92
                    }

                    contentItem: Label {
                        text: "♡"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "#1F2937"
                    }

                    onClicked: root.favoriteClicked()
                }
            }
        }

        // ===================== INFO =====================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10
            spacing: 4

            // Price – Primary blue
            Label {
                text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
                font.pixelSize: 16
                font.bold: true
                color: "#2563EB"            // Primary
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // Title
            Label {
                text: root.title
                font.pixelSize: 13
                font.weight: Font.Medium
                color: "#1F2937"            // Primary Text
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.preferredHeight: 36
            }

            // Location
            RowLayout {
                spacing: 3
                Layout.fillWidth: true

                Label {
                    text: "📍"
                    font.pixelSize: 12
                }

                Label {
                    text: root.location
                    font.pixelSize: 12
                    color: "#6B7280"        // Secondary Text
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // Verified
            Label {
                visible: root.isVerified
                text: "✓ Verified"
                font.pixelSize: 11
                font.bold: true
                color: "#22C55E"            // Secondary / Success
                Layout.topMargin: 2
            }
        }
    }

    // Click area
    MouseArea {
        anchors.fill: parent
        onClicked: {
            NavUtils.push(Qt.resolvedUrl("./PropertyDelegateDetails.qml"), {
                propertyId: root.propertyId,
                propertyTitle: root.title,
                location: root.location,
                price: root.price,
                status: root.status,
                isVerified: root.isVerified,
                imageUrl: root.imageUrl,
                imageUrls: root.imageUrls
                // add more later (description, agentName, etc.)
            });
            root.clicked();
        }
    }
}
