import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../pages"
import "../../home/models"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root
    objectName: "SavesScreen"

    property string pageTitle: qsTr("Saves")
    property bool showHeader: true
    property bool showBack: false
    property bool showBackButton: false
    property bool showBottomBorder: true
    property bool isSearchBar: false
    property int titleFontSize: 15

    property int currentTab: 0

    // The shared home feed. Injected by the host (HomeScreen / MainStackView)
    // so the Saves screen and the home screen see the same rows and neither
    // fetches on its own.
    property var sharedPropertiesModelRef: null

    // Rebuilt on every save/unsave so the tab counters stay live.
    property int propertiesCount: 0
    property int roomsCount: 0

    function refreshCounts() {
        propertiesCount = AppSettings.favoritePropertyIds.length;
        roomsCount = AppSettings.favoriteRoomIds.length;
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
        // Adjust to however your home flow exposes rooms. If RoomViewModel
        // already has a "roomById" accessor, use it directly. The shape the
        // delegate expects is:
        //   { roomId, propertyId, type, price, location, imageUrl,
        //     available, holdActive, holdExpiresAt }
        try {
            if (typeof RoomViewModel !== "undefined" && RoomViewModel.roomById !== undefined) {
                var r = RoomViewModel.roomById(roomId);
                if (r)
                    return r;
            }
        } catch (e) {}

        // Fallback: scan every property's room list if your model offers one.
        // Kept minimal here on purpose — point this at whatever source the home
        // screen already populated, do not fetch.
        return null;
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
        function onPropertyFavoritesChanged() {
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
