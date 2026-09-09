import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"
import "../../../components/inputs"
import "../../../components/indicators"
import "../../../components/scrollbars"
import "../../../components/cards"
import "../../../components/dialogs"
import "../../../utils" as UtilsModule

Page {
    id: root

    readonly property color pageColor: "#F8FAFC"
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color secondaryColor: "#22C55E"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color softRedColor: "#FEF2F2"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property string propertyTitleName: qsTr("Sunset Apartments")
    property string propertyDistrictValue: qsTr("Lilongwe")
    property string propertyVillageValue: qsTr("Area 47")
    property real monthlyPrice: 0
    // The whole-property price is optional (per-room prices apply for
    // hostel/quarter listings). This flag hides the price UI when absent.
    readonly property bool hasMonthlyPrice: root.monthlyPrice > 0
    // verificationStatus mirrors the backend enum: PENDING / VERIFIED / REJECTED ("" = local draft)
    property string verificationStatus: "PENDING"
    property string rejectionReason: ""
    property string descriptionTextValue: qsTr("Modern three-bedroom house with spacious rooms, tiled floors and a perimeter fence. Close to shops and public transport.")
    property string landlordName: qsTr("Bryan Phiri")
    property string landlordPhone: qsTr("+265 999 123 456")

    // Person who submitted/owns the listing. Populated from the property's
    // `owner` object (populated by the backend) via applyPayload.
    property string ownerName: ""
    property string ownerPhone: ""

    // Backend id used to match this property's rooms in the separate /rooms/
    // collection (the property document does not embed its rooms).
    property string propertyId: ""

    property var amenitiesList: []
    property var roomsList: []
    property var photosList: []

    readonly property string prettyStatus: {
        var s = String(root.verificationStatus).toUpperCase()
        if (s === "VERIFIED") return qsTr("Verified")
        if (s === "PENDING") return qsTr("Pending")
        if (s === "REJECTED") return qsTr("Rejected")
        if (s === "DRAFT") return qsTr("Draft")
        return s.length > 0 ? s : qsTr("Draft")
    }

    readonly property bool agentMode: AppSettings.userType() === "AGENT"
                                      || AppSettings.userType() === "ADMIN"
                                      || AppSettings.userType() === "SUPER_ADMIN"
    property bool editMode: false

    property string editNameValue: ""
    property string editDistrictValue: ""
    property string editVillageValue: ""
    property string editMonthlyPriceValue: ""
    property string editDescriptionValue: ""
    property string editLandlordNameValue: ""
    property string editLandlordPhoneValue: ""

    // Key of the local draft this page was opened from (empty for a normal
    // server-backed property). Set when a draft is opened via detail.
    property string draftKey: ""

    // A draft is a local unsent listing awaiting review/resend. It exposes a
    // dedicated "Resend" action instead of "Edit property".
    readonly property bool isDraftItem: root.draftKey.length > 0
                                        || String(root.verificationStatus).toUpperCase() === "DRAFT"

    signal propertyUpdated(var data)
    signal propertyDeleted()

    // True while a server-backed property's edits are being submitted (PUT).
    // Keeps the page in edit mode with a "Saving..." button until the backend
    // confirms so the agent is not misled into thinking the save stuck.
    property bool savingInProgress: false
    // Last message explaining why a save/photo operation could not complete.
    property string saveErrorText: ""
    // Payload of the in-flight server save; surfaced once the backend confirms.
    property var lastSavedPayload: null
    // Photo upload bookkeeping (server-backed properties). Newly picked photos
    // are staged locally (path only, no aws upload) while editing and only
    // uploaded to S3 when the agent actually saves. See submitServerSave().
    property var pendingMediaIds: []
    property int pendingMediaTotal: 0
    property string photoOpError: ""
    // Number of new (staged) photos waiting to be uploaded during a save.
    property int pendingStageTotal: 0
    // Server media ids produced while uploading the staged batch during a save.
    property var pendingStageIds: []
    // Snapshot of the server photos taken when editing starts, so cancel can
    // restore the grid to exactly the committed state (discarding staged picks).
    property var savedPhotosList: []
    // Snapshot of the committed field/room state taken when editing starts
    // (snapshotEditState). Cancel reverts to these, and Save uses them to skip
    // the backend call entirely when the listing was left untouched.
    property string savedName: ""
    property string savedDistrict: ""
    property string savedVillage: ""
    property real savedPrice: NaN
    property string savedDescription: ""
    property string savedLandlord: ""
    property string savedLandlordPhone: ""
    property var savedRooms: []

    // Last room-editing error surfaced in the edit-mode room editor.
    property string roomOpError: ""

    FileDialog {
        id: photoPickerDialog
        title: qsTr("Select photos")
        nameFilters: [qsTr("Image files (*.png *.jpg *.jpeg *.webp)")]
        fileMode: FileDialog.OpenFiles

        onAccepted: {
            var urls = selectedFiles
            root.photoOpError = ""
            for (var i = 0; i < urls.length; i++) {
                var path = urls[i].toString()
                var firstOverall = root.photosList.length === 0 && i === 0
                if (root.isDraftItem) {
                    // Drafts keep photos locally (payload paths) until resend.
                    var arr = root.photosList.slice()
                    arr.push({ path: path,
                               isPrimary: firstOverall,
                               roomId: -1 })
                    root.photosList = arr
                } else {
                    // Server-backed property, edit mode: STAGE the photo locally
                    // (path only). Nothing reaches AWS until the agent presses
                    // Save (see submitServerSave), so cancelling the edit never
                    // leaves orphaned uploads behind.
                    var staged = root.photosList.slice()
                    staged.push({ path: path,
                                  mediaId: "",
                                  isPrimary: firstOverall })
                    root.photosList = staged
                }
            }
        }
    }

    function resendProperty() {
        if (root.draftKey.length === 0)
            return
        // Re-submit through DraftViewModel: the draft is removed only on
        // success and kept on failure so it stays recoverable.
        DraftViewModel.resendDraft(root.draftKey)
    }

    function applyPayload(p) {
        if (!p) return
        if (p.title) root.propertyTitleName = p.title
        if (p.description) root.descriptionTextValue = p.description
        if (p.physicalAddress) {
            if (p.physicalAddress.district) root.propertyDistrictValue = p.physicalAddress.district
            if (p.physicalAddress.village) root.propertyVillageValue = p.physicalAddress.village
        } else {
            // Some callers pass district/village at the top level; still apply
            // them so the hero never falls back to the placeholder location.
            if (p.district) root.propertyDistrictValue = String(p.district)
            if (p.village) root.propertyVillageValue = String(p.village)
        }
        if (p.price !== undefined && Number(p.price) > 0) root.monthlyPrice = Number(p.price)
        if (p.landlord) root.landlordName = p.landlord
        if (p.landlordPhone) root.landlordPhone = p.landlordPhone
        if (p.ownerName) root.ownerName = p.ownerName
        if (p.ownerPhone) root.ownerPhone = p.ownerPhone
        if (p.amenities) root.amenitiesList = p.amenities
        if (p.propertyId) root.propertyId = String(p.propertyId)
        root.roomsList = p.rooms ? p.rooms : []
        root.photosList = p.photos ? p.photos : []
        if (p.verificationStatus !== undefined)
            root.verificationStatus = String(p.verificationStatus)
        if (p.rejectionReason !== undefined)
            root.rejectionReason = String(p.rejectionReason)
        if (p.draftKey !== undefined)
            root.draftKey = String(p.draftKey)
        root.loadRooms()
        root.loadAmenities()
    }

    // Rooms live in the separate /rooms/ collection, keyed by propertyId. The
    // property document does not embed them, so pull the matching rooms from
    // RoomViewModel (via C++) and shape them for display. Drafts are local
    // (not in /rooms/), so keep the rooms their payload already supplied.
    function loadRooms() {
        if (root.isDraftItem)
            return
        root.roomsList = root.propertyId ? RoomViewModel.roomsForProperty(root.propertyId) : []
    }

    // Amenities come from the property document (via C++). Fetching them here
    // keeps them authoritative and avoids any QML ListModel/Array.isArray
    // round-trip fragility. Drafts are local (not in the server property model),
    // so keep whatever amenities the draft payload already supplied.
    function loadAmenities() {
        if (root.isDraftItem)
            return
        root.amenitiesList = root.propertyId ? PropertyViewModel.propertyListModel.amenitiesFor(root.propertyId) : []
    }

    Connections {
        target: RoomViewModel.roomListModel
        function onCountChanged() { root.loadRooms() }
        function onModelReset() { root.loadRooms() }
        function onRowsInserted(parent, first, last) { root.loadRooms() }
        function onRowsRemoved(parent, first, last) { root.loadRooms() }
        function onDataChanged(topLeft, bottomRight, roles) { root.loadRooms() }
    }

    // Surface backend failures from room create/update/delete so a silent
    // failure never looks like a success (the list simply unchanged).
    Connections {
        target: RoomViewModel
        function onRoomError(error) { root.roomOpError = String(error) }
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onCountChanged() { root.loadAmenities() }
        function onModelReset() { root.loadAmenities() }
        function onDataChanged() { root.loadAmenities() }
    }

    // Submit Edits -> backend: the page stays in edit mode until the backend
    // confirms the PUT, so an error keeps the entered values available.
    Connections {
        target: PropertyViewModel
        function onPropertyUpdatedSignal(id) {
            if (root.savingInProgress && String(id) === String(root.propertyId)) {
                root.savingInProgress = false
                root.applyEditedValues()
                root.editMode = false
                if (root.lastSavedPayload)
                    root.propertyUpdated(root.lastSavedPayload)
            }
        }
        function onPropertyError(error) {
            if (root.savingInProgress) {
                root.savingInProgress = false
                root.saveErrorText = qsTr("Your changes could not be saved. %1").arg(String(error))
            }
        }
    }

    // Photo management (delete / set cover / add) round-trips through the
    // shared media model; refresh the grid once the viewmodel confirms.
    Connections {
        target: MediaViewModel
        function onMediaCreatedSignal(mediaId) { root.onMediaUploaded(mediaId) }
        function onMediaDeletedSignal(mediaId) { root.syncPhotosFromServer() }
        function onMediaUpdatedSignal(mediaId) { root.syncPhotosFromServer() }
        function onMediaError(error) { root.onMediaFailure(error) }
    }

    // Snapshot of the committed values when an edit session begins. Cancel uses
    // it to revert everything, and Save uses it to skip the backend call
    // entirely when the user left the listing untouched.
    function snapshotEditState() {
        root.savedName = root.propertyTitleName
        root.savedDistrict = root.propertyDistrictValue
        root.savedVillage = root.propertyVillageValue
        root.savedPrice = root.hasMonthlyPrice ? Number(root.monthlyPrice) : NaN
        root.savedDescription = root.descriptionTextValue
        root.savedLandlord = root.landlordName
        root.savedLandlordPhone = root.landlordPhone
        root.savedPhotosList = root.photosList.slice()
        root.savedRooms = []
        for (var r = 0; r < root.roomsList.length; r++)
            root.savedRooms.push(root.roomComparable(root.roomsList[r]))
    }

    // Canonical, comparison-safe projection of a room row (id/type/price/
    // available). Type casing is normalised because the backend stores it
    // uppercased while the editor options are title-cased.
    function roomComparable(r) {
        return {
            id: String(r.roomId !== undefined ? r.roomId : ""),
            type: String(r.roomType !== undefined ? r.roomType : (r.type !== undefined ? r.type : "")).toUpperCase(),
            price: Number(r.price || 0),
            available: Boolean(r.available)
        }
    }

    function hasUncommittedChanges() {
        if (root.editNameValue.trim() !== root.savedName)
            return true
        if (root.editDistrictValue.trim() !== root.savedDistrict)
            return true
        if (root.editVillageValue.trim() !== root.savedVillage)
            return true
        var parsedPrice = Number(root.editMonthlyPriceValue.replace(/[^0-9.]/g, ""))
        var expectedPrice = isNaN(Number(root.savedPrice)) ? 0 : Number(root.savedPrice)
        if (isNaN(parsedPrice) ? expectedPrice !== 0 : parsedPrice !== expectedPrice)
            return true
        if (root.editDescriptionValue.trim() !== root.savedDescription)
            return true
        if (root.editLandlordNameValue.trim() !== root.savedLandlord)
            return true
        if (root.editLandlordPhoneValue.trim() !== root.savedLandlordPhone)
            return true
        if ((root.savedRooms || []).length !== root.roomsList.length)
            return true
        for (var r = 0; r < root.roomsList.length; r++) {
            var a = root.roomComparable(root.roomsList[r])
            var b = root.savedRooms[r]
            if (a.id !== b.id || a.type !== b.type || a.price !== b.price || a.available !== b.available)
                return true
        }
        var curPhotos = root.photosList || []
        var basePhotos = root.savedPhotosList || []
        if (curPhotos.length !== basePhotos.length)
            return true
        for (var i = 0; i < curPhotos.length; i++) {
            var c = curPhotos[i] || {}
            var d = basePhotos[i] || {}
            if (String(c.mediaId || "").trim() !== String(d.mediaId || "").trim())
                return true
            if (String(c.path || "").trim() !== String(d.path || "").trim())
                return true
        }
        return false
    }

    function startEditing() {
        root.editNameValue = root.propertyTitleName
        root.editDistrictValue = root.propertyDistrictValue
        root.editVillageValue = root.propertyVillageValue
        root.editMonthlyPriceValue = root.hasMonthlyPrice ? String(Math.round(root.monthlyPrice)) : ""
        root.editDescriptionValue = root.descriptionTextValue
        root.editLandlordNameValue = root.landlordName
        root.editLandlordPhoneValue = root.landlordPhone
        root.saveErrorText = ""
        root.photoOpError = ""
        // Snapshot the committed state (fields, rooms and photos) so Cancel can
        // revert everything and Save skips the backend call when untouched.
        root.snapshotEditState()
        root.editMode = true
    }

    function cancelEditing() {
        // Never discard edits / staged photos while a save is in-flight: the
        // uploads and the property PUT are already committed or underway, so
        // cancelling now would tear the grid out from under a saving save.
        if (root.savingInProgress)
            return
        // Discard any photos staged during this edit (they hit AWS only on
        // save, so nothing to roll back there) and restore the committed set.
        root.photosList = root.savedPhotosList.slice()
        root.photoOpError = ""
        root.editMode = false
    }

    // Push the current edit fields into the read-only display values. Used
    // after a successful server save (and for local drafts).
    function applyEditedValues() {
        root.propertyTitleName = root.editNameValue.trim()
        if (root.editDistrictValue.trim().length > 0)
            root.propertyDistrictValue = root.editDistrictValue.trim()
        if (root.editVillageValue.trim().length > 0)
            root.propertyVillageValue = root.editVillageValue.trim()
        var parsedPrice = Number(root.editMonthlyPriceValue.replace(/[^0-9.]/g, ""))
        if (!isNaN(parsedPrice) && parsedPrice > 0)
            root.monthlyPrice = parsedPrice
        if (root.editDescriptionValue.trim().length > 0)
            root.descriptionTextValue = root.editDescriptionValue.trim()
        if (root.editLandlordNameValue.trim().length > 0)
            root.landlordName = root.editLandlordNameValue.trim()
        if (root.editLandlordPhoneValue.trim().length > 0)
            root.landlordPhone = root.editLandlordPhoneValue.trim()
    }

    // The details the backend review expects before a listing is considered
    // complete. The agent is shown this list while editing and is blocked from
    // submitting a server-backed save until every item is satisfied.
    function missingRequiredFields() {
        var missing = []
        if (root.editNameValue.trim().length === 0)
            missing.push(qsTr("A property name / title"))
        if (root.editDescriptionValue.trim().length < 10)
            missing.push(qsTr("A description (at least 10 characters)"))
        var priceOk = Number(root.editMonthlyPriceValue.replace(/[^0-9.]/g, "")) > 0
        if (!priceOk) {
            var anyRoomPrice = false
            for (var r = 0; r < root.roomsList.length; r++)
                if (Number(root.roomsList[r].price) > 0) { anyRoomPrice = true; break }
            if (!anyRoomPrice)
                missing.push(qsTr("A monthly rent (whole property or per room)"))
        }
        if (root.editLandlordNameValue.trim().length === 0)
            missing.push(qsTr("The landlord's name"))
        if (root.editLandlordPhoneValue.trim().length === 0)
            missing.push(qsTr("The landlord's phone number"))
        if (root.photosList.length === 0)
            missing.push(qsTr("At least one photo"))
        return missing
    }

    function deletePhoto(mediaId) {
        if (root.isDraftItem)
            return
        root.photoOpError = ""
        if (mediaId) {
            // Invalidate the removed media's cached image (it's deleted on the
            // server) so a stale copy is not served later from the local cache.
            // Guarded: cache invalidation must never block the deleteMedia call
            // below if the helper is missing/unavailable on this build.
            try {
                if (UtilsModule && typeof UtilsModule.invalidateImages === "function") {
                    var cacheTargets = []
                    for (var p = 0; p < root.photosList.length; p++)
                        if (String(root.photosList[p].mediaId) === String(mediaId)
                            || String(root.photosList[p].id) === String(mediaId))
                            cacheTargets.push(root.photosList[p])
                    UtilsModule.invalidateImages(cacheTargets)
                }
            } catch (err) {
                console.log("PropertyDetailsPage: cache invalidation skipped:", err)
            }
            MediaViewModel.deleteMedia(mediaId)
        }
    }

    // Delete for a local draft photo (no backend record behind it).
    function removeDraftPhoto(index) {
        if (index < 0 || index >= root.photosList.length)
            return
        var arr = []
        for (var i = 0; i < root.photosList.length; i++)
            if (i !== index)
                arr.push(root.photosList[i])
        // Keep a single cover photo when the deleted one was it.
        var hasPrimary = false
        for (var k = 0; k < arr.length; k++)
            if (arr[k].isPrimary) { hasPrimary = true; break }
        if (!hasPrimary && arr.length > 0)
            arr[0].isPrimary = true
        root.photosList = arr
        root.photoOpError = ""
    }

    function setPhotoCover(mediaId) {
        if (root.isDraftItem)
            return
        root.photoOpError = ""
        if (mediaId)
            MediaViewModel.updateMediaPrimary(mediaId, true)
    }

    // Remove a photo that was staged (picked) during this edit but not yet
    // uploaded. It exists only in the local grid, so drop it there without any
    // network call — it never reached AWS.
    function removeStagedPhoto(index) {
        if (index < 0 || index >= root.photosList.length)
            return
        var arr = root.photosList.slice()
        // Remove only staged entries (empty mediaId) at that index; if it's
        // actually a committed server row, fall back to the server delete path.
        if (String(arr[index].mediaId || "").length > 0) {
            root.deletePhoto(arr[index].mediaId)
            return
        }
        arr.splice(index, 1)
        // Ensure a cover still exists when the removed photo was the cover.
        var hasPrimary = false
        for (var k = 0; k < arr.length; k++)
            if (arr[k].isPrimary) { hasPrimary = true; break }
        if (!hasPrimary && arr.length > 0)
            arr[0].isPrimary = true
        root.photosList = arr
        root.photoOpError = ""
    }

    // Draft photos are local only: promote the tapped photo in place.
    function setDraftPhotoCover(index) {
        if (index < 0 || index >= root.photosList.length)
            return
        var arr = root.photosList.slice()
        for (var i = 0; i < arr.length; i++)
            arr[i].isPrimary = (i === index)
        root.photosList = arr
        root.photoOpError = ""
    }

    // Promote a staged (not yet uploaded) photo to the cover in the local grid.
    // The definitive cover is set server-side after upload via updateMedia.
    function setStagedPhotoCover(index) {
        if (index < 0 || index >= root.photosList.length)
            return
        if (String(root.photosList[index].mediaId || "").length > 0)
            return
        var arr = root.photosList.slice()
        for (var i = 0; i < arr.length; i++)
            arr[i].isPrimary = (i === index)
        root.photosList = arr
        root.photoOpError = ""
    }

    // Draft rooms live only in the local roomsList (no /rooms/ backend row).
    // These helpers edit that list directly; the draft save persists them.
    function addDraftRoom(type, price, available) {
        var arr = root.roomsList.slice()
        arr.push({ roomId: -1, roomType: type, price: price, available: available })
        root.roomsList = arr
        root.roomOpError = ""
    }

    function updateDraftRoom(index, type, price, available) {
        if (index < 0 || index >= root.roomsList.length)
            return
        var arr = root.roomsList.slice()
        var it = {}
        var k
        for (k in arr[index]) it[k] = arr[index][k]
        it.roomType = type
        it.price = price
        it.available = available
        arr[index] = it
        root.roomsList = arr
        root.roomOpError = ""
    }

    function removeDraftRoom(index) {
        if (index < 0 || index >= root.roomsList.length)
            return
        var arr = []
        for (var i = 0; i < root.roomsList.length; i++)
            if (i !== index)
                arr.push(root.roomsList[i])
        root.roomsList = arr
        root.roomOpError = ""
    }

    // Refresh the photos grid straight from the shared media model after a
    // delete / cover change / upload lands there.
    function syncPhotosFromServer() {
        if (root.isDraftItem || root.propertyId.length === 0)
            return
        var serverPhotos = MediaViewModel.mediaForProperty(root.propertyId)
        if (serverPhotos && serverPhotos.length > 0)
            root.photosList = serverPhotos
        else
            MediaViewModel.getMediaByProperty(root.propertyId)
    }

    // A photo finished uploading during a server save. Collect each server
    // media id; when the whole staged batch is done, attach the ids to the
    // property and continue the save (property text PUT).
    function onMediaUploaded(mediaId) {
        if (!root.savingInProgress)
            return
        if (mediaId && mediaId.length > 0)
            root.pendingStageIds.push(String(mediaId))
        root.pendingStageTotal--
        if (root.pendingStageTotal <= 0) {
            var ids = root.pendingStageIds.slice()
            root.pendingStageTotal = 0
            root.pendingStageIds = []
            root.pendingMediaIds = ids
            if (ids.length > 0)
                PropertyViewModel.attachMedia(root.propertyId, ids)
            root.syncPhotosFromServer()
            root.confirmServerUpdate(ids)
        }
    }

    function onMediaFailure(error) {
        root.photoOpError = qsTr("A photo could not be processed: %1").arg(error)
        if (root.savingInProgress) {
            // A staged photo failed to upload: abort the save so the agent can
            // retry/fix rather than committing a broken listing. Keep the
            // staged photos in the grid so nothing is silently lost.
            root.savingInProgress = false
            root.pendingStageTotal = 0
            root.pendingStageIds = []
            root.pendingMediaIds = []
        } else {
            root.pendingMediaIds = []
            root.pendingMediaTotal = 0
        }
    }

    function saveChanges() {
        if (root.savingInProgress)
            return
        root.saveErrorText = ""
        if (root.editNameValue.trim().length === 0) {
            root.saveErrorText = qsTr("A property name is required.")
            return
        }

        var parsedPrice = Number(root.editMonthlyPriceValue.replace(/[^0-9.]/g, ""))
        if (isNaN(parsedPrice))
            parsedPrice = 0

        var updated = {
            title: root.editNameValue.trim(),
            description: root.editDescriptionValue.trim(),
            physicalAddress: {
                district: root.editDistrictValue.trim(),
                village: root.editVillageValue.trim()
            },
            verificationStatus: root.verificationStatus,
            isActive: true,
            price: parsedPrice,
            landlord: root.editLandlordNameValue.trim(),
            landlordPhone: root.editLandlordPhoneValue.trim()
        }

        // A draft is local: persist the edits back into the draft store so the
        // changes survive until the agent resends it.
        if (root.isDraftItem) {
            if (root.draftKey.length > 0) {
                var stored = DraftViewModel.getDraft(root.draftKey) || {}
                var merged = {}
                var k
                for (k in stored) merged[k] = stored[k]
                merged.title = updated.title
                merged.description = updated.description
                merged.physicalAddress = updated.physicalAddress
                merged.verificationStatus = updated.verificationStatus
                merged.isActive = updated.isActive
                if (updated.price > 0)
                    merged.price = updated.price
                merged.landlord = updated.landlord
                merged.landlordPhone = updated.landlordPhone
                // Persist the edited room list (roomType / price / available)
                // so updated room prices survive the draft until it is resent.
                merged.rooms = root.roomsList
                DraftViewModel.updateDraft(root.draftKey, merged)
            }
            root.applyEditedValues()
            root.editMode = false
            root.propertyUpdated(updated)
            return
        }

        // Server-backed property: if nothing actually changed, exit edit mode
        // without touching the backend (no PUT, no photo uploads).
        if (!root.hasUncommittedChanges()) {
            root.cancelEditing()
            return
        }

        // The agent is required to provide the missing details before the
        // edited listing may be submitted.
        var missing = root.missingRequiredFields()
        if (missing.length > 0) {
            root.saveErrorText = qsTr("Required to provide: ") + missing.join("; ")
            return
        }

        // Submit the edits to the backend. This is the transactional commit:
        // any photos staged during the edit are uploaded to AWS first, then
        // attached, then the text fields are PUT. Stay in edit mode with a
        // "Saving..." button until PropertyViewModel confirms.
        root.submitServerSave(updated)
        return
    }

    // Transactional commit for a server-backed property edit: upload every
    // staged (not-yet-uploaded) photo to AWS, then PUT the text changes. If
    // the save is cancelled before this runs, the staged photos never reached
    // AWS at all and are simply discarded by cancelEditing().
    function submitServerSave(updated) {
        if (root.savingInProgress)
            return
        root.lastSavedPayload = updated
        root.savingInProgress = true

        // Collect the staged photos: server photos carry a mediaId; new picks
        // added during this edit have an empty mediaId and must be uploaded.
        var staged = []
        for (var p = 0; p < root.photosList.length; p++) {
            var it = root.photosList[p]
            if (!it) continue
            if (!String(it.mediaId || "").length)
                staged.push(root.photosList[p])
        }

        if (staged.length === 0) {
            // Nothing new to upload; go straight to the property text PUT.
            root.confirmServerUpdate([])
            return
        }

        var firstIsPrimary = false
        for (var s = 0; s < root.photosList.length; s++)
            if (root.photosList[s].isPrimary) { firstIsPrimary = true; break }

        root.pendingStageTotal = staged.length
        root.pendingStageIds = []

        // Pre-upload: each staged photo's isPrimary flag is unknown until it
        // becomes a real server record, so send the provisional cover state
        // only for the first staged item (matches the pick-time logic) and the
        // backend updateMedia path refines the true cover afterwards.
        for (var i = 0; i < staged.length; i++) {
            MediaViewModel.createMedia(root.propertyId,
                                       staged[i].path,
                                       "image",
                                       i === 0 && firstIsPrimary,
                                       "-1")
        }
    }

    // Called after every staged photo has been uploaded. Any staged entries in
    // the grid are replaced by their committed server rows (syncPhotosFromServer
    // already ran), then the text update is submitted.
    function confirmServerUpdate(mediaIds) {
        var idx = PropertyViewModel.indexOfProperty(root.propertyId)
        var amens = []
        if (root.amenitiesList) {
            for (var a = 0; a < root.amenitiesList.length; a++)
                amens.push(String(root.amenitiesList[a]))
        }
        var payload = root.lastSavedPayload || {}
        PropertyViewModel.updateProperty(idx < 0 ? -1 : idx,
                                         root.propertyId,
                                         payload.title,
                                         payload.description,
                                         payload.price,
                                         payload.physicalAddress ? payload.physicalAddress.district : "",
                                         payload.physicalAddress ? payload.physicalAddress.village : "",
                                         amens,
                                         payload.landlord,
                                         payload.landlordPhone,
                                         payload.verificationStatus,
                                         payload.isActive)
    }

    background: Rectangle { color: root.pageColor }

    header: ToolBar {
        background: Rectangle { color: "#FFFFFF" }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 16

            ToolButton {
                id: backButton

                contentItem: Item {
                    implicitWidth: 24
                    implicitHeight: 24

                    Rectangle {
                        width: 12
                        height: 2
                        radius: 1
                        color: root.textColor
                        rotation: 45
                        transformOrigin: Item.Right
                        x: 0
                        y: 4.5
                    }

                    Rectangle {
                        width: 12
                        height: 2
                        radius: 1
                        color: root.textColor
                        rotation: -45
                        transformOrigin: Item.Right
                        x: 0
                        y: 17.5
                    }
                }

                onClicked: {
                    if (root.editMode) {
                        root.cancelEditing()
                        return
                    }
                    UtilsModule.NavigationUtils.pop()
                }
            }

            Label {
                Layout.fillWidth: true
                text: root.agentMode && root.editMode ? qsTr("Edit property") : qsTr("Property details")
                font.pixelSize: 17
                font.bold: true
                color: root.textColor
                elide: Text.ElideRight
            }

            Button {
                id: editToggleButton
                visible: root.agentMode
                Layout.preferredWidth: 74
                Layout.preferredHeight: 32
                text: root.editMode ? qsTr("Done") : qsTr(isDraftItem ? "Edit draft" : "Edit")

                contentItem: Label {
                    text: editToggleButton.text
                    color: root.primaryColor
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 16
                    color: root.softBlueColor
                    border.color: root.primaryColor
                    border.width: 1
                }

                onClicked: root.editMode ? root.saveChanges() : root.startEditing()
            }

            StatusChip {
                visible: !(root.agentMode && root.editMode)
                textValue: root.prettyStatus
                variant: {
                    var s = String(root.verificationStatus).toUpperCase()
                    if (s === "VERIFIED") return "success"
                    if (s === "PENDING") return "warning"
                    if (s === "REJECTED") return "danger"
                    return "neutral"
                }
            }
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: detailsColumn.implicitHeight + 32
        clip: true

        ScrollBar.vertical: AppScrollBar { }

        ColumnLayout {
            id: detailsColumn
            x: Math.max(16, (flick.width - 520) / 2)
            y: 20
            width: Math.min(flick.width - 32, 520)
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: heroColumn.implicitHeight + 40
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.primaryColor }
                    GradientStop { position: 1.0; color: root.primaryDarkColor }
                }

                ColumnLayout {
                    id: heroColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 8

                    Label {
                        visible: !root.editMode
                        Layout.fillWidth: true
                        text: root.propertyTitleName
                        color: "#FFFFFF"
                        font.pixelSize: 21
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    AppTextInput {
                        visible: root.editMode
                        Layout.fillWidth: true
                        fieldHeight: 44
                        Layout.preferredHeight: 44
                        label: ""
                        placeholder: qsTr("Property name")
                        text: root.editNameValue
                        onTextEdited: root.editNameValue = text
                        backgroundColor: Qt.rgba(1, 1, 1, 0.14)
                        textColor: "#FFFFFF"
                        placeholderColor: Qt.rgba(1, 1, 1, 0.55)
                        borderColor: Qt.rgba(1, 1, 1, 0.4)
                        focusColor: "#FFFFFF"
                        errorColor: root.dangerColor
                    }

                    RowLayout {
                        visible: !root.editMode
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 5
                            Layout.preferredHeight: 5
                            radius: 2.5
                            color: Qt.rgba(1, 1, 1, 0.85)
                        }

                        Label {
                            text: root.propertyDistrictValue + " · " + root.propertyVillageValue
                            color: Qt.rgba(1, 1, 1, 0.85)
                            font.pixelSize: 13
                        }

                        Item { Layout.fillWidth: true }
                    }

                    AppTextInput {
                        visible: root.editMode
                        Layout.fillWidth: true
                        fieldHeight: 44
                        Layout.preferredHeight: 44
                        label: ""
                        placeholder: qsTr("District")
                        text: root.editDistrictValue
                        onTextEdited: root.editDistrictValue = text
                        backgroundColor: Qt.rgba(1, 1, 1, 0.14)
                        textColor: "#FFFFFF"
                        placeholderColor: Qt.rgba(1, 1, 1, 0.55)
                        borderColor: Qt.rgba(1, 1, 1, 0.4)
                        focusColor: "#FFFFFF"
                        errorColor: root.dangerColor
                    }

                    AppTextInput {
                        visible: root.editMode
                        Layout.fillWidth: true
                        fieldHeight: 44
                        Layout.preferredHeight: 44
                        label: ""
                        placeholder: qsTr("e.g. Area 47")
                        text: root.editVillageValue
                        onTextEdited: root.editVillageValue = text
                        backgroundColor: Qt.rgba(1, 1, 1, 0.14)
                        textColor: "#FFFFFF"
                        placeholderColor: Qt.rgba(1, 1, 1, 0.55)
                        borderColor: Qt.rgba(1, 1, 1, 0.4)
                        focusColor: "#FFFFFF"
                        errorColor: root.dangerColor
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        implicitHeight: priceRow.implicitHeight + 24
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            id: priceRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Label {
                                visible: !root.editMode && !root.hasMonthlyPrice
                                text: qsTr("Rent on request")
                                color: Qt.rgba(1, 1, 1, 0.85)
                                font.pixelSize: 22
                                font.bold: true
                            }

                            Label {
                                visible: !root.editMode && root.hasMonthlyPrice
                                text: "MK " + Number(root.monthlyPrice).toLocaleString()
                                color: "#FFFFFF"
                                font.pixelSize: 22
                                font.bold: true
                            }

                            Label {
                                visible: !root.editMode && root.hasMonthlyPrice
                                text: qsTr("/ month")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 13
                            }

                            Label {
                                visible: root.editMode
                                text: "MK"
                                color: "#FFFFFF"
                                font.pixelSize: 17
                                font.bold: true
                            }

                            AppTextInput {
                                visible: root.editMode
                                Layout.preferredWidth: 150
                                fieldHeight: 44
                                label: ""
                                placeholder: qsTr("Rent / month")
                                text: root.editMonthlyPriceValue
                                onTextEdited: root.editMonthlyPriceValue = text
                                backgroundColor: Qt.rgba(1, 1, 1, 0.14)
                                textColor: "#FFFFFF"
                                placeholderColor: Qt.rgba(1, 1, 1, 0.55)
                                borderColor: Qt.rgba(1, 1, 1, 0.4)
                                focusColor: "#FFFFFF"
                                errorColor: root.dangerColor
                                Layout.preferredHeight: 40
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                visible: !root.editMode
                                text: qsTr("Rent per room")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }

            // Edit-mode helper: lists every detail the agent is required to
            // provide before the edited listing may be submitted, plus the most
            // recent save/upload error.
            ColumnLayout {
                visible: root.editMode
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    visible: root.missingRequiredFields().length > 0
                    Layout.fillWidth: true
                    implicitHeight: missingColumn.implicitHeight + 20
                    radius: 12
                    color: "#FFFBEB"
                    border.color: "#FDE68A"
                    border.width: 1

                    ColumnLayout {
                        id: missingColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 13
                        spacing: 6

                        Label {
                            text: qsTr("Required to provide")
                            color: root.warningColor
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Repeater {
                            model: root.missingRequiredFields()

                            delegate: RowLayout {
                                required property string modelData
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    Layout.preferredWidth: 5
                                    Layout.preferredHeight: 5
                                    radius: 2.5
                                    color: root.warningColor
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: modelData
                                    color: root.textColor
                                    font.pixelSize: 11
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                }

                Label {
                    visible: root.saveErrorText.length > 0
                    Layout.fillWidth: true
                    text: root.saveErrorText
                    color: root.dangerColor
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Photos")
                actionLabel: root.photosList.length > 0 ? qsTr("%1 attached").arg(root.photosList.length) : ""
            }

            Rectangle {
                visible: root.photosList.length === 0
                Layout.fillWidth: true
                implicitHeight: photosPlaceholder.implicitHeight + 24
                radius: 14
                color: root.softBlueColor
                border.color: "#BFDBFE"
                border.width: 1

                ColumnLayout {
                    id: photosPlaceholder
                    anchors.centerIn: parent
                    spacing: 10

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 34

                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: "transparent"
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: -5
                            width: 16
                            height: 9
                            radius: 3
                            color: root.softBlueColor
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 15
                            height: 15
                            radius: 7.5
                            color: "transparent"
                            border.color: root.primaryColor
                            border.width: 2.2
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 3
                            color: root.primaryColor
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.editMode ? qsTr("No photos attached yet") : qsTr("No photos uploaded yet")
                        color: root.primaryDarkColor
                        font.pixelSize: 12
                    }

                    Button {
                        id: addFirstPhotoButton
                        visible: root.editMode
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: 140
                        text: qsTr("Add photos")

                        contentItem: Label {
                            text: addFirstPhotoButton.text
                            color: root.primaryColor
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 18
                            color: addFirstPhotoButton.down ? "#DBEAFE" : "#EFF6FF"
                            border.color: "#BFDBFE"
                            border.width: 1
                        }

                        onClicked: photoPickerDialog.open()
                    }
                }
            }

            Rectangle {
                visible: root.photosList.length > 0
                Layout.fillWidth: true
                implicitHeight: photosFlow.implicitHeight + 24
                radius: 14
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Flow {
                    id: photosFlow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Repeater {
                        model: root.photosList

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: 88
                            height: 108

                            Rectangle {
                                width: 88
                                height: 88
                                radius: 10
                                color: root.softBlueColor
                                clip: true
                                border.color: modelData.isPrimary ? root.primaryColor : root.borderColor
                                border.width: modelData.isPrimary ? 2 : 1

                                Image {
                                    id: photoCardImage
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: modelData.path
                                    // Downscale the decoded image: without
                                    // sourceSize, full-resolution phone photos
                                    // exceed the Android GPU texture limit and
                                    // render as blank/white in small thumbnails.
                                    sourceSize.width: 280
                                    sourceSize.height: 280
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                }

                                // Show a subtle spinner while the remote photo is
                                // loading so the card never looks blank, and a
                                // fallback glyph if the load fails.
                                AppSpinner {
                                    anchors.centerIn: parent
                                    size: 16
                                    lineWidth: 2
                                    color: root.mutedColor
                                    running: photoCardImage.status === Image.Loading
                                    visible: running
                                }

                                Label {
                                    visible: photoCardImage.status === Image.Error
                                    anchors.centerIn: parent
                                    text: qsTr("No preview")
                                    color: root.mutedColor
                                    font.pixelSize: 8
                                }

                                Rectangle {
                                    visible: !!modelData.isPrimary
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 6
                                    width: coverLabel.implicitWidth + 12
                                    height: 18
                                    radius: 9
                                    color: root.primaryColor

                                    Label {
                                        id: coverLabel
                                        anchors.centerIn: parent
                                        text: qsTr("Cover")
                                        color: "#FFFFFF"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: photoViewer.openWithImages(root.photosList, index)
                                }
                            }

                            Label {
                                y: 92
                                width: parent.width
                                text: modelData.isPrimary ? qsTr("Cover photo") : qsTr("Photo %1").arg(index + 1)
                                color: root.mutedColor
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }

                            // Edit-mode controls: delete a photo, or promote it
                            // to the cover. Server photos carry a mediaId and are
                            // managed via the backend; drafts edit the local list.
                            Rectangle {
                                visible: root.editMode
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: -6
                                anchors.rightMargin: -6
                                width: 22
                                height: 22
                                radius: 11
                                color: deletePhotoArea.containsMouse ? "#B91C1C" : "#EF4444"

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 10
                                    height: 2
                                    radius: 1
                                    color: "#FFFFFF"
                                }

                                MouseArea {
                                    id: deletePhotoArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.isDraftItem)
                                            root.removeDraftPhoto(index)
                                        else if (modelData.mediaId)
                                            root.deletePhoto(modelData.mediaId)
                                        else
                                            // Staged (not yet uploaded) photo:
                                            // remove it from the local grid only.
                                            root.removeStagedPhoto(index)
                                    }
                                }
                            }

                            Rectangle {
                                visible: root.editMode && !modelData.isPrimary
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.topMargin: 62
                                anchors.leftMargin: 6
                                height: 20
                                width: makeCoverLabel.implicitWidth + 16
                                radius: 10
                                color: root.surfaceColor
                                border.color: root.primaryColor
                                border.width: 1

                                Label {
                                    id: makeCoverLabel
                                    anchors.centerIn: parent
                                    text: qsTr("Make cover")
                                    color: root.primaryColor
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                MouseArea {
                                    id: makeCoverArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.isDraftItem)
                                            root.setDraftPhotoCover(index)
                                        else if (modelData.mediaId)
                                            root.setPhotoCover(modelData.mediaId)
                                        else
                                            // Staged (not yet uploaded) photo:
                                            // promote it as the cover locally.
                                            root.setStagedPhotoCover(index)
                                    }
                                }
                            }
                        }
                    }

                    // Add-photo tile, shown only while editing.
                    Item {
                        visible: root.editMode
                        width: 88
                        height: 108

                        Rectangle {
                            width: 88
                            height: 88
                            radius: 10
                            color: "transparent"
                            border.color: root.primaryColor
                            border.width: 1.4

                            Label {
                                anchors.centerIn: parent
                                text: "+"
                                color: root.primaryColor
                                font.pixelSize: 28
                            }

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                text: qsTr("Add photo")
                                color: root.primaryColor
                                font.pixelSize: 9
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: photoPickerDialog.open()
                            }
                        }
                    }
                }
            }

            Label {
                visible: root.editMode && root.photoOpError.length > 0
                Layout.fillWidth: true
                text: root.photoOpError
                color: root.dangerColor
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                SectionHeader {
                    Layout.fillWidth: true
                    title: qsTr("Rooms")
                    actionLabel: root.roomsList.length > 0 ? qsTr("%1 listed").arg(root.roomsList.length) : ""
                }

                Rectangle {
                    visible: root.roomsList.length === 0
                    Layout.fillWidth: true
                    implicitHeight: 76
                    radius: 12
                    color: root.surfaceColor
                    border.color: root.borderColor
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 3

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("No rooms added yet")
                            color: root.textColor
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Room types, prices and availability will appear here.")
                            color: root.mutedColor
                            font.pixelSize: 11
                        }
                    }
                }

                Repeater {
                    model: root.roomsList

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        readonly property string roomTypeLabel: {
                            var t = modelData.roomType !== undefined ? String(modelData.roomType) : ""
                            if (t.length === 0 && modelData.type !== undefined)
                                t = String(modelData.type)
                            return t.length > 0 ? t : qsTr("Room")
                        }
                        readonly property string roomServerId: modelData.roomId !== undefined ? String(modelData.roomId) : ""
                        readonly property bool roomEditable: String(root.propertyId).length > 0 && !root.isDraftItem
                        Layout.fillWidth: true
                        implicitHeight: root.editMode ? roomEditCol.implicitHeight + 22 : roomRow.implicitHeight + 24
                        radius: 12
                        color: root.surfaceColor
                        border.color: root.borderColor
                        border.width: 1

                        // Non-editing row: room summary card.
                        RowLayout {
                            id: roomRow
                            visible: !root.editMode
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 38
                                Layout.preferredHeight: 38
                                radius: 10
                                color: root.softBlueColor

                                Label {
                                    anchors.centerIn: parent
                                    text: String(index + 1)
                                    color: root.primaryColor
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    Layout.fillWidth: true
                                    text: qsTr("Room %1 · %2").arg(index + 1).arg(roomTypeLabel)
                                    color: root.textColor
                                    font.pixelSize: 13
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Label {
                                    text: "MK " + Number(modelData.price).toLocaleString() + qsTr("/mo")
                                    color: root.mutedColor
                                    font.pixelSize: 11
                                }
                            }

                            StatusChip {
                                textValue: modelData.available ? qsTr("Available") : qsTr("Unavailable")
                                variant: modelData.available ? "success" : "neutral"
                            }
                        }

                        // Edit-mode row: editable price, type, availability and
                        // remove control. Server-backed rooms update immediately
                        // through RoomViewModel; drafts edit the local list.
                        ColumnLayout {
                            id: roomEditCol
                            visible: root.editMode
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Label {
                                    Layout.fillWidth: true
                                    text: qsTr("Room %1").arg(index + 1)
                                    color: root.textColor
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Button {
                                    id: removeRoomBtn
                                    Layout.preferredHeight: 30
                                    text: qsTr("Remove")

                                    contentItem: Label {
                                        text: removeRoomBtn.text
                                        color: root.dangerColor
                                        font.pixelSize: 11
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        radius: 15
                                        color: removeRoomBtn.down ? "#FEE2E2" : "#FEF2F2"
                                        border.color: "#FECACA"
                                        border.width: 1
                                    }

                                    onClicked: {
                                        if (roomEditable)
                                            RoomViewModel.deleteRoom(roomServerId)
                                        else
                                            root.removeDraftRoom(index)
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Label {
                                        text: qsTr("Price (MK / month)")
                                        color: root.textColor
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    TextField {
                                        id: roomPriceField
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        text: String(modelData.price !== undefined ? Math.round(modelData.price) : "")
                                        font.pixelSize: 13
                                        color: root.textColor
                                        inputMethodHints: Qt.ImhDigitsOnly
                                        background: Rectangle {
                                            radius: 8
                                            color: root.pageColor
                                            border.color: roomPriceField.activeFocus ? root.primaryColor : root.borderColor
                                            border.width: 1
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Label {
                                        text: qsTr("Type")
                                        color: root.textColor
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    ComboBox {
                                        id: roomTypeCombo
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        font.pixelSize: 12
                                        model: ["Single", "Double", "Shared", "Self-contained", "Bedsitter", "Suite"]
                                        // Preselect the room's current type. The backend stores types
                                        // uppercased ("SINGLE"), while the options here are title-cased, so
                                        // match case-insensitively and fall back to the first option.
                                        currentIndex: {
                                            var t = String(roomTypeLabel).trim().toLowerCase()
                                            for (var i = 0; i < roomTypeCombo.model.length; i++) {
                                                if (String(roomTypeCombo.model[i]).toLowerCase() === t)
                                                    return i
                                            }
                                            return 0
                                        }
                                        contentItem: Label {
                                            text: roomTypeCombo.currentText
                                            leftPadding: 10
                                            verticalAlignment: Text.AlignVCenter
                                            color: root.textColor
                                            elide: Text.ElideRight
                                        }
                                        background: Rectangle {
                                            radius: 8
                                            color: root.pageColor
                                            border.color: roomTypeCombo.activeFocus ? root.primaryColor : root.borderColor
                                            border.width: 1
                                        }
                                        popup: Popup {
                                            width: roomTypeCombo.width
                                            padding: 4
                                            modal: true
                                            focus: true
                                            contentItem: ListView {
                                                clip: true
                                                implicitHeight: contentHeight
                                                model: roomTypeCombo.popup.visible ? roomTypeCombo.delegateModel : null
                                            }
                                            background: Rectangle {
                                                radius: 8
                                                color: "#FFFFFF"
                                                border.color: root.borderColor
                                                border.width: 1
                                            }
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.minimumWidth: 92
                                    spacing: 2

                                    Label {
                                        text: qsTr("Available")
                                        color: root.textColor
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Switch {
                                        id: roomAvaSwitch
                                        Layout.preferredHeight: 28
                                        Layout.alignment: Qt.AlignLeft
                                        checked: modelData.available
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Button {
                                    id: cancelRoomBtn
                                    Layout.preferredWidth: 106
                                    Layout.preferredHeight: 40
                                    text: qsTr("Cancel")

                                    contentItem: Label {
                                        text: cancelRoomBtn.text
                                        color: "#4B5563"
                                        font.pixelSize: 13
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // Outline / secondary action: discards any
                                    // un-saved edits and exits edit mode.
                                    background: Rectangle {
                                        radius: 12
                                        color: cancelRoomBtn.down ? "#F3F4F6" : "#FFFFFF"
                                        border.color: "#D1D5DB"
                                        border.width: 1
                                    }

                                    onClicked: root.cancelEditing()
                                }

                                Button {
                                    id: updateRoomBtn
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    text: qsTr(roomEditable ? "Save room" : "Update room")

                                    contentItem: Label {
                                        text: updateRoomBtn.text
                                        color: "#FFFFFF"
                                        font.pixelSize: 13
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        radius: 12
                                        color: updateRoomBtn.down ? root.primaryDarkColor : root.primaryColor
                                        border.width: 1
                                        border.color: updateRoomBtn.down ? root.primaryColor : root.primaryDarkColor
                                    }

                                    onClicked: {
                                        var price = parseFloat(roomPriceField.text)
                                        if (isNaN(price) || price <= 0) {
                                            root.roomOpError = qsTr("Room %1: enter a valid price greater than 0.").arg(index + 1)
                                            return
                                        }
                                        root.roomOpError = ""
                                        // No edits on this room? Don't fire an API call.
                                        var typeChanged = String(roomTypeCombo.currentText || "").trim().toUpperCase()
                                                          !== String(roomTypeLabel || "").trim().toUpperCase()
                                        var priceChanged = Math.abs(price - Number(modelData.price || 0)) > 0.001
                                        var availChanged = Boolean(roomAvaSwitch.checked) !== Boolean(modelData.available)
                                        if (!typeChanged && !priceChanged && !availChanged)
                                            return
                                        if (roomEditable) {
                                            RoomViewModel.updateRoom(roomServerId,
                                                                      roomTypeCombo.currentText,
                                                                      price,
                                                                      roomAvaSwitch.checked)
                                        } else {
                                            root.updateDraftRoom(index, roomTypeCombo.currentText, price, roomAvaSwitch.checked)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Edit-mode inline editor to add a brand-new room.
                Rectangle {
                    visible: root.editMode
                    Layout.fillWidth: true
                    implicitHeight: addRoomCol.implicitHeight + 18
                    radius: 12
                    color: root.softBlueColor
                    border.color: "#BFDBFE"
                    border.width: 1

                    ColumnLayout {
                        id: addRoomCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 8

                        Label {
                            text: qsTr("Add a room")
                            color: root.primaryColor
                            font.pixelSize: 12
                            font.bold: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            TextField {
                                id: newRoomPrice
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38
                                placeholderText: qsTr("Price (MK/mo)")
                                placeholderTextColor: root.mutedColor
                                font.pixelSize: 12
                                color: root.textColor
                                inputMethodHints: Qt.ImhDigitsOnly
                                background: Rectangle {
                                    radius: 8
                                    color: "#FFFFFF"
                                    border.color: newRoomPrice.activeFocus ? root.primaryColor : root.borderColor
                                    border.width: 1
                                }
                            }

                            ComboBox {
                                id: newRoomType
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38
                                font.pixelSize: 12
                                model: ["Single", "Double", "Shared", "Self-contained", "Bedsitter", "Suite"]
                                contentItem: Label {
                                    text: newRoomType.currentText
                                    leftPadding: 8
                                    verticalAlignment: Text.AlignVCenter
                                    color: root.textColor
                                    elide: Text.ElideRight
                                }
                                background: Rectangle {
                                    radius: 8
                                    color: "#FFFFFF"
                                    border.color: newRoomType.activeFocus ? root.primaryColor : root.borderColor
                                    border.width: 1
                                }
                                popup: Popup {
                                    width: newRoomType.width
                                    padding: 4
                                    modal: true
                                    focus: true
                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: newRoomType.popup.visible ? newRoomType.delegateModel : null
                                    }
                                    background: Rectangle {
                                        radius: 8
                                        color: "#FFFFFF"
                                        border.color: root.borderColor
                                        border.width: 1
                                    }
                                }
                            }

                            Button {
                                id: addRoomBtn
                                Layout.preferredHeight: 36
                                Layout.preferredWidth: 88
                                text: qsTr("+ Add")

                                contentItem: Label {
                                    text: addRoomBtn.text
                                    color: "#FFFFFF"
                                    font.pixelSize: 12
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 18
                                    color: addRoomBtn.down ? root.primaryDarkColor : root.primaryColor
                                }

                                onClicked: {
                                    var price = parseFloat(newRoomPrice.text)
                                    if (isNaN(price) || price <= 0) {
                                        root.roomOpError = qsTr("Enter a valid price greater than 0 for the new room.")
                                        return
                                    }
                                    root.roomOpError = ""
                                    if (root.isDraftItem || String(root.propertyId).length === 0) {
                                        root.addDraftRoom(newRoomType.currentText, price, true)
                                    } else {
                                        RoomViewModel.createRoomWithPrice(root.propertyId,
                                                                         newRoomType.currentText,
                                                                         price,
                                                                         true)
                                    }
                                    newRoomPrice.text = ""
                                    newRoomType.currentIndex = -1
                                }
                            }
                        }

                        Label {
                            visible: root.roomOpError.length > 0
                            Layout.fillWidth: true
                            text: root.roomOpError
                            color: root.dangerColor
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("About this property")
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: root.editMode ? Math.max(descriptionArea.implicitHeight + 24, 120) : aboutLabel.implicitHeight + 28
                radius: 12
                color: root.surfaceColor
                border.color: root.editMode ? root.primaryColor : root.borderColor
                border.width: 1

                Label {
                    id: aboutLabel
                    visible: !root.editMode
                    anchors.fill: parent
                    anchors.margins: 14
                    text: root.descriptionTextValue
                    color: root.textColor
                    font.pixelSize: 13
                    lineHeight: 1.25
                    wrapMode: Text.WordWrap
                }

                ScrollView {
                    visible: root.editMode
                    anchors.fill: parent
                    anchors.margins: 10

                    TextArea {
                        id: descriptionArea
                        text: root.editDescriptionValue
                        onTextChanged: root.editDescriptionValue = text
                        color: root.textColor
                        placeholderText: qsTr("Describe this property")
                        placeholderTextColor: root.mutedColor
                        font.pixelSize: 13
                        wrapMode: TextArea.Wrap
                        background: null
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Amenities")
            }

            Rectangle {
                visible: root.amenitiesList.length === 0
                Layout.fillWidth: true
                implicitHeight: 76
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 3

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No amenities listed")
                        color: root.textColor
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Add amenities such as Wi-Fi, parking or security.")
                        color: root.mutedColor
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                visible: root.amenitiesList.length > 0
                Layout.fillWidth: true
                implicitHeight: amenitiesFlow.implicitHeight + 24
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Flow {
                    id: amenitiesFlow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Repeater {
                        model: root.amenitiesList

                        delegate: Rectangle {
                            required property var modelData
                            readonly property string amenityLabel: {
                                var labels = {
                                    "WIFI": qsTr("Wi-Fi"), "PARKING": qsTr("Parking"),
                                    "SECURITY": qsTr("Security"), "WATER": qsTr("Water"),
                                    "ELECTRICITY": qsTr("Electricity"), "FURNISHED": qsTr("Furnished"),
                                    "AC": qsTr("A/C")
                                }
                                return labels[String(modelData)] !== undefined
                                       ? labels[String(modelData)] : String(modelData)
                            }
                            width: amenityChipLabel.implicitWidth + 24
                            height: 28
                            radius: 14
                            color: root.softBlueColor

                            Label {
                                id: amenityChipLabel
                                anchors.centerIn: parent
                                text: parent.amenityLabel
                                color: root.primaryDarkColor
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible: !root.editMode && String(root.verificationStatus).toUpperCase() === "REJECTED"
                       && root.rejectionReason.length > 0
                Layout.fillWidth: true
                implicitHeight: rejectionReasonColumn.implicitHeight + 28
                radius: 12
                color: root.softRedColor
                border.color: "#FECACA"
                border.width: 1

                ColumnLayout {
                    id: rejectionReasonColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 4

                    Label {
                        text: qsTr("Rejection reason")
                        font.pixelSize: 11
                        font.bold: true
                        color: "#B91C1C"
                    }

                    Label {
                        id: rejectedReasonLabel
                        Layout.fillWidth: true
                        text: root.rejectionReason
                        color: "#7F1D1D"
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Rooms")
                    valueText: String(root.roomsList.length)
                    accentColor: root.primaryColor
                }

                    StatCard {
                        Layout.fillWidth: true
                        label: qsTr("Monthly rent")
                        valueText: root.hasMonthlyPrice
                                   ? "MK " + Number(root.monthlyPrice).toLocaleString()
                                   : qsTr("On request")
                        accentColor: root.successColor
                    }

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Verification")
                    valueText: root.prettyStatus
                    accentColor: root.warningColor
                }

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Amenities")
                    valueText: String(root.amenitiesList.length)
                    accentColor: root.primaryDarkColor
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                SectionHeader {
                    Layout.fillWidth: true
                    title: qsTr(root.editMode ? "Landlord details" : "Contacts")
                }

                ContactCard {
                    visible: !root.editMode
                    title: qsTr("Listed by")
                    name: root.ownerName
                    phone: root.ownerPhone
                    accentColor: root.primaryColor
                    onCallRequested: function (number) {
                        if (number && number.length > 0)
                            Qt.openUrlExternally("tel:" + number)
                    }
                }

                ContactCard {
                    visible: !root.editMode
                    title: qsTr("Landlord")
                    name: root.landlordName
                    phone: root.landlordPhone
                    accentColor: root.secondaryColor
                    onCallRequested: function (number) {
                        if (number && number.length > 0)
                            Qt.openUrlExternally("tel:" + number)
                    }
                }

                Rectangle {
                    visible: root.editMode
                    Layout.fillWidth: true
                    implicitHeight: landlordEditColumn.implicitHeight + 26
                    radius: 12
                    color: root.surfaceColor
                    border.color: root.borderColor
                    border.width: 1

                    ColumnLayout {
                        id: landlordEditColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 13
                        spacing: 10

                        AppTextInput {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 66
                            label: qsTr("Landlord name")
                            placeholder: qsTr("e.g. John Banda")
                            fieldHeight: 44
                            text: root.editLandlordNameValue
                            onTextEdited: root.editLandlordNameValue = text
                            backgroundColor: root.pageColor
                            textColor: root.textColor
                            labelColor: root.textColor
                            placeholderColor: root.mutedColor
                            borderColor: root.borderColor
                            focusColor: root.primaryColor
                            errorColor: root.dangerColor
                        }

                        AppTextInput {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 66
                            label: qsTr("Landlord phone")
                            placeholder: qsTr("+265 999 123 456")
                            fieldHeight: 44
                            text: root.editLandlordPhoneValue
                            onTextEdited: root.editLandlordPhoneValue = text
                            backgroundColor: root.pageColor
                            textColor: root.textColor
                            labelColor: root.textColor
                            placeholderColor: root.mutedColor
                            borderColor: root.borderColor
                            focusColor: root.primaryColor
                            errorColor: root.dangerColor
                        }
                    }
                }
            }

            Rectangle {
                visible: root.agentMode && !root.editMode
                Layout.fillWidth: true
                implicitHeight: deleteRow.implicitHeight + 28
                radius: 12
                color: root.softRedColor
                border.color: "#FECACA"
                border.width: 1

                RowLayout {
                    id: deleteRow
                    visible: root.agentMode && !root.editMode
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: root.isDraftItem ? qsTr("Delete draft") : qsTr("Delete property")
                            color: root.dangerColor
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.isDraftItem
                                  ? qsTr("Permanently delete this draft. This cannot be undone.")
                                  : qsTr("Permanently remove this listing and all its rooms.")
                            color: root.mutedColor
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                        }
                    }

                    Button {
                        id: deleteButton
                        Layout.preferredHeight: 38
                        Layout.preferredWidth: 92
                        text: qsTr("Delete")

                        contentItem: Label {
                            text: deleteButton.text
                            color: "#FFFFFF"
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 19
                            color: deleteButton.down ? "#B91C1C" : root.dangerColor
                        }

                        onClicked: deleteDialog.open()
                    }
                }
            }

            Item { Layout.preferredHeight: 8; Layout.fillWidth: true }
        }
    }

    Dialog {
        id: deleteDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 340)
        padding: 20

        background: Rectangle {
            radius: 16
            color: root.surfaceColor
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Delete this property?")
                color: root.textColor
                font.pixelSize: 16
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("\"%1\" will be permanently removed. This action cannot be undone.").arg(root.propertyTitleName)
                color: root.mutedColor
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 10

                Button {
                    id: keepButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Keep")

                    contentItem: Label {
                        text: keepButton.text
                        color: root.textColor
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: "transparent"
                        border.color: root.borderColor
                        border.width: 1
                    }

                    onClicked: deleteDialog.close()
                }

                Button {
                    id: confirmDeleteButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Delete")

                    contentItem: Label {
                        text: confirmDeleteButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: confirmDeleteButton.down ? "#B91C1C" : root.dangerColor
                    }

                    onClicked: {
                        deleteDialog.close()
                        if (root.isDraftItem && root.draftKey.length > 0)
                            DraftViewModel.removeDraft(root.draftKey)
                        else
                            root.propertyDeleted()
                        UtilsModule.NavigationUtils.pop()
                    }
                }
            }
        }
    }

    footer: Rectangle {
        implicitHeight: footerBarRow.implicitHeight + 24
        color: root.surfaceColor

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: root.borderColor
        }

        RowLayout {
            id: footerBarRow
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 52
                spacing: 1

                Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: root.hasMonthlyPrice
                          ? "MK " + Number(root.monthlyPrice).toLocaleString()
                          : qsTr("Rent on request")
                    color: root.textColor
                    font.pixelSize: 17
                    font.bold: true
                }

                Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: root.agentMode ? qsTr("monthly rent") : qsTr("per month")
                    color: root.mutedColor
                    font.pixelSize: 11
                }
            }

            Button {
                id: cancelFooterButton
                visible: root.agentMode && root.editMode && !root.savingInProgress
                Layout.preferredWidth: 96
                Layout.preferredHeight: 48
                Layout.minimumWidth: 76
                Layout.maximumWidth: 96
                text: qsTr("Cancel")

                contentItem: Label {
                    text: cancelFooterButton.text
                    color: "#4B5563"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                // Overall cancel: reverts every uncommitted edit (fields, staged
                // photos, local room changes) and exits edit mode locally.
                background: Rectangle {
                    radius: 24
                    color: cancelFooterButton.down ? "#F3F4F6" : "#FFFFFF"
                    border.color: "#D1D5DB"
                    border.width: 1
                }

                onClicked: root.cancelEditing()
            }

            Button {
                id: agentFooterButton
                visible: root.agentMode
                Layout.preferredWidth: 164
                Layout.preferredHeight: 48
                Layout.minimumWidth: 140
                Layout.maximumWidth: 164
                text: root.editMode
                      ? (root.savingInProgress ? qsTr("Saving...") : qsTr("Save changes"))
                      : (root.isDraftItem ? qsTr("Resend draft") : qsTr("Edit property"))

                contentItem: Label {
                    text: agentFooterButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 24
                    color: agentFooterButton.down ? root.primaryDarkColor : root.primaryColor
                }

                onClicked: {
                    if (root.editMode) {
                        root.saveChanges()
                    } else if (root.isDraftItem) {
                        root.resendProperty()
                    } else {
                        root.startEditing()
                    }
                }
            }

            Button {
                id: bookNowButton
                visible: !root.agentMode
                Layout.preferredWidth: 150
                Layout.preferredHeight: 48
                Layout.minimumWidth: 130
                Layout.maximumWidth: 150
                text: qsTr("Book now")

                contentItem: Label {
                    text: bookNowButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 24
                    color: bookNowButton.down ? root.primaryDarkColor : root.primaryColor
                }

                onClicked: UtilsModule.NavigationUtils.navigateToPayments()
            }
        }
    }

    AppImageLightbox {
        id: photoViewer
        anchors.fill: parent
        title: root.propertyTitleName
        onClosed: { }
    }
}
