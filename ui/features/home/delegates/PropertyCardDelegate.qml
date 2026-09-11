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
    property bool isInfoSectionVisible: true
    property var amenities: []

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

        //IMAGE
        Rectangle {
            id: borderRect
            width: parent.width
            height: parent.height - (root.isInfoSectionVisible ? 52 : 0)
            border.color: "#E5E7EB"
            color: "#F3F4F6"
            border.width: 1.5
            radius: 16
            clip: true

            RemoteImage {
                id: img
                anchors.fill: parent
                anchors.margins: borderRect.border.width
                remoteUrl: root.imageUrl
                // Everything below is identical to before.
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                opacity: status === Image.Ready ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                layer.enabled: true
                layer.smooth: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: mask
                }
            }

            // Rounded mask
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

            // ===== SKELETON LOADER (shown while loading) =====
            Rectangle {
                id: skeleton
                anchors.fill: parent
                anchors.margins: borderRect.border.width
                radius: 16
                visible: img.status !== Image.Ready
                color: "#E5E7EB"
                clip: true

                // Moving shimmer bar
                Rectangle {
                    id: shimmer
                    width: parent.width * 0.45
                    height: parent.height
                    color: "#F9FAFB"
                    radius: 16
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

                // Optional soft icon while loading
                // Label {
                //     anchors.centerIn: parent
                //     text: "🏠"
                //     font.pixelSize: 28
                //     opacity: 0.25
                // }
            }
        }

        // INFO SECTION
        Column {
            id: infoSection
            width: parent.width
            spacing: 2
            leftPadding: 2
            rightPadding: 2
            visible: root.isInfoSectionVisible

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
                    text: root.title
                    font.pixelSize: 11
                    color: "#F59E0B"          // amber/gold
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
            console.log("cjecking ifthe amenenites are avalaiba from propertydelefate");
            console.log(root.amenities[0]);
            NavUtils.push(Qt.resolvedUrl("./PropertyDelegateDetails.qml"), {
                propertyId: root.propertyId,
                propertyTitle: root.title,
                location: root.location,
                price: root.price,
                status: root.status,
                isVerified: root.isVerified,
                imageUrl: root.imageUrl,
                amenities: root.amenities
            });
            root.clicked();
        }
    }
}
