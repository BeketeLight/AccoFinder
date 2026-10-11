import QtQuick

Item {
    id: root

    readonly property alias propertiesModel: propertiesModelId
    readonly property alias recentsPropertiesModel: recentsPropertiesModel
    readonly property int count: propertiesModelId.count
    readonly property int visibleCount: _visibleCount
    readonly property bool loading: PropertyViewModel.isLoading

    // "ALL" | "HOSTEL" | "QUARTER" | "WHOLE"
    property string typeFilter: "ALL"
    property int _visibleCount: 0

    // How far back "recent" goes, in hours. Exposed so a screen can
    // temporarily widen or narrow the window without touching this file.
    property int recentsWindowHours: 24

    // Guards getMediaByProperty(pid) so it fires at most once per property
    // per Home session.
    property var _mediaRequested: ({})

    property int _coverTicksWithoutChange: 0

    ListModel {
        id: propertiesModelId
    }

    ListModel {
        id: recentsPropertiesModel
    }

    Timer {
        id: coverRefreshTimer
        interval: 400
        repeat: true
        running: false
        onTriggered: root.refreshCovers()
    }

    // ------------------------------------------------------------
    // Normalise whatever the model hands us into a JS Date, or
    // null if it can't be parsed. Handles three cases:
    //   1. QDateTime  -> arrives in QML as a JS Date
    //   2. ISO string -> parsed with new Date()
    //   3. epoch ms   -> constructed directly
    // ------------------------------------------------------------
    function parseCreatedAt(value) {
        if (value === undefined || value === null || value === "")
            return null;

        if (value instanceof Date)
            return isNaN(value.getTime()) ? null : value;

        if (typeof value === "number")
            return new Date(value);

        var d = new Date(String(value));
        return isNaN(d.getTime()) ? null : d;
    }

    // ------------------------------------------------------------
    // Rebuild recentsPropertiesModel from propertiesModelId,
    // keeping only rows whose createdAt falls within the window
    // and which currently match the active filter.
    // ------------------------------------------------------------
    function refreshRecents() {
        recentsPropertiesModel.clear();

        var cutoffMs = Date.now() - (root.recentsWindowHours * 60 * 60 * 1000);

        // Collect matching rows first, then sort, then append.
        var picked = [];
        for (var i = 0; i < propertiesModelId.count; i++) {
            var row = propertiesModelId.get(i);

            // Only surface rows that pass the current filter.
            if (row.matches !== true)
                continue;
            var created = root.parseCreatedAt(row.createdAt);
            if (!created)
                continue;
            if (created.getTime() < cutoffMs)
                continue;
            picked.push(row);
        }

        // Newest first.
        picked.sort(function (a, b) {
            var da = root.parseCreatedAt(a.createdAt);
            var db = root.parseCreatedAt(b.createdAt);
            if (!da || !db)
                return 0;
            return db.getTime() - da.getTime();
        });

        for (var k = 0; k < picked.length; k++) {
            var p = picked[k];
            recentsPropertiesModel.append({
                propertyId: p.propertyId,
                title: p.title,
                description: p.description,
                price: p.price,
                district: p.district,
                village: p.village,
                location: p.location,
                propertyType: p.propertyType,
                status: p.status,
                isVerified: p.isVerified,
                isActive: p.isActive,
                landlord: p.landlord,
                landlordPhone: p.landlordPhone,
                ownerName: p.ownerName,
                ownerPhone: p.ownerPhone,
                amenities: p.amenities,
                roomCount: p.roomCount,
                rejectionReason: p.rejectionReason,
                matches: p.matches,
                imageUrl: p.imageUrl,
                imageUrls: p.imageUrls,
                createdAt: p.createdAt
            });
        }
    }

    function reload() {
        propertiesModelId.clear();

        var m = PropertyViewModel.propertyListModel;
        var n = m ? m.size() : 0;
        for (var i = 0; i < n; i++) {
            var item = m.at(i);
            var pid = item.propertyId;
            var locationText = ((item.village || "") + (item.district ? ", " + item.district : "")).trim();

            propertiesModelId.append({
                propertyId: pid,
                title: item.title || "Untitled",
                description: item.description || "",
                price: Number(item.price || 0),
                district: item.district || "",
                village: item.village || "",
                location: locationText,
                propertyType: String(item.propertyType || "").toUpperCase(),
                status: item.status || "",
                isVerified: String(item.status || "").toUpperCase() === "VERIFIED",
                isActive: item.active !== undefined ? item.active : true,
                landlord: item.landlord || "",
                landlordPhone: item.landlordPhone || "",
                ownerName: item.ownerName || "",
                ownerPhone: item.ownerPhone || "",
                amenities: pid ? m.amenitiesFor(pid).join("|") : "",
                roomCount: item.roomCount || 0,
                rejectionReason: item.rejectionReason || "",
                matches: true,
                imageUrl: "",
                imageUrls: "",
                createdAt: item.createdAt || ""
            });
        }

        applyFilter();
        scheduleMediaFetches();
        refreshCovers();
        refreshRecents();
    }

    function setFilter(type) {
        typeFilter = String(type || "ALL").toUpperCase();
        applyFilter();
    }

    // Recompute `matches` on every row without rebuilding the model.
    function applyFilter() {
        var wanted = typeFilter === "ALL" ? "" : typeFilter;
        var n = 0;
        for (var i = 0; i < propertiesModelId.count; i++) {
            var row = propertiesModelId.get(i);
            var status = String(row.status || "").toUpperCase();

            // Public visibility: only VERIFIED + active listings appear
            // on the client home.
            var publicVisible = status === "VERIFIED" && (row.isActive === true || row.isActive === "true");

            var typeMatch = wanted.length === 0 || String(row.propertyType).toUpperCase() === wanted;

            var match = publicVisible && typeMatch;
            propertiesModelId.setProperty(i, "matches", match);
            if (match)
                n++;
        }
        _visibleCount = n;
        refreshRecents();
    }

    // Fire getMediaByProperty(pid) once per property, ever.
    function scheduleMediaFetches() {
        var fired = 0;
        for (var i = 0; i < propertiesModelId.count; i++) {
            var pid = String(propertiesModelId.get(i).propertyId || "");
            if (pid.length === 0)
                continue;
            if (_mediaRequested[pid])
                continue;
            _mediaRequested[pid] = true;
            MediaViewModel.getMediaByProperty(pid);
            fired++;
        }
        if (fired > 0)
            coverRefreshTimer.restart();
    }

    // Read whatever media the shared MediaListModel already has for each
    // row, pick the primary (or the first), and write both imageUrl
    // (cover) and imageUrls (comma-joined list) into the row.
    function refreshCovers() {
        for (var i = 0; i < propertiesModelId.count; i++) {
            var pid = String(propertiesModelId.get(i).propertyId || "");
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
                // Put the cover first in the list, keep the rest order-stable.
                if (cover.length > 0) {
                    var reordered = [cover];
                    for (var u = 0; u < urls.length; u++)
                        if (urls[u] !== cover)
                            reordered.push(urls[u]);
                    urls = reordered;
                }
            }

            if (String(propertiesModelId.get(i).imageUrl) !== cover)
                propertiesModelId.setProperty(i, "imageUrl", cover);

            var joined = urls.join(",");
            if (String(propertiesModelId.get(i).imageUrls) !== joined)
                propertiesModelId.setProperty(i, "imageUrls", joined);
        }
        // Keep the recents mirror in sync — its cards need cover images too.
        refreshRecents();
    }

    Component.onCompleted: {
        reload();
        PropertyViewModel.getProperties();
    }

    // Media batch settled → refresh covers.
    Connections {
        target: MediaViewModel
        function onIsLoadingChanged(loading) {
            if (!loading)
                root.refreshCovers();
        }
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onCountChanged() {
            root.reload();
        }
        function onDataChanged() {
            root.reload();
        }
        function onModelReset() {
            root.reload();
        }
        function onRowsInserted() {
            root.reload();
        }
        function onRowsRemoved() {
            root.reload();
        }
    }

    // Stop hammering the media model once nothing changes.
    Connections {
        target: coverRefreshTimer
        function onTriggered() {
            var before = 0;
            for (var i = 0; i < propertiesModelId.count; i++)
                if (String(propertiesModelId.get(i).imageUrl).length > 0)
                    before++;

            root.refreshCovers();

            var after = 0;
            for (var j = 0; j < propertiesModelId.count; j++)
                if (String(propertiesModelId.get(j).imageUrl).length > 0)
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
}
