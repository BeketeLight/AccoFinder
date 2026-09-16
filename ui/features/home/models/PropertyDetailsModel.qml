import QtQuick 2.15

Item {
    id: root

    // Properties
    property string propertyId: ""
    property string imageUrl: ""
    property bool loading: false

    readonly property alias imageListModel: imageListModelId
    readonly property alias roomsModel: roomsModelId

    readonly property int imageCount: imageListModelId.count
    readonly property int roomCount: roomsModelId.count

    // Logging property changes for count bindings
    onRoomCountChanged: {
        console.log("PropertyDetailsModel [BINDING]: roomCount property updated ->", roomCount);
    }

    onImageCountChanged: {
        console.log("PropertyDetailsModel [BINDING]: imageCount property updated ->", imageCount);
    }

    property bool _roomsFetchRequested: false
    property bool _mediaFetchRequested: false

    // Models
    ListModel {
        id: imageListModelId
        onCountChanged: {
            console.log("PropertyDetailsModel [MODEL]: imageListModel count changed ->", count);
        }
    }

    ListModel {
        id: roomsModelId
        onCountChanged: {
            console.log("PropertyDetailsModel [MODEL]: roomsModel count changed ->", count);
        }
    }

    // Utility Functions

    /*
     * Determines whether media belongs to the property itself
     * rather than to a specific room.
     */
    function isPropertyLevel(roomId) {
        if (roomId === undefined || roomId === null)
            return true;

        var id = String(roomId);
        return id === "" || id === "-1" || id === "null";
    }

    /*
     * Safely extracts the media URL.
     */
    function mediaUrl(media) {
        if (!media)
            return "";

        if (media.url)
            return String(media.url);

        if (media.path)
            return String(media.path);

        return "";
    }

    /*
     * Safely gets a room ID regardless of the property name
     * returned by the backend layer.
     */
    function getRoomId(room) {
        if (!room)
            return "";

        if (room._id !== undefined && room._id !== null)
            return String(room._id);

        if (room.roomId !== undefined && room.roomId !== null)
            return String(room.roomId);

        if (room.id !== undefined && room.id !== null)
            return String(room.id);

        return "";
    }

    /*
     * Gets the room type.
     */
    function getRoomType(room) {
        if (!room)
            return "Room";

        if (room.roomType !== undefined && room.roomType !== null)
            return String(room.roomType);

        if (room.type !== undefined && room.type !== null)
            return String(room.type);

        return "Room";
    }

    /*
     * Gets the room price.
     */
    function getRoomPrice(room) {
        if (!room)
            return 0;

        return Number(room.price || 0);
    }

    /*
     * Converts different possible availability values into a boolean.
     */
    function getRoomAvailability(room) {
        if (!room)
            return false;

        return room.available === true || room.available === "true" || room.available === 1;
    }

    /*
     * Determines whether media is marked as primary.
     */
    function isPrimaryMedia(media) {
        if (!media)
            return false;

        return media.isPrimary === true || media.isPrimary === 1 || media.isPrimary === "true";
    }

    /*
     * Finds the primary image URL belonging to a specific room.
     */
    function findRoomImage(media, roomId, roomIndex) {
        var targetRoomId = String(roomId || "");
        var targetIndexStr = String(roomIndex + 1);

        if (!media || media.length === undefined || media.length === 0) {
            return "";
        }

        var firstImage = "";

        for (var i = 0; i < media.length; i++) {
            var item = media[i];

            if (!item || item.roomId === undefined || item.roomId === null)
                continue;

            var mediaRoomId = String(item.roomId);

            var isMatch = (mediaRoomId === targetRoomId && targetRoomId.length > 0) || (mediaRoomId === targetIndexStr);

            if (!isMatch)
                continue;

            var url = mediaUrl(item);
            if (!url.length)
                continue;

            if (!firstImage.length) {
                firstImage = url;
            }

            if (isPrimaryMedia(item)) {
                return url;
            }
        }

        return firstImage;
    }

    /*
     * Collects ALL images belonging to a specific room.
     */
    function findRoomImages(media, roomId, roomIndex) {
        var targetRoomId = String(roomId || "");
        var targetIndexStr = String(roomIndex + 1);

        if (!media || media.length === undefined || media.length === 0) {
            return [];
        }

        var images = [];

        for (var i = 0; i < media.length; i++) {
            var item = media[i];

            if (!item || item.roomId === undefined || item.roomId === null)
                continue;

            var mediaRoomId = String(item.roomId);
            console.log("comparing sought for room id ", targetIndexStr, " to found media room id ", mediaRoomId);
            //console.log("comparing sought for room id ", roomId, " to found media room id ", item.roomId);
            var isMatch = (mediaRoomId === targetRoomId && targetRoomId.length > 0) || (mediaRoomId === targetIndexStr);

            if (!isMatch)
                continue;

            var url = mediaUrl(item);
            if (!url.length)
                continue;

            if (isPrimaryMedia(item)) {
                images.unshift(url);
            } else {
                images.push(url);
            }
        }

        return images;
    }

    // Rebuild Property Gallery

    function rebuildPropertyImages(media) {
        imageListModelId.clear();
        root.imageUrl = "";

        if (!media || media.length === undefined)
            return;

        var gallery = [];
        var primaryImage = "";

        for (var i = 0; i < media.length; i++) {
            var item = media[i];

            console.log("the sought roomId for whole proprty pictures ", item.roomId);

            if (!item || !isPropertyLevel(item.roomId))
                continue;

            var url = mediaUrl(item);
            if (!url.length)
                continue;

            var primary = isPrimaryMedia(item);

            gallery.push({
                url: url,
                primary: primary
            });

            if (primary && !primaryImage.length)
                primaryImage = url;
        }

        if (!primaryImage.length && gallery.length)
            primaryImage = gallery[0].url;

        if (primaryImage.length) {
            imageListModelId.append({
                url: primaryImage
            });

            for (var g = 0; g < gallery.length; g++) {
                if (gallery[g].url === primaryImage)
                    continue;
                imageListModelId.append({
                    url: gallery[g].url
                });
            }
        }

        root.imageUrl = primaryImage;
        //console.log("PropertyDetailsModel [PROPERTY GALLERY]: Final imageListModel count =", imageListModelId.count, "| Cover imageUrl =", root.imageUrl);
    }

    // Rebuild Rooms

    function rebuildRooms(rooms, media) {
        //console.log("PropertyDetailsModel [REBUILD ROOMS]: Clearing roomsModelId...");
        roomsModelId.clear();

        if (!rooms) {
            // console.log("PropertyDetailsModel [REBUILD ROOMS]: Exiting early. Raw rooms is null/undefined");
            return;
        }

        //console.log("PropertyDetailsModel [REBUILD ROOMS]: Starting processing for", rooms.length, "raw room items.");

        for (var i = 0; i < rooms.length; i++) {
            var room = rooms[i];

            if (!room)
                continue;

            var roomId = getRoomId(room);
            if (!roomId.length) {
                // console.log("PropertyDetailsModel [REBUILD ROOMS]: Skipping room index", i, "due to missing roomId.");
                continue;
            }

            var roomType = getRoomType(room);
            var roomPrice = getRoomPrice(room);
            var roomAvailable = getRoomAvailability(room);
            var roomSize = (room.size !== undefined && room.size !== null) ? String(room.size) : "";

            // 1. Get array of all images
            var roomImages = findRoomImages(media, roomId, i);

            // 2. Cover image for single-image bindings
            var primaryRoomImage = roomImages.length > 0 ? roomImages[0] : findRoomImage(media, roomId, i);

            //console.log("PropertyDetailsModel [REBUILD ROOMS]: Assigning room to model ->", "roomId =", roomId, "type =", roomType, "price =", roomPrice, "available =", roomAvailable, "size =", roomSize, "imageUrl =", primaryRoomImage);

            roomsModelId.append({
                roomId: roomId,
                type: roomType,
                price: roomPrice,
                available: roomAvailable,
                size: roomSize,
                imageUrl: primaryRoomImage,
                images: roomImages
            });
        }

        //console.log("PropertyDetailsModel [REBUILD ROOMS]: Complete. Total rooms in model =", roomsModelId.count, "| Property roomCount =", root.roomCount);
    }

    // Main Rebuild

    function rebuild() {
        var pid = String(root.propertyId || "");

        //console.log("PropertyDetailsModel [REBUILD]: Triggered for propertyId =", pid);

        if (!pid.length) {
            imageListModelId.clear();
            roomsModelId.clear();
            root.imageUrl = "";
            // console.log("PropertyDetailsModel [REBUILD]: propertyId is empty, skipping.");
            return;
        }

        var media = [];
        try {
            media = MediaViewModel.mediaForProperty(pid) || [];
            //console.log("PropertyDetailsModel: Managed to get media for", pid, "| Count =", media.length);
        } catch (error) {
            //console.log("PropertyDetailsModel: Failed to get media:", error);
            media = [];
        }

        var rooms = [];
        try {
            rooms = RoomViewModel.roomsForProperty(pid) || [];
            //console.log("PropertyDetailsModel: Managed to get rooms for", pid, "| Count =", rooms.length);
        } catch (error2) {
            // console.log("PropertyDetailsModel: Failed to get rooms:", error2);
            rooms = [];
        }

        rebuildPropertyImages(media);
        rebuildRooms(rooms, media);
    }

    function updateLoading() {
        var mediaLoading = false;
        var roomsLoading = false;

        try {
            mediaLoading = MediaViewModel.isLoading;
        } catch (e) {}
        try {
            roomsLoading = RoomViewModel.isLoading;
        } catch (e) {}

        root.loading = mediaLoading || roomsLoading;
        // console.log("PropertyDetailsModel [LOADING]: State updated -> loading =", root.loading);
    }

    function refresh() {
        var pid = String(root.propertyId || "");

        //  console.log("PropertyDetailsModel [REFRESH]: Called for propertyId =", pid);

        if (!pid.length) {
            rebuild();
            return;
        }

        try {
            if (!_mediaFetchRequested) {
                _mediaFetchRequested = true;
                // console.log("PropertyDetailsModel: Requesting media for property:", pid);
                MediaViewModel.getMediaByProperty(pid);
            }
        } catch (error) {
            //  console.log("PropertyDetailsModel: Media request failed:", error);
        }

        try {
            if (!_roomsFetchRequested) {
                _roomsFetchRequested = true;
                //  console.log("PropertyDetailsModel: Requesting rooms for property:", pid);
                RoomViewModel.loadRooms();
            }
        } catch (error2) {
            //  console.log("PropertyDetailsModel: Room request failed:", error2);
        }

        updateLoading();
        rebuild();
    }

    onPropertyIdChanged: {
        //console.log("PropertyDetailsModel [EVENT]: propertyId changed ->", propertyId);
        _roomsFetchRequested = false;
        _mediaFetchRequested = false;
        refresh();
    }

    Component.onCompleted: {
        //console.log("PropertyDetailsModel.qml started");
        refresh();
    }

    // ViewModel Connections to handle async network completion
    Connections {
        target: MediaViewModel
        function onIsLoadingChanged() {
            root.updateLoading();
            if (!MediaViewModel.isLoading) {
                root.rebuild();
            }
        }
    }

    Connections {
        target: RoomViewModel
        function onIsLoadingChanged() {
            root.updateLoading();
            if (!RoomViewModel.isLoading) {
                root.rebuild();
            }
        }
    }
}
