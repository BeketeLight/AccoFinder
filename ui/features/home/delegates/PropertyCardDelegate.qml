import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root

    // Model properties
    property string propertyId: ""
    property string title: ""
    property string location: ""
    property real price: 0
    property string imageUrl: ""
    property string status: "Available"      // Available, Booked, Pending
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
                        switch (root.status.toLowerCase()) {
                        case "available":
                            return "#DCFCE7";   // light green
                        case "booked":
                            return "#FEE2E2";   // light red
                        case "pending":
                            return "#FEF3C7";   // light orange
                        default:
                            return "#F3F4F6";
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: root.status
                        font.pixelSize: 11
                        font.bold: true
                        leftPadding: 8
                        rightPadding: 8
                        color: {
                            switch (root.status.toLowerCase()) {
                            case "available":
                                return "#16A34A";   // Success green
                            case "booked":
                                return "#DC2626";   // Error red
                            case "pending":
                                return "#D97706";   // Warning orange
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
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
