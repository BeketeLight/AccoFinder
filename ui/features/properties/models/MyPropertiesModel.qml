import QtQuick 2.15

Item {
    id: root

    // Delegate-facing API preserved. Real data is sourced from the C++
    // PropertyViewModel (PropertyController -> /house-listing/ API). Filtering
    // still happens in QML into a lightweight viewModel so delegates work.
    // status values mirror the backend enum: VERIFIED / PENDING / REJECTED
    property string statusFilter: "All"
    property string searchText: ""
    property int resultCount: 0

    readonly property alias propertiesModel: propertiesModelId
    readonly property alias filterChipsModel: filterChipsModelId

    ListModel {
        id: propertiesModelId
    }

    ListModel {
        id: filterChipsModelId
        ListElement { label: "All" }
        ListElement { label: "Verified" }
        ListElement { label: "Pending" }
        ListElement { label: "Draft" }
        ListElement { label: "Rejected" }
    }

    function prettyStatus(s) {
        var v = String(s).toUpperCase()
        if (v === "VERIFIED") return qsTr("Verified")
        if (v === "PENDING") return qsTr("Pending")
        if (v === "REJECTED") return qsTr("Rejected")
        if (v === "DRAFT") return qsTr("Draft")
        return v
    }

    function applyFilters() {
        var count = 0
        var q = root.searchText.trim().toLowerCase()
        var wanted = root.statusFilter === "All" ? "" : root.statusFilter.toUpperCase()
        for (var i = 0; i < propertiesModelId.count; i++) {
            var it = propertiesModelId.get(i)
            var okStatus = wanted.length === 0 || it.status === wanted
            var okSearch = q.length === 0
                          || it.title.toLowerCase().indexOf(q) !== -1
                          || it.district.toLowerCase().indexOf(q) !== -1
                          || it.village.toLowerCase().indexOf(q) !== -1
            var match = okStatus && okSearch
            propertiesModelId.setProperty(i, "matches", match)
            if (match)
                count++
        }
        root.resultCount = count
    }

    function findProperty(matchValue, matchRole) {
        for (var i = 0; i < propertiesModelId.count; i++) {
            var it = propertiesModelId.get(i)
            if (String(it[matchRole]) === String(matchValue))
                return it
        }
        return null
    }

    function setPropertyStatus(propertyId, status, reason = "") {
        for (var i = 0; i < propertiesModelId.count; i++) {
            var it = propertiesModelId.get(i)
            if (it.propertyId === propertyId) {
                it.status = status
                if (reason && String(reason).length > 0)
                    it.rejectionReason = reason
                propertiesModelId.set(i, it)
                break
            }
        }
    }

    function modelToArray(value) {
        var arr = []
        if (!value)
            return arr
        if (value.count !== undefined) {
            for (var i = 0; i < value.count; i++) {
                var el = value.get(i)
                // Plain-string var roles come back wrapped as { modelData: "..." }
                arr.push(el)
            }
        } else {
            for (var j = 0; j < value.length; j++)
                arr.push(value[j])
        }
        return arr
    }

    function registrationPayloadFor(matchValue, matchRole) {
        var it = findProperty(matchValue, matchRole)
        if (!it)
            return null
        return {
            propertyId: it.propertyId,
            title: it.title,
            description: it.description,
            physicalAddress: {
                district: it.district,
                village: it.village
            },
            verificationStatus: String(it.status),
            rejectionReason: it.rejectionReason || "",
            amenities: it.propertyId ? PropertyViewModel.propertyListModel.amenitiesFor(it.propertyId) : [],
            isActive: true,
            price: it.price,
            landlord: it.landlord,
            landlordPhone: it.landlordPhone,
            ownerName: it.ownerName || "",
            ownerPhone: it.ownerPhone || "",
            rooms: modelToArray(it.roomsData),
            photos: modelToArray(it.photosData)
        }
    }

    function reload() {
        propertiesModelId.clear()
        var m = PropertyViewModel.propertyListModel
        var cppSize = m ? m.size() : 0
        for (var i = 0; i < cppSize; i++) {
            var item = m.at(i)
            var pid = item.propertyId
            propertiesModelId.append({
                propertyId: pid, title: item.title,
                district: item.district, village: item.village,
                price: item.price, status: item.status,
                rooms: item.roomCount, matches: true,
                rejectionReason: item.rejectionReason || "",
                amenities: m.amenitiesFor(pid),
                landlord: item.landlord || item.landlordPhone || "",
                landlordPhone: item.landlordPhone || "",
                ownerName: item.ownerName || "",
                ownerPhone: item.ownerPhone || "",
                description: item.description || "",
                roomsData: pid ? RoomViewModel.roomsForProperty(pid) : [], photosData: []
            })
        }
        root.applyFilters()
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onCountChanged() { root.reload() }
        function onDataChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Connections {
        target: RoomViewModel.roomListModel
        function onCountChanged() { root.reload() }
        function onModelReset() { root.reload() }
    }

    Component.onCompleted: {
        // Sync immediately from whatever is already cached in the shared C++
        // model, then trigger a fresh fetch. This prevents the page from
        // showing null if the initial network call fails or is slow.
        root.reload()
        PropertyViewModel.getProperties()
        // Rooms are stored in a separate /rooms/ collection (not embedded in
        // the property document), so fetch them to hydrate per-property counts
        // and the detail page's room list.
        RoomViewModel.loadRooms()
    }
}
