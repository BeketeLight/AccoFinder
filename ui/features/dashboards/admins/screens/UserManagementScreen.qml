import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/pages"

Item {
    id: root

    property string pageTitle: qsTr("User Management")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal userToggled(var userId, var name, var active)

    // True while a full re-fetch of the user list is running (e.g. on pull-to-
    // refresh). Drives the pull-to-refresh strip in AppScrollablePage.
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

    AppScrollablePage {
        anchors.fill: parent
        pullEnabled: true
        refreshing: root.refreshing
        onRefreshRequested: root.refresh()

        // Only show the centered spinner when there is no data on screen yet.
        // Once the list is populated the centered spinner stays hidden, so
        // role/pull refreshes don't cause it to flash.
        loading: UserViewModel.isLoading && page.usersModel.viewModel.count === 0

        UserManagementPage {
            id: page
            Layout.fillWidth: true

            onUserToggled: (userId, name, active) => root.userToggled(userId, name, active)
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
