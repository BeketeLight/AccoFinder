import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../../utils/ImageUtils.js" as ImageUtils
import "../../../utils/NavigationUtils.js" as NavUtils

// One saved room card. All data comes from a SavedRoomsModel row — which came
// from the home rooms model. Tapping the card opens QuartersDetailDelegate with
// the correct propertyId so the booking flow works exactly as from home.
Item {
    id: root

    required property string roomId
    required property string propertyId
    required property string quarterType
    required property string quarterTitle
    required property real quarterPrice
    required property string location
    required property string imageUrl
    required property bool available
    required property bool holdActive
    required property var holdExpiresAt

    signal removeRequested(string roomId)

    implicitHeight: 116

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#FFFFFF"
        border.color: "#E5E7EB"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // ---------- Thumbnail ----------
            Rectangle {
                Layout.preferredWidth: 96
                Layout.preferredHeight: 96
                radius: 10
                color: "#F1F3F4"
                clip: true

                Image {
                    id: thumb
                    anchors.fill: parent
                    source: root.imageUrl ? ImageUtils.cachedSource(root.imageUrl) : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    visible: status === Image.Ready

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: thumbMask
                    }
                }

                Rectangle {
                    id: thumbMask
                    anchors.fill: parent
                    radius: 10
                    visible: false
                    layer.enabled: true
                }

                Label {
                    anchors.centerIn: parent
                    visible: thumb.status !== Image.Ready
                    text: "🛏️"
                    font.pixelSize: 28
                    opacity: 0.35
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 6
                    height: 18
                    radius: 9
                    width: availLabel.implicitWidth + 12
                    color: !root.available ? "#EF4444" : root.holdActive ? "#F59E0B" : "#22C55E"

                    Label {
                        id: availLabel
                        anchors.centerIn: parent
                        text: !root.available ? qsTr("Booked") : root.holdActive ? qsTr("On Hold") : qsTr("Open")
                        color: "#FFFFFF"
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }

            // ---------- Details ----------
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 3

                Label {
                    Layout.fillWidth: true
                    text: root.quarterType
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: "#1F2937"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Label {
                    Layout.fillWidth: true
                    visible: root.quarterTitle.length > 0
                    text: root.quarterTitle
                    font.pixelSize: 12
                    color: "#6B7280"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: root.location.length > 0

                    Image {
                        source: "qrc:/ui/assets/location-2955.svg"
                        sourceSize.width: 12
                        sourceSize.height: 12
                        width: 12
                        height: 12
                        fillMode: Image.PreserveAspectFit
                    }
                    Label {
                        Layout.fillWidth: true
                        text: root.location
                        font.pixelSize: 11
                        color: "#9CA3AF"
                        elide: Text.ElideRight
                    }
                }

                Label {
                    text: "MWK " + Number(root.quarterPrice).toLocaleString(Qt.locale(), "f", 0)
                    font.pixelSize: 15
                    font.bold: true
                    color: "#2563EB"
                }
            }

            // ---------- Remove ----------
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignTop
                radius: 16
                color: "#FFFFFF"
                border.color: "#E5E7EB"
                border.width: 1

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/ui/assets/favorite-filled.svg"
                    sourceSize.width: 18
                    sourceSize.height: 18
                    width: 18
                    height: 18
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.removeRequested(root.roomId)
                }
            }
        }

        // Whole-card tap → room detail page, with the correct parent propertyId.
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: {
                NavUtils.push(Qt.resolvedUrl("../../../home/delegates/QuartersDetailDelegate.qml"), {
                    quarterId: root.roomId,
                    propertyId: root.propertyId,
                    quarterType: root.quarterType,
                    quarterTitle: root.quarterTitle,
                    quarterPrice: root.quarterPrice,
                    location: root.location,
                    roomImage: root.imageUrl,
                    isquarterAvailable: root.available,
                    isOnHold: root.holdActive,
                    holdExpiresAt: root.holdExpiresAt
                });
            }
        }
    }
}
