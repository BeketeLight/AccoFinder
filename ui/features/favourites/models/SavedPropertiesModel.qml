import QtQuick
import "../../../utils/Utils.js" as Utils

// Read-only mirror of the saved property rows. Populated by scanning the shared
// home PropertiesModel for ids that appear in AppSettings.favoritePropertyIds.
// Nothing is fetched here — the source model is already populated by
// PropertyViewModel when the home screen is loaded.
Item {
    id: root

    // The shared home PropertiesModel (the same instance HomeScreen owns).
    property var sourceModel: null

    readonly property alias model: savedModel
    readonly property int count: savedModel.count

    // The Saves tab is cached. Rebuild only while it is visible and its
    // Flickable is idle; otherwise the Repeater is torn down mid-flick.
    property bool refreshAllowed: true
    readonly property bool canRebuild: root.refreshAllowed && Utils.isPageActive(root)
    property bool _reloadPending: false

    ListModel {
        id: savedModel
    }

    function requestReload() {
        root._reloadPending = true;
        if (root.canRebuild && !reloadTimer.running)
            reloadTimer.start();
    }

    onCanRebuildChanged: {
        if (root.canRebuild && root._reloadPending && !reloadTimer.running)
            reloadTimer.start();
    }

    Timer {
        id: reloadTimer
        interval: 80
        repeat: true
        running: false
        onTriggered: {
            if (!root.canRebuild)
                return;
            stop();
            root._reloadPending = false;
            root.reload();
        }
    }

    // Rebuild by scanning sourceModel once and picking the rows whose
    // propertyId is in the saved-ids list. Order is preserved from the ids
    // list so the most recently saved can be shown first if you ever want that.
    function reload() {
        savedModel.clear();

        var ids = AppSettings.favoritePropertyIds();   // QStringList → JS array
        if (!ids || ids.length === 0)
            return;

        // Build a lookup set for O(1) membership tests.
        var wanted = {};
        for (var i = 0; i < ids.length; i++)
            wanted[String(ids[i])] = true;

        var src = root.sourceModel ? root.sourceModel.propertiesModel : null;
        if (!src)
            return;

        for (var j = 0; j < src.count; j++) {
            var row = src.get(j);
            if (!wanted[String(row.propertyId)])
                continue;

            savedModel.append({
                propertyId: row.propertyId,
                title: row.title,
                description: row.description,
                price: row.price,
                location: row.location,
                propertyType: row.propertyType,
                status: row.status,
                isVerified: row.isVerified,
                isActive: row.isActive,
                amenities: row.amenities,
                imageUrl: row.imageUrl,
                imageUrls: row.imageUrls
            });
        }
    }

    // Watch the source model for count/data changes, and the AppSettings
    // favourites for id-list changes.
    onSourceModelChanged: root.requestReload()

    Connections {
        target: root.sourceModel ? root.sourceModel.propertiesModel : null
        enabled: root.sourceModel !== null
        function onCountChanged() {
            root.requestReload();
        }
        function onDataChanged() {
            root.requestReload();
        }
        function onModelReset() {
            root.requestReload();
        }
    }

    Connections {
        target: AppSettings
        function onFavoritePropertyIdsChanged() {
            root.requestReload();
        }
    }

    Component.onCompleted: reload()
}
