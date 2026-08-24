import QtQuick 2.15

Item {
    id: root

    property string statusFilter: "All"
    property string searchText: ""
    property int resultCount: 0

    readonly property alias propertiesModel: propertiesModelId
    readonly property alias filterChipsModel: filterChipsModelId

    Component.onCompleted: root.applyFilters()

    ListModel {
        id: filterChipsModelId
        ListElement { label: "All" }
        ListElement { label: "Verified" }
        ListElement { label: "Pending" }
        ListElement { label: "Draft" }
        ListElement { label: "Rejected" }
    }

    ListModel {
        id: propertiesModelId
        ListElement { propertyId: "P-001"; title: "Sunview Apartments"; location: "Area 47, Lilongwe"; price: 25000; status: "Verified"; rooms: 6; matches: true }
        ListElement { propertyId: "P-002"; title: "Green Court Hostel"; location: "Chichiri, Blantyre"; price: 12000; status: "Verified"; rooms: 12; matches: true }
        ListElement { propertyId: "P-003"; title: "Palm Bungalow"; location: "Namiwawa, Blantyre"; price: 40000; status: "Pending"; rooms: 4; matches: true }
        ListElement { propertyId: "P-004"; title: "Riverside Flats"; location: "Area 49, Lilongwe"; price: 32000; status: "Pending"; rooms: 5; matches: true }
        ListElement { propertyId: "P-005"; title: "Acacia Studio"; location: "Area 15, Lilongwe"; price: 18000; status: "Draft"; rooms: 2; matches: true }
        ListElement { propertyId: "P-006"; title: "Brookline Guest House"; location: "Nyambadwe, Blantyre"; price: 55000; status: "Rejected"; rooms: 8; matches: true }
    }

    function applyFilters() {
        var count = 0
        var q = root.searchText.trim().toLowerCase()
        for (var i = 0; i < propertiesModelId.count; i++) {
            var it = propertiesModelId.get(i)
            var okStatus = (root.statusFilter === "All") || (it.status === root.statusFilter)
            var okSearch = q.length === 0
                          || it.title.toLowerCase().indexOf(q) !== -1
                          || it.location.toLowerCase().indexOf(q) !== -1
            var match = okStatus && okSearch
            propertiesModelId.setProperty(i, "matches", match)
            if (match)
                count++
        }
        root.resultCount = count
    }
}
