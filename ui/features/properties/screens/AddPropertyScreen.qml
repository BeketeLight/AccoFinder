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
    property var deferredPayload: null

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

    // The payload built by the wizard lacks the backend property id (it is only
    // known after createProperty returns), so stamp it in before the detail
    // screen opens — this lets it fetch rooms and photos for that property.
    function payloadWithPropertyId(payload) {
        if (payload && pendingPropertyId.length > 0 && !payload.propertyId)
            payload.propertyId = pendingPropertyId
        return payload
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
            // Property + every photo are now uploaded/attached. Tell the wizard
            // to stop the spinner and show the success state — its success
            // timer will emit registrationFinished, which performs the
            // (deferred) navigation. This keeps the loader visible during the
            // whole background upload instead of showing success prematurely.
            addPropertyPage.completeSubmission()
        }
    }

    // An upload errored out. Reset the pending media state so the fallback
    // timer doesn't also fire, then surface the error instead of an infinite
    // spinner. The property itself was already created on the backend, so the
    // user is not blocked from proceeding.
    function onMediaFailure(error) {
        navigationFallbackTimer.stop()
        pendingMediaIds = []
        pendingMediaTotal = 0
        pendingPropertyId = ""
        addPropertyPage.showError(qsTr("Some photos could not be uploaded: %1").arg(error))
    }

    // Moving on only once media have finished uploading and being attached.
    // This keeps the Connections below (and the pending media state) alive until
    // every photo is attached — otherwise the screen would be replaced before
    // the async uploads complete and the media would never be linked.
    function finishNavigation() {
        if (deferredPayload) {
            var payload = payloadWithPropertyId(deferredPayload)
            deferredPayload = null
            navigationFallbackTimer.stop()
            // Safety-net navigation (e.g. a failed upload) — hide the wizard's
            // busy overlay so it doesn't linger over the next screen.
            addPropertyPage.hideBusy()
            NavUtils.replace("../features/properties/screens/PropertyDetailScreen.qml",
                             { initialPayload: payload })
        }
    }
    // Safety net: if any upload fails (so onMediaUploaded never reaches the
    // total) still leave the wizard after a grace period instead of hanging.
    Timer {
        id: navigationFallbackTimer
        interval: 15000
        repeat: false
        onTriggered: addItemdId.finishNavigation()
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
        function onMediaError(error) {
            // A photo upload failed (e.g. backend S3 error). Releasing the
            // spinner and showing the error beats leaving the user stuck on an
            // indefinite loader. The created property still exists on the
            // backend (minus the failed photo) and can be revisited.
            addItemdId.onMediaFailure(error)
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
            // If there are photos, hold navigation until they are all uploaded
            // and attached (see finishNavigation) so the media is persisted.
            if (addItemdId.pendingMediaTotal > 0) {
                addItemdId.deferredPayload = payload
                navigationFallbackTimer.restart()
                console.log("Delaying navigation while", addItemdId.pendingMediaTotal,
                            "photos are still uploading")
            } else {
                addItemdId.deferredPayload = null
                NavUtils.replace("../features/properties/screens/PropertyDetailScreen.qml",
                                 { initialPayload: addItemdId.payloadWithPropertyId(payload) })
            }
        }
    }
}
