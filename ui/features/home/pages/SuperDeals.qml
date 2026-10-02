import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"

Item {
    id: root

    // ---------------------------------------------------------------------
    // Public API
    // ---------------------------------------------------------------------
    property int cardWidth: 220
    property int cardHeight: 130
    property string title: ""
    property bool infoSectionVisible: true

    // Real model from outside.
    property var model: null

    // Kept for API compatibility with callers that already pass it.
    property var propertiesModelRef: null

    // ---------------------------------------------------------------------
    // How many times to repeat the model for the fake-circular effect.
    // Only applies when the real model has more than one row.
    // ---------------------------------------------------------------------
    readonly property int loopCopies: 3

    // Real number of rows in the source model.
    readonly property int realCount: model && model.count !== undefined ? model.count : 0

    // The loop is only meaningful with 2+ rows: with 1 row there is no
    // "next" to wrap to, and triplicating the row looks wrong. With 0 rows
    // there is nothing to show.
    readonly property bool loopEnabled: realCount > 1

    // ---------------------------------------------------------------------
    // Layout constants — one source of truth.
    // ---------------------------------------------------------------------
    readonly property int _columnSpacing: 5
    readonly property int _listExtraPad: 37
    readonly property int _bottomPadding: 8

    // ---------------------------------------------------------------------
    // Implicit size — matches what the inner layout renders.
    // ---------------------------------------------------------------------
    implicitWidth: parent && parent.width > 0 ? parent.width : 355
    implicitHeight: headerRow.implicitHeight + (headerRow.visible ? _columnSpacing : 0) + (cardHeight + _listExtraPad) + _bottomPadding

    // ---------------------------------------------------------------------
    // Loop model — the actual model the ListView renders.
    // Rebuilt whenever the source changes, OR when loopEnabled flips.
    // ---------------------------------------------------------------------
    ListModel {
        id: loopModel
    }

    function rebuildLoopModel() {
        loopModel.clear();

        if (realCount <= 0)
            return;

        // Single-item case: show the real row once, no duplication.
        // This is what makes a lone recent listing appear exactly once,
        // centred, with nothing to scroll to.
        if (!loopEnabled) {
            for (var i = 0; i < root.realCount; ++i) {
                var single = root.model.get(i);
                loopModel.append({
                    propertyId: single.propertyId,
                    title: single.title,
                    location: single.location,
                    price: single.price,
                    imageUrl: single.imageUrl,
                    imageUrls: single.imageUrls,
                    status: single.status,
                    isVerified: single.isVerified
                });
            }
            return;
        }

        // Multi-item case: triplicate for the fake-circular carousel.
        for (var copy = 0; copy < root.loopCopies; ++copy) {
            for (var j = 0; j < realCount; ++j) {
                var item = root.model.get(j);
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

    // Rebuild when the source reference is assigned.
    onModelChanged: Qt.callLater(rebuildLoopModel)

    // Rebuild when the source's row count changes (rows added / removed).
    Connections {
        target: root.model
        enabled: root.model !== null && root.model.count !== undefined
        function onCountChanged() {
            Qt.callLater(root.rebuildLoopModel);
        }
        function onModelReset() {
            Qt.callLater(root.rebuildLoopModel);
        }
        function onDataChanged() {
            Qt.callLater(root.rebuildLoopModel);
        }
    }

    // Rebuild when loopEnabled flips (i.e. realCount crosses 1).
    onLoopEnabledChanged: Qt.callLater(rebuildLoopModel)

    Component.onCompleted: Qt.callLater(rebuildLoopModel)

    // ---------------------------------------------------------------------
    // Content
    // ---------------------------------------------------------------------
    ColumnLayout {
        id: innerLayout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        spacing: root._columnSpacing

        // Header row.
        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            // Layout.leftMargin: 16
            // Layout.rightMargin: 16
            Layout.preferredHeight: headerLabel.implicitHeight
            visible: headerLabel.text.length > 0

            Label {
                id: headerLabel
                text: root.title
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        ListView {
            id: dealsList
            Layout.fillWidth: true
            Layout.preferredHeight: root.cardHeight + root._listExtraPad
            orientation: ListView.Horizontal
            spacing: 12
            clip: true

            // The loop model. In the single-item case it holds exactly one
            // row (no duplication). In the multi-item case it holds
            // loopCopies × realCount rows.
            model: loopModel

            // Peek: centre the current card, leave room either side.
            // StrictlyEnforceRange is what makes the "current" card stay
            // locked to the centre — keep it, it's the point of the
            // carousel. It behaves correctly for a 1-row model too.
            preferredHighlightBegin: (width - root.cardWidth) / 2
            preferredHighlightEnd: (width - root.cardWidth) / 2
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 250
            snapMode: ListView.SnapToItem

            // Centre-on-start only matters when the loop is active — it
            // positions the current card inside the middle copy so the user
            // can swipe both ways. With a single-item model, this is a no-op.
            function positionToStart() {
                if (!root.loopEnabled)
                    return;
                if (width <= 0 || realCount <= 0 || loopModel.count === 0)
                    return;
                var local = Math.min(2, realCount - 1);
                var start = realCount + local;          // middle block
                currentIndex = start;
                positionViewAtIndex(start, ListView.Center);
            }

            Component.onCompleted: Qt.callLater(positionToStart)
            onCountChanged: Qt.callLater(positionToStart)
            onWidthChanged: Qt.callLater(positionToStart)

            // Fake-circular: when near either end, jump by one block.
            // Only fires when the loop is active — a single-row model has
            // nowhere to jump to.
            onCurrentIndexChanged: {
                if (!root.loopEnabled)
                    return;
                if (realCount <= 1)
                    return;
                if (currentIndex < realCount) {
                    currentIndex = currentIndex + realCount;
                } else if (currentIndex >= realCount * 2) {
                    currentIndex = currentIndex - realCount;
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
