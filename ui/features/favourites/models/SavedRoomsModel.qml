import QtQuick

// Read-only mirror of the saved room rows. Scans the shared home rooms model
// for ids present in AppSettings.favoriteRoomIds. Each kept row keeps its
// parent propertyId so tapping the card can open the room's detail page with
// the correct property context.
Item {
    id: root

    // The shared rooms source. HomeScreen owns the PropertiesModel; rooms come
    // from RoomViewModel (already fetched by the home flow). We don't fetch.
    property var roomsSource: null     // e.g. a JS array, ListModel, or provider fn

    readonly property alias model: savedModel
    readonly property int count: savedModel.count

    ListModel {
        id: savedModel
    }

    // Caller supplies this — see SavesScreen. Given a roomId it returns the
    // room row (with its propertyId). Keeping it as a function lets the model
    // work with a ListModel, a JS array, or a C++ view model without any
    // coupling here.
    property var lookupRoom: null

    function reload() {
        savedModel.clear();

        var ids = AppSettings.favoriteRoomIds;
        if (!ids || ids.length === 0)
            return;
        if (!root.lookupRoom)
            return;

        for (var i = 0; i < ids.length; i++) {
            var row = root.lookupRoom(ids[i]);
            if (!row)
                continue;
            savedModel.append({
                roomId: row.roomId,
                propertyId: row.propertyId      // ← the room's parent property
                ,
                quarterType: row.type || row.roomType || "Room",
                quarterTitle: row.title || "",
                quarterPrice: Number(row.price || 0),
                location: row.location || "",
                imageUrl: row.imageUrl || "",
                available: row.available === undefined ? true : row.available,
                holdActive: row.holdActive === true,
                holdExpiresAt: row.holdExpiresAt || null
            });
        }
    }

    Connections {
        target: AppSettings
        function onRoomFavoritesChanged() {
            root.reload();
        }
    }

    onLookupRoomChanged: reload()

    Component.onCompleted: reload()
}
