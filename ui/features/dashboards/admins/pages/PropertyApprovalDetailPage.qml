import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../properties/models"
import "../../../../components/cards"
import "../../../../components/scrollbars"
import "../../../../components/dialogs"
import "../../../../components/indicators"
import "../../../../utils/Utils.js" as Utils

// Dedicated review screen for a single property awaiting admin verification.
// Shows every detail the backend exposes (including photos, if any) so the
// admin can decide to Approve or Reject based on full information.
Item {
    id: root

    property var propertyPayload: null
    property string propertyId: ""
    property var listingsModel: null

    signal decisionMade(var propertyId, var title, var approved)
    signal goBackRequested()
    // Emitted once the backend confirms the delete, so the host screen can drop
    // its cached images and pop. Not emitted optimistically on click: a delete
    // that fails on the server must leave the admin on the page, not navigate
    // away from a property that is still there.
    signal propertyDeleted()

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color pageColor: "#F8FAFC"
    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color dangerColor: "#DC2626"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color softRedColor: "#FEF2F2"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property string propTitle: propertyPayload ? (propertyPayload.title || "Untitled property") : ""
    property string propDescription: propertyPayload ? (propertyPayload.description || "") : ""
    property string propDistrict: propertyPayload && propertyPayload.physicalAddress ? (propertyPayload.physicalAddress.district || "") : ""
    property string propVillage: propertyPayload && propertyPayload.physicalAddress ? (propertyPayload.physicalAddress.village || "") : ""
    property real propPrice: propertyPayload && propertyPayload.price ? Number(propertyPayload.price) : 0
    property string propLandlord: propertyPayload ? (propertyPayload.landlord || "") : ""
    property string propLandlordPhone: propertyPayload ? (propertyPayload.landlordPhone || "") : ""
    property string propOwner: propertyPayload ? (propertyPayload.ownerName || "") : ""
    property string propOwnerPhone: propertyPayload ? (propertyPayload.ownerPhone || "") : ""
    property var propAmenities: []
    property var propRooms: []
    property var propPhotos: []
    property string propStatus: propertyPayload ? String(propertyPayload.verificationStatus || "").toUpperCase() : "PENDING"

    // Admin who approved this listing (VERIFIED). Read from the payload's
    // approvedBy so reviewers can see who verified a property.
    property string propApprovedBy: propertyPayload ? String(propertyPayload.approvedByName || "") : ""

    readonly property bool hasPrice: root.propPrice > 0

    // ---- Delete flow ----
    // True only between our own delete call and its answer. PropertyViewModel's
    // deleted/error signals are app-wide, so an unguarded handler would react to
    // unrelated property requests made from other screens.
    property bool deletePending: false
    property string deleteError: ""
    // Set when the backend refuses the delete because rooms still hold
    // bookings; drives the "delete anyway" override dialog.
    property int blockedBookings: 0

    // Spelled out once so the override dialog and the warning copy cannot
    // disagree on the count. Built by hand rather than with a %n plural
    // because these strings are only ever shown untranslated in practice and a
    // missing plural entry would silently render the wrong form.
    readonly property string blockedBookingCount: root.blockedBookings === 1
        ? qsTr("1 active booking")
        : qsTr("%1 active bookings").arg(root.blockedBookings)

    // Rooms live in the separate /rooms/ collection keyed by propertyId, so
    // pull them from RoomViewModel (via C++) instead of the (room-less) payload
    // snapshot. This also reacts to rooms arriving late via the Connections below.
    function syncRooms() {
        root.propRooms = root.propertyId ? RoomViewModel.roomsForProperty(root.propertyId) : []
    }

    function confirmReject() {
        rejectReasonField.text = ""
        rejectError.visible = false
        rejectDialog.open()
    }

    // Refresh the header status display after a decision so the UI reflects the
    // change immediately (the payload snapshot itself is static until refetched).
    function applyStatus(newStatus, approvedBy) {
        root.propStatus = String(newStatus || "").toUpperCase()
        root.propApprovedBy = (root.propStatus === "VERIFIED") ? (approvedBy || "") : ""
        if (root.listingsModel)
            root.listingsModel.setPropertyStatus(root.propertyId, root.propStatus)
        // Keep the admin verification queue in step: the listing being reviewed
        // is queued from the owner-scoped fetch, not from the shared list.
        PropertyViewModel.setPendingListingStatus(root.propertyId, root.propStatus)
    }

    function doApprove() {
        root.applyStatus("VERIFIED", AppSettings.userName())
        // Persist the decision on the backend so it survives a refresh.
        // setPropertyStatus only edits the local list.
        PropertyViewModel.updatePropertyStatus(root.propertyId, "VERIFIED", "", AppSettings.userId(), AppSettings.userName())
        console.log("Approval:", root.propertyId, "-> VERIFIED")
        root.decisionMade(root.propertyId, root.propTitle, true)
        root.goBackRequested()
    }

    // Reverse an earlier decision (e.g. a property that was approved by mistake):
    // put it back in the review queue as PENDING so it can be re-reviewed.
    function doRevert() {
        root.applyStatus("PENDING")
        PropertyViewModel.updatePropertyStatus(root.propertyId, "PENDING")
        console.log("Approval:", root.propertyId, "-> PENDING")
        root.decisionMade(root.propertyId, root.propTitle, false)
        root.goBackRequested()
    }

    function doReject() {
        var reason = rejectReasonField.text.trim()
        if (reason.length < 5) {
            rejectError.visible = true
            return
        }
        rejectError.visible = false
        root.applyStatus("REJECTED")
        // Persist the decision (with the reason) on the backend so it survives a
        // refresh. setPropertyStatus only edits the local list.
        PropertyViewModel.updatePropertyStatus(root.propertyId, "REJECTED", reason)
        console.log("Approval:", root.propertyId, "-> REJECTED")
        root.decisionMade(root.propertyId, root.propTitle, false)
        root.goBackRequested()
        rejectDialog.close()
    }

    // ---- Delete ----
    // Same confirmation gate the agent-facing property page uses
    // (PropertyDetailsPage), reached from the same business call:
    // PropertyViewModel.deleteProperty -> DELETE /house-listing/:id.
    function confirmDelete() {
        root.deleteError = ""
        root.blockedBookings = 0
        deleteDialog.open()
    }

    // force=true only ever comes from the override dialog, i.e. after the admin
    // has seen how many bookings are in the way and confirmed anyway.
    function doDelete(force) {
        // Nothing server-side to remove without a real id (a local draft).
        if (!root.propertyId || root.propertyId.length === 0)
            return
        root.deletePending = true
        root.deleteError = ""
        deleteDialog.close()
        forceDeleteDialog.close()
        PropertyViewModel.deleteProperty(root.propertyId, force === true)
        console.log("Delete requested:", root.propertyId, "force:", force === true)
    }

    function handleDeleteSucceeded(id) {
        if (!root.deletePending || String(id) !== String(root.propertyId))
            return
        root.deletePending = false
        console.log("Delete confirmed:", root.propertyId)
        root.propertyDeleted()
    }

    function handleDeleteFailed(message) {
        if (!root.deletePending)
            return
        root.deletePending = false
        root.deleteError = (message && String(message).length > 0)
            ? String(message)
            : qsTr("This property could not be deleted. Please try again.")
        console.warn("Delete failed:", root.propertyId, root.deleteError)
    }

    // The backend refuses the delete while any room still holds a booking. It
    // reports how many, which we turn into an explicit override prompt rather
    // than a failure.
    function handleDeleteBlocked(activeBookings) {
        if (!root.deletePending)
            return
        root.deletePending = false
        root.deleteError = ""
        root.blockedBookings = Number(activeBookings) > 0 ? Number(activeBookings) : 1
        forceDeleteDialog.open()
        console.warn("Delete blocked by active bookings:", root.propertyId, root.blockedBookings)
    }

    // Amenities come from the property document (via C++). Fetching them here
    // keeps them authoritative and avoids QML ListModel/Array.isArray fragility.
    function syncAmenities() {
        root.propAmenities = root.propertyId ? PropertyViewModel.propertyListModel.amenitiesFor(root.propertyId) : []
    }

    function loadMedia() {
        if (!root.propertyId || root.propertyId.length === 0)
            return
        var serverPhotos = MediaViewModel.mediaForProperty(root.propertyId)
        if (serverPhotos && serverPhotos.length > 0) {
            root.propPhotos = serverPhotos
        } else {
            MediaViewModel.getMediaByProperty(root.propertyId)
        }
    }

    Component.onCompleted: {
        root.syncRooms()
        root.syncAmenities()
        root.loadMedia()
        RoomViewModel.loadRooms()
    }

    Connections {
        target: RoomViewModel.roomListModel
        function onCountChanged() { root.syncRooms() }
        function onModelReset() { root.syncRooms() }
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onCountChanged() { root.syncAmenities() }
        function onModelReset() { root.syncAmenities() }
        function onDataChanged() { root.syncAmenities() }
    }

    Connections {
        target: MediaViewModel.mediaListModel
        function onCountChanged() { root.loadMedia() }
        function onModelReset() { root.loadMedia() }
    }

    // Backend answer for the delete started above. Both handlers bail out unless
    // deletePending is set, because these signals are shared with every other
    // property operation in the app.
    Connections {
        target: PropertyViewModel

        function onPropertyDeletedSignal(id) { root.handleDeleteSucceeded(id) }
        function onPropertyError(message) { root.handleDeleteFailed(message) }
        function onPropertyDeleteBlockedSignal(activeBookings) { root.handleDeleteBlocked(activeBookings) }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 24
        clip: true

        ScrollBar.vertical: AppScrollBar { }

        ColumnLayout {
            id: contentColumn
            x: Math.max(12, (width - 520) / 2)
            width: Math.min(parent.width - 24, 520)
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: heroColumn.implicitHeight + 32
                radius: 14
                color: root.primaryColor

                ColumnLayout {
                    id: heroColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 18
                    spacing: 8

                    Label {
                        Layout.fillWidth: true
                        text: root.propTitle
                        color: "#FFFFFF"
                        font.pixelSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        Layout.fillWidth: true
                        text: (root.propDistrict.length > 0 || root.propVillage.length > 0)
                              ? root.propDistrict + " · " + root.propVillage : qsTr("No location provided")
                        color: Qt.rgba(1, 1, 1, 0.85)
                        font.pixelSize: 13
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        implicitHeight: priceLine.implicitHeight + 20
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            id: priceLine
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Label {
                                text: root.hasPrice ? "MK " + Number(root.propPrice).toLocaleString() : qsTr("Rent on request")
                                color: "#FFFFFF"
                                font.pixelSize: 21
                                font.bold: true
                            }

                            Label {
                                visible: root.hasPrice
                                text: qsTr("/ month")
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 13
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: {
                                    var s = root.propStatus
                                    if (s === "PENDING") return qsTr("PENDING")
                                    if (s === "VERIFIED") return qsTr("VERIFIED")
                                    if (s === "REJECTED") return qsTr("REJECTED")
                                    return s
                                }
                                color: Qt.rgba(1, 1, 1, 0.9)
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Label {
                                visible: root.propStatus === "VERIFIED" && root.propApprovedBy.length > 0
                                text: qsTr("by %1").arg(root.propApprovedBy)
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Photos")
                actionLabel: root.propPhotos.length > 0 ? qsTr("%1 shown").arg(root.propPhotos.length) : ""
            }

            Rectangle {
                visible: root.propPhotos.length === 0
                Layout.fillWidth: true
                implicitHeight: 120
                radius: 12
                color: root.softBlueColor
                border.color: "#BFDBFE"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No photos available for this listing")
                        color: root.textColor
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("The agent has not attached images to this property.")
                        color: root.mutedColor
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                visible: root.propPhotos.length > 0
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
                        model: root.propPhotos

                        delegate: Item {
                            required property var modelData
                            required property int index
                            readonly property string photoSource: {
                                if (typeof modelData === "string")
                                    return Utils.cachedImage(modelData)
                                return Utils.cachedImage(modelData.path || modelData.url || "")
                            }
                            readonly property bool isPrimary: typeof modelData === "object" && !!modelData.isPrimary

                            width: 88
                            height: 108

                            Rectangle {
                                width: 88
                                height: 88
                                radius: 10
                                color: root.softBlueColor
                                clip: true
                                border.color: isPrimary ? root.primaryColor : root.borderColor
                                border.width: isPrimary ? 2 : 1

                                Image {
                                    id: thumbImage
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: photoSource
                                    sourceSize.width: 280
                                    sourceSize.height: 280
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                }

                                AppSpinner {
                                    anchors.centerIn: parent
                                    size: 16
                                    lineWidth: 2
                                    color: root.mutedColor
                                    running: thumbImage.status === Image.Loading
                                    visible: running
                                }

                                Label {
                                    visible: thumbImage.status === Image.Error
                                    anchors.centerIn: parent
                                    text: qsTr("No preview")
                                    color: root.mutedColor
                                    font.pixelSize: 8
                                }

                                Rectangle {
                                    visible: isPrimary
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
                                    onClicked: photoViewer.openWithImages(root.propPhotos, index)
                                }
                            }

                            Label {
                                y: 92
                                width: parent.width
                                text: isPrimary ? qsTr("Cover") : qsTr("Photo %1").arg(index + 1)
                                color: root.mutedColor
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Property details")
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: aboutLabel.implicitHeight + 28
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Label {
                    id: aboutLabel
                    anchors.fill: parent
                    anchors.margins: 14
                    text: root.propDescription.length > 0 ? root.propDescription : qsTr("No description provided by the agent.")
                    color: root.textColor
                    font.pixelSize: 13
                    lineHeight: 1.25
                    wrapMode: Text.WordWrap
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Amenities")
                actionLabel: String(root.propAmenities.length)
            }

            Rectangle {
                visible: root.propAmenities.length === 0
                Layout.fillWidth: true
                implicitHeight: 64
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: qsTr("No amenities listed")
                    color: root.mutedColor
                    font.pixelSize: 12
                }
            }

            Rectangle {
                visible: root.propAmenities.length > 0
                Layout.fillWidth: true
                implicitHeight: amenFlow.implicitHeight + 24
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Flow {
                    id: amenFlow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Repeater {
                        model: root.propAmenities

                        delegate: Rectangle {
                            required property var modelData
                            readonly property string label: {
                                var labels = {
                                    "WIFI": qsTr("Wi-Fi"), "PARKING": qsTr("Parking"),
                                    "SECURITY": qsTr("Security"), "WATER": qsTr("Water"),
                                    "ELECTRICITY": qsTr("Electricity"), "FURNISHED": qsTr("Furnished"),
                                    "AC": qsTr("A/C")
                                }
                                return labels[String(modelData)] !== undefined ? labels[String(modelData)] : String(modelData)
                            }
                            width: labelChip.implicitWidth + 24
                            height: 28
                            radius: 14
                            color: root.softBlueColor

                            Label {
                                id: labelChip
                                anchors.centerIn: parent
                                text: parent.label
                                color: root.primaryColor
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Rooms")
                actionLabel: String(root.propRooms.length)
            }

            Rectangle {
                visible: root.propRooms.length === 0
                Layout.fillWidth: true
                implicitHeight: 64
                radius: 12
                color: root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: qsTr("No rooms listed")
                    color: root.mutedColor
                    font.pixelSize: 12
                }
            }

            Repeater {
                model: root.propRooms

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    implicitHeight: roomRow.implicitHeight + 20
                    radius: 12
                    color: root.surfaceColor
                    border.color: root.borderColor
                    border.width: 1

                    RowLayout {
                        id: roomRow
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
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
                                text: qsTr("Room %1 · %2").arg(index + 1).arg(modelData.roomType || modelData.type || "")
                                color: root.textColor
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Label {
                                text: {
                                    var rp = Number(modelData.price || 0)
                                    return rp > 0 ? "MK " + rp.toLocaleString() + qsTr("/mo") : qsTr("Price on request")
                                }
                                color: root.mutedColor
                                font.pixelSize: 11
                            }
                        }

                        StatusChip {
                            textValue: modelData.available === false ? qsTr("Unavailable") : qsTr("Available")
                            variant: modelData.available === false ? "neutral" : "success"
                        }
                    }
                }
            }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Contacts")
            }

            ContactCard {
                title: qsTr("Listed by")
                name: root.propOwner
                phone: root.propOwnerPhone
                accentColor: root.primaryColor
                onCallRequested: function (number) {
                    if (number && number.length > 0)
                        Qt.openUrlExternally("tel:" + number)
                }
            }

            ContactCard {
                title: qsTr("Landlord")
                name: root.propLandlord
                phone: root.propLandlordPhone
                accentColor: root.successColor
                onCallRequested: function (number) {
                    if (number && number.length > 0)
                        Qt.openUrlExternally("tel:" + number)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: rejectButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    text: qsTr("Reject")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: rejectButton.text
                        color: "#B91C1C"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 23
                        color: rejectButton.down ? "#FEE2E2" : root.softRedColor
                        border.color: "#FECACA"
                        border.width: 1
                    }

                    onClicked: root.confirmReject()
                }

                Button {
                    id: approveButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    // For a listing that is already VERIFIED the primary action
                    // becomes "Revert to pending" so an admin can undo an
                    // accidental approval; otherwise it is the approval itself.
                    text: root.propStatus === "VERIFIED" ? qsTr("Revert to pending") : qsTr("Approve")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: approveButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 23
                        color: approveButton.down ? "#15803D" : root.successColor
                    }

                    onClicked: {
                        if (root.propStatus === "VERIFIED")
                            root.doRevert()
                        else
                            root.doApprove()
                    }
                }
            }

            // Delete gets its own row rather than a third button in the row above:
            // an irreversible delete should not sit one mis-tap away from
            // Approve. Outlined rather than filled so it reads as destructive
            // without competing with the two primary actions.
            Button {
                id: deleteButton
                Layout.fillWidth: true
                visible: root.propertyId.length > 0
                Layout.preferredHeight: visible ? 46 : 0
                enabled: !root.deletePending
                text: root.deletePending ? qsTr("Deleting...") : qsTr("Delete property")

                contentItem: Item {
                    Text {
                        id: deleteLabel
                        anchors.centerIn: parent
                        // Half the spinner (16px) plus half the 8px gap, so the
                        // spinner and label stay centred as the text changes.
                        anchors.horizontalCenterOffset: root.deletePending ? 12 : 0
                        text: deleteButton.text
                        color: "#B91C1C"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    AppSpinner {
                        // Explicit width/height: this contentItem is a plain Item,
                        // so AppSpinner's implicit size is never applied.
                        width: 16
                        height: 16
                        size: 16
                        lineWidth: 2.5
                        color: "#B91C1C"
                        anchors.right: deleteLabel.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: deleteLabel.verticalCenter
                        visible: root.deletePending
                        running: root.deletePending
                    }
                }

                background: Rectangle {
                    radius: 23
                    color: "#FFFFFF"
                    border.color: "#FECACA"
                    border.width: 1
                }

                onClicked: root.confirmDelete()
            }

            // Delete failure message. Shown in place of the dialog so the admin
            // keeps the full context of what they were trying to remove.
            Label {
                Layout.fillWidth: true
                visible: root.deleteError.length > 0
                text: root.deleteError
                color: root.dangerColor
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }
        }
    }

    AppImageLightbox {
        id: photoViewer
        anchors.fill: parent
        title: root.propTitle
        onClosed: { }
    }

    Dialog {
        id: rejectDialog
        modal: true
        width: Math.min(parent ? parent.width - 40 : 320, 360)
        anchors.centerIn: parent
        padding: 18
        title: qsTr("Reject property")

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: qsTr("Tell the agent what to fix so they can resubmit.")
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: "#374151"
            }

            TextArea {
                id: rejectReasonField
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(rejectReasonField.contentHeight + 36, 96)
                placeholderText: ""
                color: root.textColor
                font.pixelSize: 12
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                leftPadding: 14
                rightPadding: 14
                topPadding: rejectReasonField.activeFocus || rejectReasonField.text.length > 0 ? 30 : 12
                bottomPadding: 8

                property int maxLength: 500

                onTextChanged: {
                    if (text.length > maxLength) {
                        var cursorPos = cursorPosition
                        text = text.substring(0, maxLength)
                        cursorPosition = Math.min(cursorPos, text.length)
                    }
                    rejectError.visible = false
                }

                background: Item {
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#FFFFFF"
                        border.width: rejectReasonField.activeFocus || rejectError.visible ? 2 : 1
                        border.color: rejectError.visible ? root.dangerColor
                                     : rejectReasonField.activeFocus ? root.primaryColor
                                     : root.borderColor
                    }

                    Text {
                        id: rejectFloating
                        readonly property bool isFloating: rejectReasonField.activeFocus || rejectReasonField.text.length > 0
                        text: qsTr("Reason for rejection...")
                        color: rejectError.visible ? root.dangerColor
                               : rejectReasonField.activeFocus ? root.primaryColor
                               : root.mutedColor
                        font.pixelSize: isFloating ? 11 : 12
                        font.weight: isFloating ? Font.Medium : Font.Normal
                        x: 14
                        width: parent.width - 28
                        elide: Text.ElideRight

                        y: isFloating ? 8 : Math.round((parent.height - height) / 2)

                        Behavior on y {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on font.pixelSize {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                            }
                        }
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: qsTr("%L1 / %L2 characters").arg(rejectReasonField.length).arg(rejectReasonField.maxLength)
                color: rejectReasonField.length >= rejectReasonField.maxLength ? root.dangerColor : root.mutedColor
                font.pixelSize: 10
            }

            Label {
                id: rejectError
                visible: false
                Layout.fillWidth: true
                text: qsTr("Add a reason (at least a few words) so the agent can fix it.")
                color: root.dangerColor
                font.pixelSize: 11
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Cancel")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Cancel")
                        color: root.textColor
                        font.pixelSize: 13
                    }

                    background: Rectangle {
                        radius: 8
                        color: root.surfaceColor
                        border.color: root.borderColor
                        border.width: 1
                    }

                    onClicked: rejectDialog.reject()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Reject")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Reject")
                        color: "#B91C1C"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: root.softRedColor
                        border.color: "#FECACA"
                        border.width: 1
                    }

                    onClicked: root.doReject()
                }
            }
        }
    }

    // Confirmation gate for the irreversible delete, matching the one on the
    // agent-facing property detail page. Stays open on nothing: the dialog is
    // only a "are you sure", the outcome arrives on PropertyViewModel's signals
    // and is reported on the page itself.
    Dialog {
        id: deleteDialog
        modal: true
        width: Math.min(parent ? parent.width - 48 : 340, 340)
        anchors.centerIn: parent
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
                text: qsTr("\"%1\", its rooms and its photos will be permanently removed. If any of its rooms still has an active booking, the delete will be blocked and you will be asked to confirm.").arg(root.propTitle)
                color: root.mutedColor
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Keep")

                    contentItem: Label {
                        text: qsTr("Keep")
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
                    id: deleteConfirmButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Delete")

                    contentItem: Label {
                        text: qsTr("Delete")
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: deleteConfirmButton.down ? "#B91C1C" : root.dangerColor
                    }

                    onClicked: root.doDelete()
                }
            }
        }
    }

    // Opened only when the backend refuses the delete with HTTP 409 because
    // the property's rooms still hold bookings. This is the one decision the
    // admin has to make themselves, so it is stated in full: how many bookings
    // are in the way, that they will be cancelled, that the rooms disappear
    // with the property, and that the booking rows themselves are kept so the
    // payment history survives. "Keep property" is the safe default and closes
    // without touching the backend, which is still fully intact at this point.
    Dialog {
        id: forceDeleteDialog
        modal: true
        width: Math.min(parent ? parent.width - 48 : 340, 340)
        anchors.centerIn: parent
        padding: 20

        background: Rectangle {
            radius: 16
            color: root.surfaceColor
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                Layout.fillWidth: true
                text: qsTr("Delete despite an active booking?")
                color: root.textColor
                font.pixelSize: 16
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("\"%1\" still has %2. Deleting it will cancel %3 and remove the rooms, so those clients lose the reservation.")
                        .arg(root.propTitle)
                        .arg(root.blockedBookingCount)
                        .arg(root.blockedBookings === 1 ? qsTr("it") : qsTr("them"))
                color: root.mutedColor
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("The cancelled bookings stay on record so payment history is not lost.")
                color: root.mutedColor
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Keep property")

                    contentItem: Label {
                        text: qsTr("Keep property")
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

                    onClicked: forceDeleteDialog.close()
                }

                Button {
                    id: forceDeleteConfirmButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Delete anyway")

                    contentItem: Label {
                        text: qsTr("Delete anyway")
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 22
                        color: forceDeleteConfirmButton.down ? "#B91C1C" : root.dangerColor
                    }

                    onClicked: root.doDelete(true)
                }
            }
        }
    }
}
