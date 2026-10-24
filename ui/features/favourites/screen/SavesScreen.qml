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
        // ============================================================
        // TEMPORARY DEBUG PANEL — remove before shipping.
        // Shows exactly what AppSettings has persisted. If the saved
        // lists are empty here, the bug is in AppSettings or the heart
        // handlers, not in the Saves UI.
        // ============================================================
        Rectangle {
            id: debugPanel
            Layout.fillWidth: true
            Layout.preferredHeight: debugColumn.implicitHeight + 16
            color: "#0F172A"        // dark slate so it stands out from the app UI
            radius: 0

            property string propertyIdsText: ""
            property string roomIdsText: ""
            property string roomSnapshotsText: ""

            function refresh() {
                // Reads exactly what AppSettings stored.
                var pIds = AppSettings.favoritePropertyIds;
                var rIds = AppSettings.favoriteRoomIds;

                propertyIdsText = (pIds && pIds.length) ? pIds.join(", ") : "(none)";

                roomIdsText = (rIds && rIds.length) ? rIds.join(", ") : "(none)";

                // For every saved room, print the cached snapshot in compact form.
                // This is the same data SavedRoomDelegate renders from.
                if (rIds && rIds.length) {
                    var lines = [];
                    for (var i = 0; i < rIds.length; i++) {
                        var snap = AppSettings.favoriteRoomSnapshot(rIds[i]);
                        var parsed = JSON.parse(JSON.stringify(snap));   // QVariantMap → plain
                        var summary = parsed ? ["id=" + (parsed.quarterId || rIds[i]), "prop=" + (parsed.propertyId || ""), "type=" + (parsed.type || ""), "price=" + (parsed.price || 0), "img=" + (parsed.imageUrl ? "yes" : "no")].join("  ") : "(no snapshot)";
                        lines.push("  • " + summary);
                    }
                    roomSnapshotsText = lines.join("\n");
                } else {
                    roomSnapshotsText = "  (none)";
                }
            }

            Connections {
                target: AppSettings
                function onFavoritePropertyIdsChanged() {
                    debugPanel.refresh();
                }
                function onRoomFavoritesChanged() {
                    debugPanel.refresh();
                }
                function onUserSessionChanged() {
                    debugPanel.refresh();
                }
            }

            Component.onCompleted: refresh()

            ColumnLayout {
                id: debugColumn
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Label {
                    text: qsTr("DEBUG — AppSettings persistence")
                    color: "#FACC15"
                    font.pixelSize: 11
                    font.bold: true
                }

                Label {
                    Layout.fillWidth: true
                    text: "favoritePropertyIds (" + AppSettings.favoritePropertyIds.length + "): " + debugPanel.propertyIdsText
                    color: "#E5E7EB"
                    font.pixelSize: 10
                    font.family: "monospace"
                    wrapMode: Text.WrapAnywhere
                }

                Label {
                    Layout.fillWidth: true
                    text: "favoriteRoomIds (" + AppSettings.favoriteRoomIds.length + "): " + debugPanel.roomIdsText
                    color: "#E5E7EB"
                    font.pixelSize: 10
                    font.family: "monospace"
                    wrapMode: Text.WrapAnywhere
                }

                Label {
                    Layout.fillWidth: true
                    text: "roomSnapshots:\n" + debugPanel.roomSnapshotsText
                    color: "#93C5FD"
                    font.pixelSize: 10
                    font.family: "monospace"
                    wrapMode: Text.WrapAnywhere
                }
            }
        }
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
