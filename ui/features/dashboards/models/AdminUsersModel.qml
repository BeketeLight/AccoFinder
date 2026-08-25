import QtQuick

Item {
    id: root

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
        for (var i = 0; i < usersModelId.count; i++) {
            var u = usersModelId.get(i)
            if (u.userId === userId) {
                u.active = active
                usersModelId.set(i, u)
                break
            }
        }
        refresh()
    }

    function setUserRole(userId, newRole) {
        for (var i = 0; i < usersModelId.count; i++) {
            var u = usersModelId.get(i)
            if (u.userId === userId) {
                u.role = newRole
                usersModelId.set(i, u)
                break
            }
        }
        refresh()
    }

    function findByEmail(email) {
        for (var i = 0; i < usersModelId.count; i++) {
            var u = usersModelId.get(i)
            if (u.email.toLowerCase() === email.toLowerCase()) {
                return { userId: u.userId, name: u.name, email: u.email,
                         phone: u.phone, role: u.role, joined: u.joined, active: u.active }
            }
        }
        return null
    }

    function addUser(payload) {
        var id = "U-" + String(100 + usersModelId.count + 1).padStart(3, "0")
        usersModelId.append({
            userId: id,
            name: payload.firstName + " " + payload.surname,
            email: payload.email,
            phone: payload.phone,
            role: payload.role || "CLIENT",
            joined: Qt.formatDate(new Date(), "dd MMM yyyy"),
            active: true,
            password: payload.password || "",
            residentialAddress: payload.residentialAddress || ""
        })
        refresh()
        return id
    }

    ListModel {
        id: usersModelId

        ListElement { userId: "U-001"; name: "Chikondi Banda"; email: "chikondi@accofinder.mw"; phone: "+265 991 000 111"; role: "CLIENT"; joined: "12 Jan 2026"; active: true; password: ""; residentialAddress: "" }
        ListElement { userId: "U-002"; name: "Memory Phiri"; email: "memory.p@gmail.com"; phone: "+265 888 234 567"; role: "CLIENT"; joined: "03 Feb 2026"; active: true; password: ""; residentialAddress: "" }
        ListElement { userId: "U-003"; name: "Yankho Mwale"; email: "yankho.mwale@gmail.com"; phone: "+265 995 444 010"; role: "AGENT"; joined: "18 Dec 2025"; active: true; password: ""; residentialAddress: "" }
        ListElement { userId: "U-004"; name: "Chilumba Chirwa"; email: "chilumba.c@gmail.com"; phone: "+265 993 771 220"; role: "AGENT"; joined: "27 Jan 2026"; active: false; password: ""; residentialAddress: "" }
        ListElement { userId: "U-005"; name: "Alinafe Buleya"; email: "alinafe.b@yahoo.com"; phone: "+265 881 909 145"; role: "CLIENT"; joined: "09 Nov 2025"; active: true; password: ""; residentialAddress: "" }
        ListElement { userId: "U-006"; name: "Tapiwa Gondwe"; email: "tapiwa.g@gmail.com"; phone: "+265 999 120 334"; role: "CLIENT"; joined: "22 Feb 2026"; active: true; password: ""; residentialAddress: "" }
        ListElement { userId: "U-007"; name: "Blessings Nkhoma"; email: "blessings.n@gmail.com"; phone: "+265 884 556 721"; role: "CLIENT"; joined: "14 Mar 2026"; active: false; password: ""; residentialAddress: "" }
        ListElement { userId: "U-008"; name: "Fatsani Zimba"; email: "fatsani.z@gmail.com"; phone: "+265 997 310 845"; role: "AGENT"; joined: "05 Apr 2026"; active: true; password: ""; residentialAddress: "" }
    }

    ListModel { id: viewModelId }

    Component.onCompleted: refresh()
}
