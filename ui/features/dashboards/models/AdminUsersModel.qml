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

    function reload() {
        usersModelId.clear()
        var m = UserViewModel.userListModel
        for (var i = 0; i < m.size; i++) {
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
        UserViewModel.getUsers()
    }
}
