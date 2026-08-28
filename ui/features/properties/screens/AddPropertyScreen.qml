import QtQuick
import "../pages"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: addItemdId

    property alias pageTitle: addPropertyPage.pageTitle
    property alias showHeader: addPropertyPage.showHeader

    property var pendingPayload: null
    property var pendingMediaIds: []
    property int pendingMediaTotal: 0
    property string pendingPropertyId: ""

    function goBack() {
        addPropertyPage.goBack()
    }

    function createRoomsAndMedia(propertyId) {
        var payload = pendingPayload
        if (!payload)
            return

        pendingPropertyId = propertyId
        pendingMediaIds = []
        pendingMediaTotal = payload.photos ? payload.photos.length : 0

        if (pendingMediaTotal === 0)
            return

        if (payload.photos) {
            for (var j = 0; j < payload.photos.length; j++) {
                var photo = payload.photos[j]
                MediaViewModel.createMedia(propertyId,
                                           photo.path,
                                           "image",
                                           photo.isPrimary,
                                           String(photo.roomId !== undefined ? photo.roomId : -1))
            }
        }
    }

    function onMediaUploaded(mediaId) {
        if (!mediaId || mediaId.length === 0)
            return
        pendingMediaIds.push(mediaId)
        if (pendingMediaIds.length >= pendingMediaTotal && pendingPropertyId.length > 0) {
            PropertyViewModel.attachMedia(pendingPropertyId, pendingMediaIds)
            pendingMediaIds = []
            pendingMediaTotal = 0
            pendingPropertyId = ""
        }
    }

    Connections {
        target: PropertyViewModel
        function onPropertyCreatedSignal(id, title) {
            addItemdId.createRoomsAndMedia(id)
        }
    }

    Connections {
        target: MediaViewModel
        function onMediaCreatedSignal(mediaId) {
            addItemdId.onMediaUploaded(mediaId)
        }
    }

    Connections {
        target: PropertyViewModel
        function onPropertyError(error) {
            console.log("Property create error:", error)
            // Persist the unsent property as a draft so the data survives an app
            // restart and can be resent later from the Drafts screen.
            if (pendingPayload)
                DraftViewModel.saveDraft(pendingPayload)
            pendingPayload = null
        }
    }

    AddPropertiesPage {
        id: addPropertyPage
        anchors.fill: parent

        onPropertySubmitted: function (payload) {
            if (payload) {
                // Rooms are sent inline so the property and its rooms are
                // created atomically in one request.
                pendingPayload = payload
                var roomsArr = []
                if (payload.rooms) {
                    for (var k = 0; k < payload.rooms.length; k++) {
                        var r = payload.rooms[k]
                        roomsArr.push({
                                          type: r.roomType !== undefined ? r.roomType : "Room",
                                          price: r.price !== undefined ? r.price : 0,
                                          available: r.available !== undefined ? r.available : true
                                      })
                    }
                }
                PropertyViewModel.createProperty(
                    payload.title,
                    payload.description,
                    payload.price,
                    payload.propertyType !== undefined && payload.propertyType.length > 0
                        ? payload.propertyType : "WHOLE",
                    payload.physicalAddress && payload.physicalAddress.district,
                    payload.physicalAddress && payload.physicalAddress.village,
                    payload.amenities,
                    payload.landlord,
                    payload.landlordPhone,
                    payload.verificationStatus,
                    payload.isActive !== undefined ? payload.isActive : true,
                    roomsArr)
            }
        }

        onDraftSaved: function (payload) {
            console.log("Property draft saved:", JSON.stringify(payload))
            if (payload)
                DraftViewModel.saveDraft(payload)
        }

        onRegistrationFinished: function (payload) {
            NavUtils.replace("../features/properties/screens/PropertyDetailScreen.qml",
                             { initialPayload: payload })
        }
    }
}
