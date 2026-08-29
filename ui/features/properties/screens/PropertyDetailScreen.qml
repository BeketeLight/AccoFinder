import QtQuick 2.15
import "../pages"
Item {
    id:propertiesdetailsId

    property var initialPayload: null

    PropertyDetailsPage{
        id: detailPage
        anchors.fill: parent
        Component.onCompleted: {
            if (initialPayload)
                detailPage.applyPayload(initialPayload)
            // Rooms are stored in the separate /rooms/ collection, so fetch
            // them up front; the page rebuilds its room list once they arrive.
            RoomViewModel.loadRooms()
        }
    }
}
