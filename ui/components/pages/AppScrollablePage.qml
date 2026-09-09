import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../indicators"

// Shared scrollable page shell used by the dashboard screens (and reusable by
// any feature). Wraps a Page with the standard canvas color, a Flickable with a
// vertical scrollbar, horizontally-centered content capped at a max width, an
// optional centered non-blocking spinner, and an optional pull-to-refresh strip.
//
// Usage:
//   AppScrollablePage {
//       loading: SomeViewModel.isLoading
//       pullEnabled: true
//       refreshing: root.busy
//       onRefreshRequested: refresh()
//       ChildPage { id: child; onSomeSignal: ... }
//   }
Page {
    id: root

    // Injected child content is re-parented into the centered column. The name
    // intentionally avoids clashing with QQuickPane's own contentData member.
    default property alias pageContent: contentColumn.data

    property bool loading: false
    property bool pullEnabled: false
    property bool refreshing: false
    property int maxContentWidth: 520
    property int contentTopMargin: 24
    property int contentBottomPadding: 48

    // Emitted when the user pulls-to-refresh and a refresh is not already in
    // flight. The screen should kick off its backend load here.
    signal refreshRequested()

    background: Rectangle { color: "#F8FAFC" }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + root.contentBottomPadding
        clip: true
        boundsBehavior: Flickable.DragAndOvershootBounds

        ScrollBar.vertical: ScrollBar { }

        onContentYChanged: {
            if (root.pullEnabled && flick.dragging && flick.contentY <= -56)
                pullArmed = true
        }
        onDragEnded: {
            if (root.pullEnabled && pullArmed && !root.refreshing) {
                pullArmed = false
                root.refreshRequested()
                flick.returnToBounds()
            } else {
                pullArmed = false
            }
        }

        property bool pullArmed: false

        // Pull-to-refresh indicator strip shown at the top while dragging down
        // or while a refresh completes.
        ColumnLayout {
            id: pullIndicator
            z: 10
            anchors.horizontalCenter: parent.horizontalCenter
            y: -40 + Math.abs(Math.min(0, flick.contentY))
            spacing: 4
            visible: root.refreshing || flick.contentY < -2
            opacity: Math.min(1, Math.abs(Math.min(0, flick.contentY)) / 56)

            AppSpinner {
                Layout.alignment: Qt.AlignHCenter
                size: 20
                lineWidth: 2
                color: "#9CA3AF"
                running: root.refreshing
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.refreshing ? qsTr("Refreshing…") : qsTr("Pull to refresh")
                color: "#9CA3AF"
                font.pixelSize: 11
            }
        }

        ColumnLayout {
            id: contentColumn
            x: Math.max(12, (flick.width - width) / 2)
            y: root.contentTopMargin
            width: flick.width > 48 ? Math.min(flick.width - 24, root.maxContentWidth) : root.maxContentWidth
        }
    }

    // Centered non-blocking spinner shown while `loading` is true.
    AppSpinner {
        visible: root.loading
        anchors.centerIn: parent
        z: 20
        size: 32
        lineWidth: 3
        color: "#2563EB"
        running: root.loading
    }
}
