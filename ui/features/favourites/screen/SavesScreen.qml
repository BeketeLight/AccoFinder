import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../pages"
import "../../home/models"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root
    // Must match the case in main.qml's loader.onLoaded dispatcher.
    objectName: "SavesScreen"

    property string pageTitle: qsTr("Saves")
    property bool showHeader: true
    property bool showBack: false
    property bool showBackButton: false
    property bool showBottomBorder: true
    property bool isSearchBar: false
    property int titleFontSize: 15

    property int currentTab: 0

    // Injected by main.qml's loader.onLoaded when the footer opens this
    // screen. Falls back to a private instance so a deep-link / debug path
    // still renders something instead of silently showing an empty tab.
    property var sharedPropertiesModelRef: privateProperties
    PropertiesModel {
        id: privateProperties
    }

    // Rebuilt on every save/unsave so the tab counters stay live.
    property int propertiesCount: 0
    property int roomsCount: 0

    function refreshCounts() {
        propertiesCount = AppSettings.favoritePropertyIds().length;
        roomsCount = AppSettings.favoriteRoomIds().length;
    }

    function removeProperty(pid) {
        var ids = AppSettings.favoritePropertyIds;
        var idx = ids.indexOf(pid);
        if (idx >= 0) {
            ids.splice(idx, 1);
            AppSettings.setFavoritePropertyIds(ids);
        }
        refreshCounts();
    }

    function removeRoom(rid) {
        AppSettings.toggleFavoriteRoom(rid);   // toggles off
        refreshCounts();
    }

    // ---- Room lookup: given a roomId, find its row in the shared home room
    // source. Your home flow already keeps rooms around (RoomViewModel / the
    // rooms model each property uses). Expose it via a small helper here so
    // SavedRoomsModel stays agnostic about the storage format.
    function lookupRoom(roomId) {
        // 1) Live cache — the room is already in the shared roomListModel.
        //    RoomViewModel exposes getRoomById(roomId), not roomById.
        try {
            if (typeof RoomViewModel !== "undefined" && RoomViewModel.getRoomById !== undefined) {
                var r = RoomViewModel.getRoomById(roomId);
                if (r && r.id)
                    return r;
            }
        } catch (e) {}

        // 2) Fallback: the snapshot written by QuartersDetailDelegate when
        //    the user bookmarked the room. Works on a cold start before any
        //    /rooms/ call, which is what the Saves screen needs.
        var snap = AppSettings.favoriteRoomSnapshot(roomId);
        if (!snap || !snap.quarterId)
            return null;

        return {
            roomId: snap.quarterId,
            propertyId: snap.propertyId,
            type: snap.type,
            title: snap.title,
            price: snap.price,
            location: snap.location,
            imageUrl: snap.imageUrl,
            available: snap.available === undefined ? true : snap.available,
            holdActive: snap.holdActive === true,
            holdExpiresAt: snap.holdExpiresAt || null
        };
    }

    Connections {
        target: AppSettings
        function onUserSessionChanged() {
            root.refreshCounts();
        }
        function onRoomFavoritesChanged() {
            root.refreshCounts();
        }
        function onFavoritePropertyIdsChanged() {
            root.refreshCounts();
        }
    }

    Component.onCompleted: refreshCounts()

    Rectangle {
        color: "#F8FAFC"
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SavesTabStrip {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            currentIndex: root.currentTab
            propertiesCount: root.propertiesCount
            roomsCount: root.roomsCount
            onTabChanged: function (index) {
                root.currentTab = index;
            }
        }

        SavesPage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentTab: root.currentTab
            propertiesModelRef: root.sharedPropertiesModelRef
            roomLookupFn: root.lookupRoom
            onRemoveProperty: function (pid) {
                root.removeProperty(pid);
            }
            onRemoveRoom: function (rid) {
                root.removeRoom(rid);
            }
        }
    }
}
