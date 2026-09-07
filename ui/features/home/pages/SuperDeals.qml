import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../delegates"

Item {
    id: root
    width: 355
    height: 190

    Layout.alignment: Qt.AlignHCenter
    // ========== DUMMY DATA ==========
    // Fixed card width
    property int cardWidth: 220
    property int cardHeight: 130
    property alias model: dealsList.model
    readonly property int cardSpacing: 12
    property string title: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Label {
                text: root.title ? root.title : "🔥 Super Deals"
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
                Layout.fillWidth: true
            }
        }

        // Horizontal ListView with peek effect
        ListView {
            id: dealsList
            Layout.fillWidth: true
            Layout.preferredHeight: root.cardHeight + 10
            orientation: ListView.Horizontal
            spacing: 12
            clip: true

            // === This creates the peek effect ===
            preferredHighlightBegin: (width - root.cardWidth) / 2
            preferredHighlightEnd: (width - root.cardWidth) / 2 /*+ root.cardWidth*/
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 250
            snapMode: ListView.SnapToItem
            delegate: Item {
                width: root.cardWidth
                height: root.cardHeight

                PropertyCardDelegate {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    propertyId: model.propertyId
                    title: model.title
                    location: model.location
                    price: model.price
                    imageUrl: model.imageUrl
                    imageUrls: model.imageUrls   // add if available in dummy data
                    isVerified: model.isVerified
                }
            }
        }
    }
}
