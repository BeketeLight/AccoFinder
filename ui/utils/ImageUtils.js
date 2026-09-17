.pragma library

/**
 * Returns a source string for CachedImageProvider.
 * Pass a normal http(s) URL (or already-cached URI).
 */
function cachedSource(url) {
    if (url === undefined || url === null)
        return "";

    var s = String(url).trim();
    if (!s.length)
        return "";

    // Already using the provider
    if (s.indexOf("image://cached/") === 0)
        return s;

    // Optional: leave local / qrc paths alone
    if (s.indexOf("qrc:") === 0 || s.indexOf("file:") === 0)
        return s;

    return "image://cached/" + encodeURIComponent(s);
}
