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
