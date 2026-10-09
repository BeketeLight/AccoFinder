function formatCurrency(value) {
    var num = Number(value)
    if (isNaN(num)) return "MK 0"
    var parts = Math.round(num).toString().split(".")
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return "MK " + parts[0]
}

// Wrap a remote img URL so it loads through the CachedImageProvider. Local
// (file:// or qrc://) and empty sources pass through unchanged.
function cachedImage(src) {
    if (!src) return ""
    var s = String(src)
    if (s.indexOf("http://") === 0 || s.indexOf("https://") === 0)
        return "image://cached/" + encodeURIComponent(s)
    return s
}

// Determine which notification feed scope the current viewer should use on the
// agent dashboard. The dashboard always surfaces agent-addressed notifications
// plus announcements that were delivered to everyone: an admin acting as an
// agent sees the same agent feed (never their admin-targeted notifications).
// The backend matches this by returning recipientRole=AGENT OR announcement.
function notificationRoleForViewer() {
    return "AGENT"
}

// Normalise a verification status coming from the backend before comparing it
// against a known value. The API has used "PENDING", "pending" and
// "Unverified" for the same state, and PropertyListModel also falls back to
// "Not Verified", so every caller shares one comparison rule instead of
// hard-coding its own.
function normalizeVerificationStatus(value) {
    var s = String(value === undefined || value === null ? "" : value).trim().toUpperCase()
    if (s === "")
        return ""
    // Collapse "Not Verified" / "Not verified" onto the same token.
    return s.replace(/\s+/g, " ")
}

// True when a property is still waiting for an admin decision. The dashboard
// counter and the approval queue both call this so a non-zero card can never
// open an empty screen.
function isPendingVerification(value) {
    var s = normalizeVerificationStatus(value)
    return s === "PENDING" || s === "UNVERIFIED" || s === "NOT VERIFIED"
}

// Bucket a booking status into the state the admin UI filters on.
//
// BookingListModel renders BookingStatus::PendingPayment as "Pending payment"
// and PaymentInFlight as "Payment processing" (the backend enum values are
// "PendingPayment"/"PaymentInFlight"), so comparing a row against the bare
// token "Pending" never matched anything. Comparing here instead of against the
// display string keeps every caller - the status filter, the counters and the
// delegate's action buttons - in step.
//
//   PENDING   hold still open, nothing settled: "Pending payment",
//             "Payment processing", "Payment failed" (retryable, hold stands)
//             and the legacy "Pending"
//   CONFIRMED "Confirmed" and the legacy "Paid"
//   CANCELLED "Cancelled"
//   EXPIRED   hold lapsed and the room was released - nothing left to do
//
// Returns "" for an unrecognised status so it is never silently counted.
function bookingStatusBucket(value) {
    var s = normalizeVerificationStatus(value)
    if (s === "PENDING PAYMENT" || s === "PAYMENT PROCESSING"
            || s === "PAYMENT FAILED" || s === "PENDING") {
        return "PENDING"
    }
    if (s === "CONFIRMED" || s === "PAID")
        return "CONFIRMED"
    if (s === "CANCELLED")
        return "CANCELLED"
    if (s === "EXPIRED")
        return "EXPIRED"
    return ""
}

// True while a booking is unsettled enough for an admin to act on it. The
// backend's confirmBooking refuses an already-confirmed or cancelled booking
// and otherwise confirms whenever the hold still stands, so exactly the
// PENDING bucket is actionable.
function isActionableBooking(value) {
    return bookingStatusBucket(value) === "PENDING"
}

// Tell the CachedImageProvider to forget one or more remote URLs after the
// underlying image was deleted server-side, so a stale copy is not served
// later. Accepts a single string or an array of strings/objects with .url.
function invalidateImages(srcs) {
    if (typeof ImageCache === "undefined" || !ImageCache)
        return
    if (!srcs)
        return
    var list = Array.isArray(srcs) ? srcs : [srcs]
    for (var i = 0; i < list.length; i++) {
        var item = list[i]
        if (!item) continue
        var u = typeof item === "string" ? item : (item.url || item.path || "")
        if (!u) continue
        if (u.indexOf("http://") === 0 || u.indexOf("https://") === 0)
            ImageCache.invalidateUrl(u)
    }
}

// Render when a notification arrived, as "<date> · <time>" in the device's own
// locale and timezone. Accepts a JS Date (what the C++ role hands QML), an
// ISO-8601 string, or epoch milliseconds.
//
// Anything unparseable, and anything the backend never stamped, returns an
// empty string rather than a placeholder: callers hide the whole row when it
// is empty, so a missing timestamp shows as simply no timestamp instead of a
// misleading 1 Jan 1970.
function notificationTimestamp(value) {
    var d
    if (value instanceof Date)
        d = value
    else if (typeof value === "number")
        d = new Date(value)
    else if (typeof value === "string" && value.length > 0)
        d = new Date(value)
    else
        return ""
    if (isNaN(d.getTime()) || d.getTime() <= 0)
        return ""

    // Midnight boundaries are computed in local time on both sides, so "today"
    // and "yesterday" follow the device clock rather than UTC.
    var now = new Date()
    var startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
    var day = 86400000

    var time = Qt.formatTime(d, Qt.locale(), "HH:mm")
    var dayLabel
    if (d.getTime() >= startOfToday)
        dayLabel = qsTr("Today")
    else if (d.getTime() >= startOfToday - day)
        dayLabel = qsTr("Yesterday")
    else if (d.getFullYear() === now.getFullYear())
        dayLabel = Qt.formatDate(d, Qt.locale(), "d MMM")
    else
        dayLabel = Qt.formatDate(d, Qt.locale(), "d MMM yyyy")

    return dayLabel + " · " + time
}

// Seconds left until holdExpiresAt (ISO / parseable string).
// -1 = missing/invalid deadline (no countdown)
//  0 = expired
// >0 = still open
function holdSecondsRemaining(holdExpiresAt) {
    if (holdExpiresAt === undefined || holdExpiresAt === null)
        return -1
    var s = String(holdExpiresAt).trim()
    if (s.length === 0)
        return -1
    var end = Date.parse(s)
    if (isNaN(end) || end <= 0)
        return -1
    return Math.max(0, Math.floor((end - Date.now()) / 1000))
}
// Check if the booking is in a pending state eligible for payment/action
function isActionableBooking(status) {
    if (!status) return false;
    var s = String(status).trim().toUpperCase();
    return s === "PENDING" || s === "PENDING PAYMENT" || s === "PAYMENT PROCESSING";
}

function isHoldOpen(holdExpiresAt) {
    return holdSecondsRemaining(holdExpiresAt) > 0
}

// Card / details label. Empty string = hide the row.
function holdCountdownText(status,holdExpiresAt) {
    // If booking is cancelled, confirmed, or expired, hide hold text completely
    if (!isActionableBooking(status))
            return "";
    var sec = holdSecondsRemaining(holdExpiresAt)
    if (sec < 0)
        return ""
    if (sec <= 0)
        return qsTr("Hold expired")
    var h = Math.floor(sec / 3600)
    var m = Math.floor((sec % 3600) / 60)
    var s = sec % 60
    if (h > 0)
        return qsTr("This booking expires in %1h %2m").arg(h).arg(m)
    if (m > 0)
        return qsTr("This booking expires in %1m %2s").arg(m).arg(s)
    return qsTr("Expires in %1s").arg(s)
}

// Pay / cancel-while-hold: pending bucket AND time left
function canPayBooking(status, holdExpiresAt) {
    return isActionableBooking(status) && isHoldOpen(holdExpiresAt)
}