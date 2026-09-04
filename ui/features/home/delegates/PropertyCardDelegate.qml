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

    width: 180
    height: 240

    // Background
    Rectangle {
        anchors.fill: parent
        radius: 5
        color: "#FFFFFF"
        border.color: "#E5E7EB"
        border.width: 1
        clip: true

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#15000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 2
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========== IMAGE ==========
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 105

            Rectangle {
                anchors.fill: parent
                radius: 5
                color: "red" //"#F5F5F5"
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.imageUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    Rectangle {
                        anchors.fill: parent
                        color: "#F5F5F5"
                        visible: parent.status !== Image.Ready

                        Label {
                            anchors.centerIn: parent
                            text: "🏠"
                            font.pixelSize: 28
                            opacity: 0.3
                        }
                    }
                }
            }
        }
        // Price
        Label {
            text: "MWK " + Number(root.price).toLocaleString(Qt.locale(), "f", 0)
            font.pixelSize: 14
            font.bold: true
            color: "#2563EB"
            elide: Text.ElideRight

            Layout.fillWidth: true                    // take full width
            horizontalAlignment: Text.AlignHCenter    // ← center the text
            Layout.alignment: Qt.AlignHCenter         // ← center the item (optional)
            //Layout.topMargin: 4
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
