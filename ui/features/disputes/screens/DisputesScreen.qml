import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../components/indicators"

Item {
    id: root

    property string pageTitle: qsTr("Open disputes")
    property bool showHeader: true
    property bool showBack: true

    property bool refreshing: false
    property bool loading: false
    property double _refreshStart: 0
    property int _minVisible: 600

    readonly property bool busy: DisputesListViewModel.isLoading

    Timer {
        id: hideLoaderTimer
        interval: root._minVisible
        repeat: false
        onTriggered: root.loading = false
    }

    function refresh() {
        if (root.refreshing || root.loading)
            return
        root._refreshStart = Date.now()
        root.refreshing = true
        root.loading = true
        DisputesListViewModel.getDisputes()
    }

    function onRequestsSettled() {
        if (root.busy)
            return
        root.refreshing = false
        var elapsed = Date.now() - root._refreshStart
        var remain = root._minVisible - elapsed
        if (remain > 0) {
            hideLoaderTimer.interval = remain
            hideLoaderTimer.restart()
        } else {
            hideLoaderTimer.stop()
            root.loading = false
        }
    }

    property bool pullArmed: false

    function armIfPulled() {
        if (flick.dragging && flick.contentY <= -56)
            root.pullArmed = true
    }

    function handlePullRelease() {
        if (root.pullArmed && !root.refreshing && !root.loading) {
            root.refresh()
            flick.returnToBounds()
        }
        root.pullArmed = false
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: DisputesListViewModel
        function onIsLoadingChanged(loading) { root.onRequestsSettled() }
    }

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: disputesPage.implicitHeight + 48
            clip: true
            boundsBehavior: Flickable.DragAndOvershootBounds

            onContentYChanged: root.armIfPulled()
            onDragEnded: root.handlePullRelease()

            ScrollBar.vertical: ScrollBar { }

            DisputesPage {
                id: disputesPage
                x: Math.max(12, (flick.width - width) / 2)
                y: 24
                width: Math.min(flick.width - 24, 520)
            }
        }

        // Non-blocking spinner centered on the page, shown on first load and
        // whenever a pull-to-refresh triggers a backend call.
        AppSpinner {
            visible: root.loading || root.refreshing
            anchors.centerIn: parent
            z: 20
            size: 32
            lineWidth: 3
            color: "#2563EB"
            running: root.loading || root.refreshing
        }
    }
}
