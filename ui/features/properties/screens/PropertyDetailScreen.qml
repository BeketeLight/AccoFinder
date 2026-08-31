import QtQuick 2.15
import "../../../utils/Utils.js" as UtilsModule
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
            // Photos live in the separate /media/ collection. Server-backed
            // properties (with a property id) pull their photos here; drafts
            // keep the local photos supplied by their payload.
            loadMedia()
        }

        onPropertyDeleted: {
            // Drop the property's images from the local image cache so a
            // removed property can't later be shown from a stale cached copy.
            // Guarded: cache invalidation must never block the actual delete
            // below if the helper is missing/unavailable on this build.
            try {
                if (UtilsModule && typeof UtilsModule.invalidateImages === "function")
                    UtilsModule.invalidateImages(detailPage.photosList)
            } catch (err) {
                console.log("PropertyDetailScreen: cache invalidation skipped:", err)
            }
            // Fire the backend delete for a server-backed property. Draft items
            // (no propertyId) are removed locally via DraftViewModel in the page.
            if (detailPage.propertyId && detailPage.propertyId.length > 0)
                PropertyViewModel.deleteProperty(detailPage.propertyId)
        }
    }

    // Map this property's media (fetched through MediaViewModel) into the
    // page's photos list. Server-backed photos override the payload's local
    // ones; when nothing is on the server yet the payload photos are kept.
    function loadMedia() {
        if (detailPage.isDraftItem)
            return
        if (!detailPage.propertyId || detailPage.propertyId.length === 0)
            return
        var serverPhotos = MediaViewModel.mediaForProperty(detailPage.propertyId)
        if (serverPhotos && serverPhotos.length > 0)
            detailPage.photosList = serverPhotos
        else
            MediaViewModel.getMediaByProperty(detailPage.propertyId)
    }

    // Media arrive asynchronously after the fetch above; refresh the photos
    // grid once the shared media list is replaced or grows.
    Connections {
        target: MediaViewModel.mediaListModel
        function onCountChanged() { loadMedia() }
        function onModelReset() { loadMedia() }
    }
}
