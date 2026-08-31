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
