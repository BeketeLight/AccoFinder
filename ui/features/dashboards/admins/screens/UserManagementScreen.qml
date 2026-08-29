import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/indicators"

Item {
    id: root

    property string pageTitle: qsTr("User Management")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal userToggled(var userId, var name, var active)

    property bool refreshing: false

    // Pull-to-refresh re-fetches the user list from the backend. The result
    // flows back through UserViewModel's signals into the shared C++ model,
    // which the QML AdminUsersModel mirrors.
    function refresh() {
        if (root.refreshing)
            return
        root.refreshing = true
        UserViewModel.getUsers()
    }

    property bool pullArmed: false

    function armIfPulled() {
        if (flick.dragging && flick.contentY <= -56)
            root.pullArmed = true
    }

    function handlePullRelease() {
        if (root.pullArmed && !root.refreshing) {
            root.refresh()
            flick.returnToBounds()
        }
        root.pullArmed = false
    }

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: page.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            onContentYChanged: root.armIfPulled()
            onDragEnded: root.handlePullRelease()

            // Pull-to-refresh indicator: a small strip shown at the top while
            // the content is dragged down (or while a refresh is running).
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

            UserManagementPage {
                id: page

                Component.onCompleted: Qt.callLater(function() {console.log("UMSZ", "page", "root=" + root.width + "x" + root.height + " flick=" + flick.width + " page=" + width + " x=" + x) })
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                onUserToggled: (userId, name, active) => root.userToggled(userId, name, active)
            }
        }

        // Non-blocking spinner while the user list is being fetched, but only
        // when there is no data on screen yet. Once the list is populated the
        // centered spinner stays hidden, so role/pull refreshes don't cause it
        // to flash — role changes show their own per-card loader instead.
        AppSpinner {
            visible: UserViewModel.isLoading && page.usersModel.viewModel.count === 0
            anchors.centerIn: parent
            z: 20
            size: 32
            lineWidth: 3
            color: "#2563EB"
            running: visible
        }
    }

    Connections {
        target: UserViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshing = false
        }
    }
}
