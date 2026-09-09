import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: roomCard
    property string roomId: ""
    property string roomType: ""
    property real price: 0
    property bool isAvailable: true
    property string roomSize: ""
    property string imageUrl: ""
    property string propertyTitle: ""
    property string location: ""

    signal clicked

    width: 150
    height: 170
    radius: 12
    color: "#FFFFFF"
    border.color: "#E5E7EB"
    border.width: 1

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.5
        shadowColor: "#20000000"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Room image
        Rectangle {
            id: borderRect
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: 8
            color: "#F5F5F5"
            clip: true

            Image {
                id: roomImg
                anchors.fill: parent
                source: roomCard.imageUrl || "../../assets/images/placeholder.png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true

                Rectangle {
                    anchors.fill: parent
                    color: "#F5F5F5"
                    visible: parent.status !== Image.Ready
                    Label {
                        anchors.centerIn: parent
                        text: "🛏️"
                        font.pixelSize: 28
                        opacity: 0.3
                    }
                }
            }

            // Availability badge
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 4
                height: 18
                radius: 9
                width: availText.width + 10
                color: roomCard.isAvailable ? "#22C55E" : "#EF4444"

                Label {
                    id: availText
                    anchors.centerIn: parent
                    text: roomCard.isAvailable ? "Open" : "Booked"
                    color: "white"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
            // ===== SKELETON LOADER (shown while loading) =====
            Rectangle {
                id: skeleton
                anchors.fill: parent
                anchors.margins: borderRect.border.width
                radius: 14
                visible: roomImg.status !== Image.Ready
                color: "#E5E7EB"
                clip: true

                // Moving shimmer bar
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

        // Room type
        Label {
            text: roomCard.roomType
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: "#1F2937"
            elide: Text.ElideRight
            Layout.fillWidth: true
            maximumLineCount: 1
        }

        // Price
        Label {
            text: "MWK " + Number(roomCard.price).toLocaleString(Qt.locale(), "f", 0)
            font.pixelSize: 14
            font.bold: true
            color: "#2563EB"
        }

        // Size
        RowLayout {
            spacing: 4
            Label {
                text: "📐"
                font.pixelSize: 10
            }
            Label {
                text: roomCard.roomSize || "N/A"
                font.pixelSize: 10
                color: "#6B7280"
            }
            Item {
                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            roomCard.clicked();
        }
    }
}
