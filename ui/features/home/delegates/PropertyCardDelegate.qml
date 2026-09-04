import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string propertyId: ""
    property string title: ""
    property string location: ""
    property real price: 0
    property string imageUrl: ""
    property string imageUrls: ""
    property string status: "PENDING"
    property bool isVerified: false

    property real rating: 4.5          // e.g. 4.5
    property int reviewCount: 12       // e.g. 12 reviews

    signal clicked
    signal favoriteClicked

    // Remove fixed width/height - let the GridView control this
    // width: 100  // REMOVE THIS
    // height: 240 // REMOVE THIS

    Column {
        anchors.fill: parent
        spacing: 4  // Small gap between image and price

        // ========== IMAGE ==========
        Rectangle {
            id: borderRect
            width: parent.width
            height: parent.height - 52  // Leave space for price (adjust as needed)
            border.color: "#E5E7EB"
            color: "transparent"
            border.width: 1.5
            radius: 16

            Image {
                id: img
                anchors.fill: parent
                anchors.margins: borderRect.border.width
                source: root.imageUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true

                layer.enabled: true
                layer.smooth: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: mask
                }
                clip: true
            }

            Rectangle {
                id: mask
                anchors.fill: parent
                anchors.margins: borderRect.border.width
                radius: 16
                color: "black"
                visible: false
                layer.enabled: true
                layer.smooth: true
            }
        }

        // INFO SECTION
        Column {
            width: parent.width
            spacing: 2
            leftPadding: 2
            rightPadding: 2

            // Price
            Label {
                width: parent.width
                text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
                font.pixelSize: 12
                font.bold: true
                color: "#2563EB"
                elide: Text.ElideRight
            }

            // Location
            Label {
                width: parent.width
                text: root.location
                font.pixelSize: 11
                color: "#6B7280"
                elide: Text.ElideRight
            }

            // Stars + review count
            Row {
                spacing: 3

                // Simple star display
                Label {
                    text: "★".repeat(Math.floor(root.rating)) + (root.rating % 1 >= 0.5 ? "½" : "")
                    font.pixelSize: 11
                    color: "#F59E0B"          // amber/gold
                }

                Label {
                    text: root.rating.toFixed(1)
                    font.pixelSize: 10
                    color: "#6B7280"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    text: "(" + root.reviewCount + ")"
                    font.pixelSize: 10
                    color: "#9CA3AF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ========== PRICE ==========
        // Label {
        //     width: parent.width
        //     height: 20  // Fixed height for price
        //     text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
        //     font.pixelSize: 14
        //     font.bold: true
        //     color: "#2563EB"
        //     elide: Text.ElideRight
        //     horizontalAlignment: Text.AlignHCenter
        //     verticalAlignment: Text.AlignVCenter
        // }
    }

    // Click area
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
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
            });
            root.clicked();
        }
    }
}
