import QtQuick

Item {
    id: root

    //Exposable properties to be used in pages
    property string propertyId: ""
    property string roomId: ""
    property string propertyImage: ""

    property bool mediaRequestStarted: false

    //use propertyid & roomId to get image
    function coverImageFor(propertyId, roomId) {
        if (!propertyId || typeof MediaViewModel === "undefined")
            return ""
        var list = MediaViewModel.mediaForProperty(propertyId)
        if (!list || list.length === 0)
            return ""

        //prefer the image belonging to booked room
        if (roomId) {
            var want = String(roomId).trim()
            for (var i = 0; i < list.length; i++) {
                var mRoom = String(list[i].roomId !== null ? list[i].roomId : "").trim()
                var url = list[i].url || list[i].path || ""
                if (mRoom.length && mRoom !== "-1" && mRoom === want && url)
                    return url
            }
        }
        for (var j = 0; j < list.length; j++) {
            if (list[j].isPrimary) {
                var primaryUrl = list[j].url || list[j].path || ""
                if (primaryUrl)
                    return primaryUrl
            }
        }
        for (var k = 0; k < list.length; k++) {
            var rid = String(list[k].roomId !== null ? list[k].roomId : "").trim()
            if (rid === "" || rid === "-1") {
                var propertyUrl = list[k].url || list[k].path || ""
                if (propertyUrl)
                    return propertyUrl
            }
        }
        return list[0].url || list[0].path || ""
    }

    //Get propertyId from the Page
    //if not passed
    function resolvePropertyId() {
        var pid = String(root.propertyId || "").trim()
        if (pid.length)
            return pid
        var rid = String(root.roomId || "").trim()
        if (!rid.length || typeof RoomViewModel === "undefined")
            return ""
        var room = RoomViewModel.getRoomById(rid) || {}
        var fromRoom = room.propertyId || ""
        if (typeof fromRoom === "object" && fromRoom)
            fromRoom = fromRoom._id || fromRoom.id || ""
        return String(fromRoom || "").trim()
    }

    //Calls CoverImageFor function
    //then sets propertyimage
    function applyCoverImage() {
        var pid = resolvePropertyId()
        if (!pid.length)
            return
        var imageUrl = coverImageFor(pid, root.roomId)
        if (imageUrl.length)
            root.propertyImage = imageUrl
    }

    //Resolves property Id by calling MediaRequest
    //Then calls applyCoverImage for cach
    function requestPropertyMedia() {
        var pid = resolvePropertyId()
        if (!pid.length)
            return

        applyCoverImage()
        if (root.propertyImage.length > 0){
            console.log("Image from media cache:", root.propertyImage)
            return
        }


        //Request image  from media
        //Otherwise use the cached one
        //helps to avoid repeated calling for already cached image
        if (!mediaRequestStarted) {
            mediaRequestStarted = true
            console.log("Media cache miss, fetching:", pid)
            MediaViewModel.getMediaByProperty(pid)
        }
        // Use cached media if it already exists.
        applyCoverImage()
    }

    onPropertyIdChanged: {
        mediaRequestStarted = false
        propertyImage = ""
        requestPropertyMedia()
    }
    onRoomIdChanged: {
        mediaRequestStarted = false
        requestPropertyMedia()
    }

    Component.onCompleted: requestPropertyMedia()

    Connections {
        target: MediaViewModel.mediaListModel
        function onRowsInserted()  { root.applyCoverImage() }
        function onModelReset()    { root.applyCoverImage() }
        function onDataChanged()   { root.applyCoverImage() }
        function onCountChanged()  { root.applyCoverImage() }
    }
}