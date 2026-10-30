import QtQuick

// QML mirror of PropertyViewModel.searchResultModel, plus the media pipeline.
//
// This is the search-side twin of PropertiesModel.qml. It produces the exact
// same 22-field row shape the home feed produces, so any card, delegate, or
// detail page can consume a search row and a home row interchangeably.
//
// What it owns:
//   • reload()            — scans the C++ model, appends one row per result.
//   • scheduleMediaFetches() — fires getMediaByProperty(pid) once per pid,
//                             guarded by _mediaRequested.
//   • refreshCovers()     — writes imageUrl / imageUrls back into rows from
//                           whatever MediaViewModel already has cached.
//   • coverRefreshTimer   — 400ms poll during a media batch; stops once
//                           nothing changes for 4 ticks.
//   • Connections         — structural signals from the C++ model + the
//                           MediaViewModel.onIsLoadingChanged final pass.
//
// What it does NOT do (search doesn't need these):
//   • no recents mirror (home builds one for the "This Week" carousel).
//   • no matches / applyFilter (search filters are the backend's job).
//   • no _visibleCount (every row the C++ model returns is rendered).
Item {
    id: root

    readonly property alias model: searchModel
    readonly property int count: searchModel.count
    readonly property bool loading: PropertyViewModel.isSearching

    // Guards getMediaByProperty(pid) so the /media/property/:id endpoint is
    // hit at most once per pid per search session. CachedImageProvider
    // deduplicates the actual image bytes below this; this guard deduplicates
    // the API call that gets us the URLs in the first place.
    property var _mediaRequested: ({})

    property int _coverTicksWithoutChange: 0

    ListModel {
        id: searchModel
    }

    Timer {
        id: coverRefreshTimer
        interval: 400
        repeat: true
        running: false
        onTriggered: root.refreshCovers()
    }

    // ------------------------------------------------------------
    // Mirror the C++ rows into the QML model.
    // ------------------------------------------------------------
    function reload() {
        searchModel.clear();

        const src = PropertyViewModel.searchResultModel;
        const n = src ? src.size() : 0;

        for (let i = 0; i < n; i++) {
            const row = src.at(i);
            if (!row)
                continue;

            const pid = row.propertyId ? String(row.propertyId) : "";
            const locationText = ((row.village || "") + (row.district ? ", " + row.district : "")).trim();

            console.log("[SearchModel] pid:", pid);
            console.log("[SearchModel]   raw row.amenities:", JSON.stringify(row.amenities), "| typeof:", typeof row.amenities, "| isArray:", Array.isArray(row.amenities));

            searchModel.append({
                // ---- identity ----
                propertyId: pid,

                // ---- display ----
                title: row.title || "Untitled",
                description: row.description || "",
                price: Number(row.price || 0),
                district: row.district || "",
                village: row.village || "",
                location: locationText,
                propertyType: String(row.propertyType || "").toUpperCase(),

                // ---- classification ----
                status: row.status || "",
                isVerified: String(row.status || "").toUpperCase() === "VERIFIED",
                isActive: row.active !== undefined ? row.active : true,
                roomCount: row.roomCount || 0,
                rejectionReason: row.rejectionReason || "",

                // ---- amenities: pipe-joined string, exactly like PropertiesModel ----
                amenities: pid ? src.amenitiesFor(pid).join("|") : "",

                // ---- owner / landlord ----
                landlord: row.landlord || "",
                landlordPhone: row.landlordPhone || "",
                ownerName: row.ownerName || "",
                ownerPhone: row.ownerPhone || "",

                // ---- media: filled in by refreshCovers() ----
                imageUrl: "",
                imageUrls: "",

                // ---- meta ----
                createdAt: row.createdAt || ""
            });
        }

        scheduleMediaFetches();
        refreshCovers();
    }

    // ------------------------------------------------------------
    // Media pipeline (same shape as PropertiesModel's).
    // ------------------------------------------------------------

    // Fire getMediaByProperty(pid) once per property, ever.
    function scheduleMediaFetches() {
        var fired = 0;
        for (var i = 0; i < searchModel.count; i++) {
            var pid = String(searchModel.get(i).propertyId || "");
            if (pid.length === 0)
                continue;
            if (_mediaRequested[pid])
                continue;
            _mediaRequested[pid] = true;
            MediaViewModel.getMediaByProperty(pid);
            fired++;
        }
        // Restart the timer whenever there are rows to cover, not just when
        // new fetches fired. Media may still be arriving from a previous
        // search (or from home) and needs to be picked up.
        if (searchModel.count > 0)
            coverRefreshTimer.restart();
    }

    // Read whatever media the shared MediaListModel already has for each
    // row, pick the primary (or the first), and write both imageUrl
    // (cover) and imageUrls (comma-joined list) into the row.
    function refreshCovers() {
        for (var i = 0; i < searchModel.count; i++) {
            var pid = String(searchModel.get(i).propertyId || "");
            if (pid.length === 0)
                continue;
            var media = MediaViewModel.mediaForProperty(pid);
            var cover = "";
            var urls = [];
            if (media && media.length > 0) {
                var primary = null;
                for (var k = 0; k < media.length; k++) {
                    var m = media[k];
                    if (!m)
                        continue;
                    var u = String(m.url || m.path || "");
                    if (u.length > 0)
                        urls.push(u);
                    if (m.isPrimary && !primary)
                        primary = m;
                }
                var pick = primary || media[0];
                cover = pick ? String(pick.url || pick.path || "") : "";
                if (cover.length > 0) {
                    var reordered = [cover];
                    for (var u2 = 0; u2 < urls.length; u2++)
                        if (urls[u2] !== cover)
                            reordered.push(urls[u2]);
                    urls = reordered;
                }
            }
            if (String(searchModel.get(i).imageUrl) !== cover)
                searchModel.setProperty(i, "imageUrl", cover);
            var joined = urls.join(",");
            if (String(searchModel.get(i).imageUrls) !== joined)
                searchModel.setProperty(i, "imageUrls", joined);
        }
    }

    // ------------------------------------------------------------
    // Signals.
    // ------------------------------------------------------------

    // Structural changes from the C++ model.
    Connections {
        target: PropertyViewModel.searchResultModel
        function onCountChanged() {
            root.reload();
        }
        function onModelReset() {
            root.reload();
        }
        function onDataChanged() {
            root.reload();
        }
        function onRowsInserted() {
            root.reload();
        }
        function onRowsRemoved() {
            root.reload();
        }
    }

    // Search finishing is the signal that result rows have arrived.
    Connections {
        target: PropertyViewModel
        function onIsSearchingChanged() {
            if (!PropertyViewModel.isSearching)
                root.reload();
        }
    }

    // Final pass once the media batch settles.
    Connections {
        target: MediaViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshCovers();
        }
    }

    // Stop hammering the media model once nothing changes.
    Connections {
        target: coverRefreshTimer
        function onTriggered() {
            var before = 0;
            for (var i = 0; i < searchModel.count; i++)
                if (String(searchModel.get(i).imageUrl).length > 0)
                    before++;
            root.refreshCovers();
            var after = 0;
            for (var j = 0; j < searchModel.count; j++)
                if (String(searchModel.get(j).imageUrl).length > 0)
                    after++;
            if (after === before) {
                root._coverTicksWithoutChange++;
                if (root._coverTicksWithoutChange >= 4)
                    coverRefreshTimer.stop();
            } else {
                root._coverTicksWithoutChange = 0;
            }
        }
    }

    Component.onCompleted: reload()
}
