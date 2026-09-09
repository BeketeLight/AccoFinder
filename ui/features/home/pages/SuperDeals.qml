import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"

Item {
    id: root

    width: 355
    height: 190
    Layout.alignment: Qt.AlignHCenter

    property int cardWidth: 220
    property int cardHeight: 130
    property alias model: dealsView.model
    property string title: ""
    property bool infoSectionVisible

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

        // Circular carousel
        PathView {
            id: dealsView
            Layout.fillWidth: true
            Layout.preferredHeight: root.cardHeight + 10
            clip: true

            pathItemCount: 3
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange
            snapMode: PathView.SnapToItem

            // Card ~58% of width → real side peeks + gaps
            property real visualCardWidth: width * 0.58

            path: Path {
                startX: 0
                startY: dealsView.height / 2
                PathLine {
                    x: dealsView.width
                    y: dealsView.height / 2
                }
            }

            delegate: Item {
                width: dealsView.visualCardWidth
                height: root.cardHeight

                scale: PathView.isCurrentItem ? 1.0 : 0.94
                opacity: PathView.isCurrentItem ? 1.0 : 0.9
                z: PathView.isCurrentItem ? 1 : 0

                PropertyCardDelegate {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    propertyId: model.propertyId
                    isInfoSectionVisible: root.infoSectionVisible
                    imageUrl: model.imageUrl
                    imageUrls: model.imageUrls
                    isVerified: model.isVerified
                }
            }
        }
    }
}
