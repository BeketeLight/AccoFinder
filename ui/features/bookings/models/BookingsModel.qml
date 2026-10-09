import QtQuick 2.15

Item {
    id: root
    property string bookingId: ""
    readonly property bool loading: BookingViewModel.isLoading
    // Backend Enum Constants
    readonly property var bookingStatus: Object.freeze({
        PENDING_PAYMENT: 'Pending payment',
        PAYMENT_PROCESSING: 'Payment processing',
        CONFIRMED: 'Confirmed',
        EXPIRED: 'Expired',
        CANCELLED: 'Cancelled',
        PAYMENT_FAILED: 'Payment failed',
        PENDING: 'Pending' // legacy compatibility
    })

    // Filtering API matching UI tabs: "All", "Pending", "Confirmed", "Paid", "Cancelled"
    property string statusFilter: "All"
    property string searchText: ""
    property int resultCount: 0
    property int totalCount: 0
    property int pendingPaymentCount: 0
    property int confirmedCount: 0
    property int cancelledCount: 0

    readonly property alias bookingsModel: bookingsModelId
    readonly property alias filterChipsModel: filterChipsModelId

    ListModel {
        id: bookingsModelId
    }


    // Updated Filter Chips to reflect the actual backend status names
    ListModel {
        id: filterChipsModelId
        ListElement { label: "All" }
        ListElement { label: "Pending Payment" }
        ListElement { label: "Confirmed" } // Updated from "Approved" to align with BookingStatus
        ListElement { label: "Cancelled" }
    }
    //Looping and summing up statuses
    function updateStatusCount(){
        var total = 0
        var pendingPayment = 0
        var confirmed = 0
        var cancelled = 0

        for(var i = 0; i < bookingsModelId.count; i++){
            var status = String(bookingsModelId.get(i).status || "").trim().toUpperCase()
            total++

            switch(status){
            //Payment window----Anything related to payment before window expires will be counted a Pending_payment
            case "PENDING PAYMENT":
            case "PAYMENT PROCESSING":
            case "PAYMENT FAILED":
            case "PENDING":
                pendingPayment++
                break

            case "CONFIRMED":
            case "PAID":
                confirmed++
                break

            case "CANCELLED":
            case "EXPIRED":
                cancelled++
                break
            }
        }
        root.totalCount = total
        root.pendingPaymentCount = pendingPayment
        root.confirmedCount = confirmed
        root.cancelledCount  = cancelled
    }
    //Function to match filters
    function matchesStatusFilter(status){
        var currentStatus = String(status || "").trim().toUpperCase()
        var filter = String(root.statusFilter || "All").trim().toUpperCase()
        //ALL
        if(filter === "ALL")
            return true

        if(filter === "PENDING PAYMENT"){
            return currentStatus === "PENDING PAYMENT"
                || currentStatus === "PAYMENT PROCESSING"
                || currentStatus === "PAYMENT FAILED"
                || currentStatus === "PENDING"
        }

        if(filter === "CONFIRMED"){
            return currentStatus ===  "CONFIRMED"
                || currentStatus === "PAID"
        }

        if(filter === "CANCELLED"){
            return currentStatus === "CANCELLED"
                || currentStatus === "EXPIRED"
        }
        return false
    }
    // --- 1. SEARCH & FILTERING LOGIC ---
    function applyFilters() {
        var count = 0
        var q = root.searchText.trim().toLowerCase()
        for (var i = 0; i < bookingsModelId.count; i++) {
            var it = bookingsModelId.get(i)
            var okStatus = root.matchesStatusFilter(it.status)// status has to be matched from matchesStatusFilter function

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
    ///used to extract field fro properties
    function findProperty(propId) {
        if (!propId || !PropertyViewModel || !PropertyViewModel.propertiesForView)
            return {}
        var list = PropertyViewModel.propertiesForView()
        if (!list || !list.length)
            return {}
        for (var i = 0; i < list.length; i++) {
            var row = list[i]
            if (row && String(row.id) === String(propId))
                return row
        }
        return {}
    }
    //EXtracting booked Image
    function coverImageFor(propertyId, roomId) {
        if (!propertyId || typeof MediaViewModel === "undefined")
            return ""

        MediaViewModel.getMediaByProperty(propertyId)
        var list = MediaViewModel.mediaForProperty(propertyId)
        if (!list || list.length === 0) {
            console.log("coverImageFor: no media yet prop", propertyId, "room", roomId)
            return ""
        }

        console.log("coverImageFor prop", propertyId, "want room", roomId, "count", list.length)

        if (roomId) {
            var want = String(roomId).trim()
            for (var i = 0; i < list.length; i++) {
                var mRoom = String(list[i].roomId !== null ? list[i].roomId : "").trim()
                var url = list[i].url || list[i].path || ""
                console.log("  media[", i, "] roomId=", mRoom, "isPrimary=", list[i].isPrimary, "url=", url)
                if (mRoom.length && mRoom !== "-1" && mRoom === want && url)
                    return url
            }
        }

        // fallback: primary, then first property-level, then first any
        for (var j = 0; j < list.length; j++) {
            if (list[j].isPrimary)
                return list[j].url || list[j].path || ""
        }
        for (var k = 0; k < list.length; k++) {
            var rid = String(list[k].roomId !== null ? list[k].roomId : "")
            if (rid === "" || rid === "-1")
                return list[k].url || list[k].path || ""
        }
        return list[0].url || list[0].path || ""
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
            "landlordPhone": it.landlordPhone,
            //Expiration window
            "holdExpiresAt": it.holdExpiresAt,
            "holdSecondsRemaining": it.holdSecondsRemaining,
            "holdActive": it.holdActive


        }

    }

    // --- 4. RELOAD & DATA JOINING ENGINE ---
    function reload() {
        bookingsModelId.clear()

        var m = BookingViewModel.bookingListModel
        var cppSize = m ? m.rowCount() : 0
        console.log("--> BookingsModel reload called. C++ row count:", cppSize)
        for (var i = 0; i < cppSize; i++) {
            var idx = m.index(i, 0)

            var bId = m.data(idx, Qt.UserRole)          // bookingId
            var cId = m.data(idx, Qt.UserRole + 1)          // clientId
            var rId = m.data(idx, Qt.UserRole + 2)          // roomId
            var bDate = m.data(idx, Qt.UserRole + 3)        // bookingDate
            var amt = m.data(idx, Qt.UserRole + 4)          // amount
            var commAmt = m.data(idx, Qt.UserRole + 5)      // commissionAmount
            var rawStat = m.data(idx, Qt.UserRole + 6)      // status

            // Sanitize and align status to BookingStatus enum values
            var stat = rawStat ? rawStat : root.bookingStatus.PENDING
            if (String(stat).toUpperCase() === "APPROVED") {
                stat = root.bookingStatus.CONFIRMED
            }

            // --- RELATIONAL JOIN: LOOKUP ROOM & PROPERTY ---
            var roomInfo = RoomViewModel.getRoomById(rId) || {}
            console.log("room count", RoomViewModel.roomListModel
                            ? RoomViewModel.roomListModel.rowCount()
                            : -1)
                console.log("roomInfo", JSON.stringify(roomInfo))
                console.log("booking", bId, "clientId", cId, "roomId", rId)
            var roomTypeVal = roomInfo.type || m.data(idx, Qt.UserRole + 11) || "Private Room"

            //Property details extraction
            var propId = (roomInfo && roomInfo.propertyId) ? roomInfo.propertyId : ""
            var propInfo = propId ? findProperty(propId) : {}

            var houseTitle = (propInfo && propInfo.title) ? propInfo.title : "Hostel/Apartment"
            var dist = (propInfo && propInfo.district) ? propInfo.district : ""
            var vill = (propInfo && propInfo.village) ? propInfo.village : ""
            var landlord = (propInfo && propInfo.landlord) ? propInfo.landlord : ""
            var landlordPhone = (propInfo && propInfo.landlordPhone) ? propInfo.landlordPhone : ""
            //Real Host
            var ownerFirstName = (propInfo && propInfo.ownerFirstName)
                    ? propInfo.ownerFirstName
                    : ""

            var ownerSurname = (propInfo && propInfo.ownerSurname)
                    ? propInfo.ownerSurname
                    : ""

            var hostName = (ownerFirstName + " " + ownerSurname).trim()
            if (!hostName.length)
                hostName = propInfo.ownerName || propInfo.landlord || "Host"

            //Extracting Initials
            var hostInitials = "?"
            if (ownerFirstName.length && ownerSurname.length)
                hostInitials = (ownerFirstName.charAt(0) + ownerSurname.charAt(0)).toUpperCase()
            else if (hostName.length && hostName !== "Host") {
                var parts = hostName.split(/\s+/).filter(function (p) { return p.length > 0 })
                if (parts.length >= 2)
                    hostInitials = (parts[0].charAt(0) + parts[1].charAt(0)).toUpperCase()
                else if (parts.length === 1)
                    hostInitials = parts[0].substring(0, Math.min(2, parts[0].length)).toUpperCase()
            }
            //Extracting exact image booked by the user-----
            var imgUrl = coverImageFor(propId, rId)

            console.log("booking", bId, "propId", propId, "imageUrl →", imgUrl, "=======================================")

            // From Booking (populated clientId parsed in repository) — NOT UserViewModel
            var cName  = m.data(idx, Qt.UserRole + 7) || "Client"
            var cPhone = m.data(idx, Qt.UserRole + 8) || "N/A"
            var cEmail = m.data(idx, Qt.UserRole + 9) || "N/A"

            var holdExpiresAt = m.data(idx, Qt.UserRole + 10)
            var holdSecondsRemaining = m.data(idx, Qt.UserRole + 11)
            var holdActive = m.data(idx, Qt.UserRole + 12)
            // Extract first letter of client's full name
            var clientInitial = cName.trim().charAt(0).toUpperCase()
            // Append aggregated item to QML model
            bookingsModelId.append({
                "bookingId": bId,
                "clientId": cId,
                "roomId": rId,
                "bookingDate": bDate,
                "amount": Number(amt) || 0, /// real property price
                "commissionAmount": Number(commAmt) || 0, // real commission
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
                "landlordPhone": propInfo.landlordPhone || "",

                "ownerFirstName": ownerFirstName,
                "ownerSurname": ownerSurname,
                "hostName": hostName,
                "hostInitials": hostInitials,
                "clientInitial": clientInitial,

                "holdExpiresAt": holdExpiresAt,
                "holdSecondsRemaining": Number(holdSecondsRemaining) || 0,
                "holdActive": Boolean(holdActive)
            })
        }
        root.updateStatusCount()
        root.applyFilters()
    }

    // --- 5. SIGNAL LISTENERS & RE-INDEXING ---
    onStatusFilterChanged: root.applyFilters()
    onSearchTextChanged: root.applyFilters()

    Component.onCompleted: {
        RoomViewModel.loadRooms()
        PropertyViewModel.getProperties("")
        BookingViewModel.fetchBookings()
        // if(typeof UserViewModel !== "undefined")
        //     UserViewModel.getUsers()
        // BookingViewModel.fetchBookingById(bookingId)
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
    Connections {
        target: MediaViewModel.mediaListModel
        function onCountChanged() { root.reload() }
        function onModelReset()   { root.reload() }
    }

}