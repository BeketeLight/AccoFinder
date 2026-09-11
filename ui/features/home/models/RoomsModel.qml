import QtQuick 2.15

Item {
    id: root

    property string propertyId: ""
    readonly property alias roomsModel: roomsModelId
    readonly property int count: roomsModelId.count
    readonly property bool loading: RoomViewModel.isLoading

    ListModel {
        id: roomsModelId
    }

    function reload() {
        roomsModelId.clear();
        if (!propertyId)
            return;
        var rows = RoomViewModel.roomsForProperty(propertyId) || [];
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i] || {};
            roomsModelId.append({
                roomId: String(r.roomId || ""),
                roomType: r.roomType || "Room",
                price: Number(r.price || 0),
                available: r.available === true || String(r.available) === "true",
                // placeholders until backend supplies these
                size: "",
                imageUrl: "",
                description: ""
            });
        }
    }

    onPropertyIdChanged: reload()

    Component.onCompleted: {
        reload();
        RoomViewModel.loadRooms();
    }

    Connections {
        target: RoomViewModel.roomListModel
        function onCountChanged() {
            root.reload();
        }
        function onDataChanged() {
            root.reload();
        }
        function onModelReset() {
            root.reload();
        }
    }
}
