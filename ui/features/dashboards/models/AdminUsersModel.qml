import QtQuick

Item {
    id: root

    // Delegate-facing API preserved. Real data is sourced from the C++
    // UserViewModel (UserController -> /users/ API). Filtering still happens
    // in QML into a lightweight viewModel so delegates keep working.
    readonly property alias usersModel: usersModelId
    readonly property alias viewModel: viewModelId

    property string searchQuery: ""
    property string roleFilter: "ALL"   // ALL | CLIENT | AGENT
    property int activeCount: 0
    property int suspendedCount: 0

    // userId of the card currently waiting on a role-change backend call. The
    // card shows an inline loader while it is set; it is cleared when the C++
    // UserViewModel finishes loading (success or error), so only the affected
    // row shows progress instead of the whole page.
    property string busyUserId: ""

    function refresh() {
        var active = 0
        var suspended = 0
        for (var i = 0; i < usersModelId.count; i++) {
            var u = usersModelId.get(i)
            if (u.active) active++
            else suspended++
        }
        root.activeCount = active
        root.suspendedCount = suspended
        applyFilters()
    }

    function applyFilters() {
        viewModelId.clear()
        var q = root.searchQuery.toLowerCase()
        for (var i = 0; i < usersModelId.count; i++) {
            var u = usersModelId.get(i)
            if (root.roleFilter !== "ALL" && u.role !== root.roleFilter)
                continue
            if (q.length > 0 &&
                u.name.toLowerCase().indexOf(q) === -1 &&
                u.email.toLowerCase().indexOf(q) === -1)
                continue
            viewModelId.append({
                userId: u.userId, name: u.name, email: u.email,
                phone: u.phone, role: u.role, joined: u.joined,
                active: u.active
            })
        }
    }

    function setAccountActive(userId, active) {
        UserViewModel.setActive(userId, active)
    }

    function setUserRole(userId, newRole) {
        root.busyUserId = userId
        UserViewModel.updateRole(userId, newRole)
    }

    function findByEmail(email) {
        return UserViewModel.findUserByEmail(email)
    }

    function addUser(payload) {
        UserViewModel.addUser(payload.firstName || "",
                              payload.surname || "",
                              payload.email || "",
                              payload.phone || "",
                              payload.role || "CLIENT",
                              payload.residentialAddress || "")
    }

    ListModel {
        id: usersModelId
    }

    ListModel {
        id: viewModelId
    }

    Connections {
        target: UserViewModel.userListModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Connections {
        target: UserViewModel
        function onUserError() {
            root.busyUserId = ""
        }
        // Clearing on isLoading dropping is deterministic: every role-change
        // call (and the initial list fetch) toggles isLoading true then false
        // on completion, so the loader always turns off even when the update
        // doesn't actually change the model data.
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.busyUserId = ""
        }
    }

    function reload() {
        usersModelId.clear()
        var m = UserViewModel.userListModel
        var cppSize = m ? m.size() : 0
        for (var i = 0; i < cppSize; i++) {
            var item = m.at(i)
            usersModelId.append({
                userId: item.userId, name: item.name, email: item.email,
                phone: item.phone, role: item.role, joined: item.joined,
                active: item.active
            })
        }
        root.refresh()
    }

    Component.onCompleted: {
        // Sync immediately from whatever is already cached in the shared C++
        // model, then trigger a fresh fetch. This prevents the page from
        // showing null if the initial network call fails or is slow.
        root.reload()
        UserViewModel.getUsers()
    }
}
