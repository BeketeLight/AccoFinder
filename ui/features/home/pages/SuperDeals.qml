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
    property string title: ""
    property bool infoSectionVisible: true

    // Real model from outside
    property var model: null

    // How many times we repeat the model for looping
    readonly property int loopCopies: 3

    ListModel {
        id: loopModel
    }

    function rebuildLoopModel() {
        loopModel.clear();
        if (!root.model)
            return;
        var n = root.model.count !== undefined ? root.model.count : 0;
        if (n <= 0)
            return;
        for (var copy = 0; copy < root.loopCopies; ++copy) {
            for (var i = 0; i < n; ++i) {
                var item = root.model.get(i);
                loopModel.append({
                    propertyId: item.propertyId,
                    title: item.title,
                    location: item.location,
                    price: item.price,
                    imageUrl: item.imageUrl,
                    imageUrls: item.imageUrls,
                    status: item.status,
                    isVerified: item.isVerified
                });
            }
        }
    }

    onModelChanged: rebuildLoopModel()
    Component.onCompleted: rebuildLoopModel()

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            Label {
                text: root.title
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
                Layout.fillWidth: true
            }
        }

        ListView {
            id: dealsList
            Layout.fillWidth: true
            Layout.preferredHeight: root.cardHeight + 10
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            model: loopModel

            // Peek: full card centered, partial left/right
            preferredHighlightBegin: (width - root.cardWidth) / 2
            preferredHighlightEnd: (width - root.cardWidth) / 2
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 250
            snapMode: ListView.SnapToItem

            // Start in the middle copy, index 2 of the real list
            function positionToStart() {
                var n = root.model && root.model.count !== undefined ? root.model.count : 0;
                if (width <= 0 || n <= 0 || loopModel.count === 0)
                    return;
                var local = Math.min(2, n - 1);
                var start = n + local;          // middle block
                currentIndex = start;
                positionViewAtIndex(start, ListView.Center);
            }

            Component.onCompleted: Qt.callLater(positionToStart)
            onCountChanged: Qt.callLater(positionToStart)
            onWidthChanged: Qt.callLater(positionToStart)

            // Fake circular: when near either end, jump by one block
            onCurrentIndexChanged: {
                var n = root.model && root.model.count !== undefined ? root.model.count : 0;
                if (n <= 1)
                    return;
                if (currentIndex < n) {
                    // near start → jump forward one block
                    currentIndex = currentIndex + n;
                } else if (currentIndex >= n * 2) {
                    // near end → jump back one block
                    currentIndex = currentIndex - n;
                }
            }

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
                    isInfoSectionVisible: root.infoSectionVisible
                    imageUrl: model.imageUrl
                    imageUrls: model.imageUrls
                    isVerified: model.isVerified
                }
            }
        }
    }
}
