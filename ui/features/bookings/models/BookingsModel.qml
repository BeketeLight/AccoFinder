import QtQuick 2.15

Item {
    id: root

    // Backend Enum Constants
    readonly property var bookingStatus: Object.freeze({
        PENDING: 'Pending',
        PAID: 'Paid',
        CONFIRMED: 'Confirmed',
        CANCELLED: 'Cancelled'
    })

    // Filtering API matching UI tabs: "All", "Pending", "Confirmed", "Paid", "Cancelled"
    property string statusFilter: "All"
    property string searchText: ""
    property int resultCount: 0

    readonly property alias bookingsModel: bookingsModelId
    readonly property alias filterChipsModel: filterChipsModelId

    ListModel {
        id: bookingsModelId
    }


    // Updated Filter Chips to reflect the actual backend status names
    ListModel {
        id: filterChipsModelId
        ListElement { label: "All" }
        ListElement { label: "Pending" }
        ListElement { label: "Confirmed" } // Updated from "Approved" to align with BookingStatus
        ListElement { label: "Paid" }
        ListElement { label: "Cancelled" }
    }

    // --- 1. SEARCH & FILTERING LOGIC ---
    function applyFilters() {
        var count = 0
        var q = root.searchText.trim().toLowerCase()

        // Normalize selected filter chip string
        var rawWanted = root.statusFilter.toUpperCase()
        var wanted = (rawWanted === "ALL") ? "" : rawWanted

        // Handle UI alias mapping if legacy views still send "APPROVED"
        if (wanted === "APPROVED") {
            wanted = root.bookingStatus.CONFIRMED.toUpperCase()
        }

        for (var i = 0; i < bookingsModelId.count; i++) {
            var it = bookingsModelId.get(i)

            var itemStatus = String(it.status).toUpperCase()

            // Normalize backend item status for legacy compatibility
            if (itemStatus === "APPROVED") {
                itemStatus = root.bookingStatus.CONFIRMED.toUpperCase()
            }

            var okStatus = (wanted.length === 0) || (itemStatus === wanted)

            var okSearch = q.length === 0
                          || (it.clientName && it.clientName.toLowerCase().indexOf(q) !== -1)
                          || (it.houseName && it.houseName.toLowerCase().indexOf(q) !== -1)
                          || (it.district && it.district.toLowerCase().indexOf(q) !== -1)
                          || (it.village && it.village.toLowerCase().indexOf(q) !== -1)

            var match = okStatus && okSearch
            bookingsModelId.setProperty(i, "matches", match)
            if (match)
                count++
        }
        root.resultCount = count
    }

    // --- 2. FIND BOOKING HELPER ---
    function findBooking(matchValue, matchRole = "bookingId") {
        for (var i = 0; i < bookingsModelId.count; i++) {
            var it = bookingsModelId.get(i)
            if (String(it[matchRole]) === String(matchValue))
                return it
        }
        return null
    }

    // --- 3. PAYLOAD GENERATOR FOR THE DETAIL PAGE ---
    function detailPayloadFor(bookingId) {
        var it = findBooking(bookingId, "bookingId")
        if (!it)
            return null

        return {
            "bookingId": it.bookingId,
            "status": it.status,
            "bookingDate": it.bookingDate,
            "createdAt": it.createdAt,

            // Financial Breakdown
            "amount": it.amount,
            "commissionAmount": it.commissionAmount,
            "totalAmount": it.amount + it.commissionAmount,

            // Joined Client Info
            "clientId": it.clientId,
            "clientName": it.clientName,
            "clientPhone": it.clientPhone,
            "clientEmail": it.clientEmail,

            // Joined Room & Property Details
            "roomId": it.roomId,
            "roomType": it.roomType,
            "houseName": it.houseName,
            "district": it.district,
            "village": it.village,
            "location": (it.district && it.village) ? (it.district + ", " + it.village) : (it.district || it.village || "Location N/A"),
            "propertyImage": it.propertyImage,
            "landlord": it.landlord,
            "landlordPhone": it.landlordPhone
        }
    }

    // --- 4. RELOAD & DATA JOINING ENGINE ---
    function reload() {
        bookingsModelId.clear()

        var m = BookingViewModel.bookingListModel
        var cppSize = m ? m.rowCount() : 0
        console.log("--> BookingsModel reload called. C++ row count:", cppSize)
        // if (cppSize === 0) {
        //         console.log("--> Injecting mock test item")
        //         bookingsModelId.append({
        //             "bookingId": "BK-101",
        //             "clientId": "C-1",
        //             "roomId": "R-1",
        //             "bookingDate": "Sep 20 - Sep 25",
        //             "amount": 45000,
        //             "commissionAmount": 5000,
        //             "status": "Pending",
        //             "matches": true,
        //             "clientName": "John Doe",
        //             "clientPhone": "+265999000000",
        //             "clientEmail": "john@example.com",
        //             "roomType": "Deluxe Room",
        //             "houseName": "Sunset Apartments",
        //             "district": "Zomba",
        //             "village": "Central",
        //             "propertyImage": "",
        //             "landlord": "Manager",
        //             "landlordPhone": ""
        //         })
        //         root.applyFilters()
        //         return
        //     }

        for (var i = 0; i < cppSize; i++) {
            var idx = m.index(i, 0)

            var bId = m.data(idx, Qt.UserRole + 1)          // bookingId
            var cId = m.data(idx, Qt.UserRole + 2)          // clientId
            var rId = m.data(idx, Qt.UserRole + 3)          // roomId
            var bDate = m.data(idx, Qt.UserRole + 4)        // bookingDate
            var amt = m.data(idx, Qt.UserRole + 5)          // amount
            var commAmt = m.data(idx, Qt.UserRole + 6)      // commissionAmount
            var rawStat = m.data(idx, Qt.UserRole + 7)      // status

            // Sanitize and align status to BookingStatus enum values
            var stat = rawStat ? rawStat : root.bookingStatus.PENDING
            if (String(stat).toUpperCase() === "APPROVED") {
                stat = root.bookingStatus.CONFIRMED
            }

            // --- RELATIONAL JOIN: LOOKUP ROOM & PROPERTY ---
            var roomInfo = RoomViewModel.getRoomById(rId) || {}
            var roomTypeVal = roomInfo.type || m.data(idx, Qt.UserRole + 11) || "Private Room"

            var propId = roomInfo.propertyId || ""
            var propInfo = propId ? PropertyViewModel.getPropertyById(propId) : {}

            var houseTitle = propInfo.title || m.data(idx, Qt.UserRole + 12) || "Hostel/Apartment"
            var dist = propInfo.district || (propInfo.physicalAddress ? propInfo.physicalAddress.district : "") || ""
            var vill = propInfo.village || (propInfo.physicalAddress ? propInfo.physicalAddress.village : "") || ""
            var imgUrl = propInfo.coverImage || (propInfo.media && propInfo.media.length > 0 ? propInfo.media[0].url : "") || ""

            // --- RELATIONAL JOIN: LOOKUP CLIENT INFO ---
            var clientInfo = UserViewModel.getUserById(cId) || {}
            var cName = clientInfo.fullName || m.data(idx, Qt.UserRole + 8) || "Client"
            var cPhone = clientInfo.phone || m.data(idx, Qt.UserRole + 9) || "N/A"
            var cEmail = clientInfo.email || m.data(idx, Qt.UserRole + 10) || "N/A"

            // Append aggregated item to QML model
            bookingsModelId.append({
                "bookingId": bId,
                "clientId": cId,
                "roomId": rId,
                "bookingDate": bDate,
                "amount": amt,
                "commissionAmount": commAmt,
                "status": stat,
                "matches": true,

                // Extracted Client Data
                "clientName": cName,
                "clientPhone": cPhone,
                "clientEmail": cEmail,

                // Extracted Room & Property Data
                "roomType": roomTypeVal,
                "houseName": houseTitle,
                "district": dist,
                "village": vill,
                "propertyImage": imgUrl,
                "landlord": propInfo.landlord || "",
                "landlordPhone": propInfo.landlordPhone || ""
            })
        }

        root.applyFilters()
    }

    // --- 5. SIGNAL LISTENERS & RE-INDEXING ---
    onStatusFilterChanged: root.applyFilters()
    onSearchTextChanged: root.applyFilters()

    Component.onCompleted: {
        reload()
    }

    Connections {
            target: BookingViewModel.bookingListModel
            function onRowsInserted(parent, first, last) { root.reload() }
            function onRowsRemoved(parent, first, last) { root.reload() }
            function onModelReset() { root.reload() }
        }

        Connections {
            target: RoomViewModel.roomListModel
            function onRowsInserted(parent, first, last) { root.reload() }
            function onModelReset() { root.reload() }
        }

        Connections {
            target: PropertyViewModel.propertyListModel
            function onRowsInserted(parent, first, last) { root.reload() }
            function onModelReset() { root.reload() }
        }
}