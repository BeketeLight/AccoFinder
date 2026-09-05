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
            height: parent.height - 24  // Leave space for price (adjust as needed)
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

        // ========== PRICE ==========
        Label {
            width: parent.width
            height: 20  // Fixed height for price
            text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
            font.pixelSize: 14
            font.bold: true
            color: "#2563EB"
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
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
