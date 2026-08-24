import QtQuick 2.15

Item {
    id: root

    // status values mirror the backend enum: VERIFIED / PENDING / REJECTED
    // plus local-only DRAFT for unsent wizard drafts
    property string statusFilter: "All"
    property string searchText: ""
    property int resultCount: 0

    readonly property alias propertiesModel: propertiesModelId
    readonly property alias filterChipsModel: filterChipsModelId

    // Fields mirror the backend Property schema:
    // title / description / physicalAddress{district,village} / verificationStatus /
    // amenities[] / isActive — plus client extras (price/landlord) and room/media refs.
    Component.onCompleted: {
        propertiesModelId.append([
            {
                propertyId: "P-001", title: "Sunview Apartments",
                district: "Lilongwe", village: "Area 47",
                price: 25000, status: "VERIFIED", rooms: 6, matches: true,
                amenities: "WATER,ELECTRICITY,SECURITY",
                landlord: "James Banda", landlordPhone: "+265 991 100 200",
                description: "Six self-contained rooms with tiled floors, borehole water and a perimeter fence. Walking distance to Area 47 shops.",
                roomsData: [
                    { roomId: 1, roomType: "Self-contained", price: 25000, available: true },
                    { roomId: 2, roomType: "Self-contained", price: 25000, available: false },
                    { roomId: 3, roomType: "Single room", price: 18000, available: true }
                ],
                photosData: []
            },
            {
                propertyId: "P-002", title: "Green Court Hostel",
                district: "Blantyre", village: "Chichiri",
                price: 12000, status: "VERIFIED", rooms: 12, matches: true,
                amenities: "WIFI,WATER,ELECTRICITY",
                landlord: "Esnath Phiri", landlordPhone: "+265 888 456 789",
                description: "Student hostel near Chichiri trading centre. Shared kitchen and yard, water tank backup.",
                roomsData: [
                    { roomId: 4, roomType: "Single room", price: 12000, available: true },
                    { roomId: 5, roomType: "Self-contained", price: 20000, available: true }
                ],
                photosData: []
            },
            {
                propertyId: "P-003", title: "Palm Bungalow",
                district: "Blantyre", village: "Namiwawa",
                price: 40000, status: "PENDING", rooms: 4, matches: true,
                amenities: "PARKING,FURNISHED,WATER",
                landlord: "Chikondi Mwale", landlordPhone: "+265 999 777 888",
                description: "Four-bedroom bungalow in a quiet Namiwawa street with a garden and private parking.",
                roomsData: [
                    { roomId: 6, roomType: "Master bedroom", price: 40000, available: true },
                    { roomId: 7, roomType: "Bedroom", price: 30000, available: true }
                ],
                photosData: []
            },
            {
                propertyId: "P-004", title: "Riverside Flats",
                district: "Lilongwe", village: "Area 49",
                price: 32000, status: "PENDING", rooms: 5, matches: true,
                amenities: "ELECTRICITY,WATER",
                landlord: "Grace Chirwa", landlordPhone: "+265 881 234 567",
                description: "Modern flats along the Area 49 riverside road, each unit self-contained with prepaid ESCOM meters.",
                roomsData: [
                    { roomId: 8, roomType: "Self-contained", price: 32000, available: false },
                    { roomId: 9, roomType: "Single room", price: 22000, available: true }
                ],
                photosData: []
            },
            {
                propertyId: "P-005", title: "Acacia Studio",
                district: "Lilongwe", village: "Area 15",
                price: 18000, status: "DRAFT", rooms: 2, matches: true,
                amenities: "",
                landlord: "Yamikani Nkhoma", landlordPhone: "+265 995 654 321",
                description: "",
                roomsData: [],
                photosData: []
            },
            {
                propertyId: "P-006", title: "Brookline Guest House",
                district: "Blantyre", village: "Nyambadwe",
                price: 55000, status: "REJECTED", rooms: 8, matches: true,
                amenities: "WIFI,PARKING,SECURITY,AC",
                landlord: "Peter Zimba", landlordPhone: "+265 884 111 222",
                description: "Eight-room guest house facing Nyambadwe stream, popular with business travellers.",
                roomsData: [
                    { roomId: 10, roomType: "Self-contained", price: 55000, available: true },
                    { roomId: 11, roomType: "Single room", price: 35000, available: true }
                ],
                photosData: []
            }
        ])
        root.applyFilters()
    }

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
            title: it.title,
            description: it.description,
            physicalAddress: {
                district: it.district,
                village: it.village
            },
            verificationStatus: String(it.status),
            amenities: String(it.amenities).length > 0 ? String(it.amenities).split(",") : [],
            isActive: true,
            price: it.price,
            landlord: it.landlord,
            landlordPhone: it.landlordPhone,
            rooms: modelToArray(it.roomsData),
            photos: modelToArray(it.photosData)
        }
    }
}
