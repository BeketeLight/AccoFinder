import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../../dashboards/Agets/pages"
import "../../../components/inputs"
import "../../../components/indicators"

Page {
    id: root

    readonly property color pageColor: "#F8FAFC"
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property string pageTitle: qsTr("Properties")
    property bool showHeader: true
    property bool showBack: false

    signal addPropertyRequested()
    signal attentionClicked(var kind, var targetId)
    signal propertyClicked(var propertyId)
    signal draftClicked(var payload)
    signal bookingClicked()
    signal notificationClicked()
    signal disputeClicked()
    signal draftsClicked()

    // Selected filter chip: All / Verified / Pending / Draft / Rejected
    property string statusFilter: "All"
    property string searchText: ""
    property int resultCount: 0
    property int serverCount: 0
    // True while the server-backed property list is fetching. The network runs
    // asynchronously off the UI thread, so rendering stays smooth; we surface
    // this so the user sees progress instead of an apparent hang. Toggled by
    // the isLoadingChanged signal (true on start, false on success OR failure).
    property bool loading: false
    // True while a pull-to-refresh is in flight. Set when the user drags the
    // list down past the top and lets it snap back; cleared when the fetch ends.
    property bool refreshing: false
    property bool pullArmed: false

    // Server-backed properties (VERIFIED/PENDING/REJECTED) merged with local
    // DRAFT rows in a single QML model, so the same filtering code serves both.
    ListModel { id: filterChipsModel }

    ListModel { id: allPropertiesModel }

    function prettyStatus(s) {
        var v = String(s).toUpperCase()
        if (v === "VERIFIED") return qsTr("Verified")
        if (v === "PENDING") return qsTr("Pending")
        if (v === "REJECTED") return qsTr("Rejected")
        if (v === "DRAFT") return qsTr("Draft")
        return v.length > 0 ? v : qsTr("Draft")
    }

    function rowMatches(row) {
        var wanted = root.statusFilter === "All" ? "" : root.statusFilter.toUpperCase()
        var okStatus = wanted.length === 0
                     || String(row.verificationStatus).toUpperCase() === wanted
        var q = root.searchText.trim().toLowerCase()
        var okSearch = q.length === 0
                     || (row.title || "").toLowerCase().indexOf(q) !== -1
                     || (row.district || "").toLowerCase().indexOf(q) !== -1
                     || (row.village || "").toLowerCase().indexOf(q) !== -1
        return okStatus && okSearch
    }

    function applyFilters() {
        var count = 0
        for (var i = 0; i < allPropertiesModel.count; i++) {
            var row = allPropertiesModel.get(i)
            var match = root.rowMatches(row)
            allPropertiesModel.setProperty(i, "matches", match)
            if (match)
                count++
        }
        root.resultCount = count
        // Only show the "No properties yet" empty state when the account is
        // genuinely empty — a saved draft is still a property to review. Hide
        // it during the initial load so it doesn't flash before data arrives.
        var haveAny = root.serverCount > 0 || DraftViewModel.count > 0
        emptyServerState.visible = !root.loading && !haveAny
        noMatchState.visible = !root.loading && haveAny && count === 0
    }

    function payloadForId(propertyId) {
        var row = null
        for (var i = 0; i < allPropertiesModel.count; i++) {
            var r = allPropertiesModel.get(i)
            if (r.source === "draft")
                continue
            if (String(r.propertyId) === String(propertyId)) {
                row = r
                break
            }
        }
        if (!row)
            return null

        // The local rows above only carry what the cards need (id, title, area,
        // price, status). Pull the full owner + landlord details straight from
        // the shared C++ model row so the detail page renders real database data
        // instead of its placeholders.
        var full = null
        var m = PropertyViewModel.propertyListModel
        for (var k = 0; m && k < m.size(); k++) {
            var cand = m.at(k)
            if (String(cand.propertyId) === String(propertyId)) {
                full = cand
                break
            }
        }

        return {
            title: row.title,
            description: full ? (full.description || "") : "",
            physicalAddress: {
                district: row.district || (full ? full.district : ""),
                village: row.village || (full ? full.village : "")
            },
            price: row.price,
            verificationStatus: row.verificationStatus,
            propertyId: String(row.propertyId),
            isActive: true,
            amenities: m ? m.amenitiesFor(String(row.propertyId)) : [],
            landlord: full ? (full.landlord || "") : "",
            landlordPhone: full ? (full.landlordPhone || "") : "",
            ownerName: full ? (full.ownerName || "") : "",
            ownerPhone: full ? (full.ownerPhone || "") : "",
            rooms: full && full.propertyId ? RoomViewModel.roomsForProperty(full.propertyId) : [],
            photos: []
        }
    }

    function refreshAll() {
        allPropertiesModel.clear()

        // The agent dashboard is the "My properties" view, so we only ever show
        // listings owned by the currently logged-in user. The backend is asked
        // for the owner's listings (?owner=userId), but as a second layer of
        // defence we also filter here by the parsed owner/agentId — the shared
        // C++ PropertyViewModel can be refreshed by other screens (My
        // Properties, admin, etc.) and must not leak another user's listings
        // into this view. Drafts are local and always belong to this device.
        var myId = AppSettings.userId()
        var server = PropertyViewModel.propertiesForView() || []
        root.serverCount = 0
        for (var s = 0; s < server.length; s++) {
            var sp = server[s]
            var ownerId = String(sp.agentId || "")
            if (ownerId.length > 0 && ownerId !== String(myId))
                continue
            root.serverCount++
            allPropertiesModel.append({
                propertyId: sp.id || "",
                title: sp.title || "Untitled property",
                district: sp.district || "",
                village: sp.village || "",
                price: sp.price !== undefined ? sp.price : 0,
                verificationStatus: sp.verificationStatus || "PENDING",
                source: "server",
                matches: true
            })
        }

        // Local drafts never hit the backend, so they are surfaced separately
        // under the DRAFT filter.
        var drafts = DraftViewModel.allDrafts() || {}
        var keys = Object.keys(drafts)
        for (var k = 0; k < keys.length; k++) {
            var d = drafts[keys[k]] || {}
            allPropertiesModel.append({
                propertyId: keys[k],
                title: d.title || "Untitled property",
                district: (d.physicalAddress && d.physicalAddress.district) || "",
                village: (d.physicalAddress && d.physicalAddress.village) || "",
                price: d.price !== undefined ? d.price : 0,
                verificationStatus: "DRAFT",
                source: "draft",
                matches: true
            })
        }

        root.applyFilters()
    }

    // Triggered by pull-to-refresh (and guarded against overlap): re-fetch the
    // server list. The result flows back through PropertyViewModel signals.
    function refresh() {
        if (root.refreshing)
            return
        root.refreshing = true
        // Fetch only the current user's listings on the agent dashboard.
        PropertyViewModel.getProperties(AppSettings.userId())
        RoomViewModel.loadRooms()
        // Also refresh the dashboard sections' data from their C++ view models.
        BookingViewModel.fetchBookings()
        NotificationViewModel.getNotifications()
        DisputesListViewModel.getDisputes()
    }

    function armIfPulled() {
        // Arm the refresh while the finger is still dragging the list past the
        // top (contentY is only negative during the drag; it springs back
        // to 0 on release, so we must latch the trigger before that).
        if (flick.dragging && flick.contentY <= -56)
            root.pullArmed = true
    }

    function handlePullRelease() {
        if (root.pullArmed && !root.refreshing) {
            root.refresh()
            // Snap the list back to the top so the header isn't left hanging.
            flick.returnToBounds()
        }
        root.pullArmed = false
    }

    Component.onCompleted: {
        filterChipsModel.append([{ label: "All" }, { label: "Verified" },
                                 { label: "Pending" }, { label: "Draft" },
                                 { label: "Rejected" }])
        // Fetch only the current user's listings on the agent dashboard.
        PropertyViewModel.getProperties(AppSettings.userId())
        RoomViewModel.loadRooms()
        root.refreshAll()
    }

    Connections {
        target: DraftViewModel
        function onDraftsChanged() { root.refreshAll() }
    }

    Connections {
        target: PropertyViewModel
        function onIsLoadingChanged(loading) {
            root.loading = loading
            if (!loading)
                root.refreshing = false
            root.refreshAll()
        }
    }

    Connections {
        target: PropertyViewModel.propertyListModel
        function onModelReset() { root.refreshAll() }
        function onRowsInserted(parent, first, last) { root.refreshAll() }
        function onRowsRemoved(parent, first, last) { root.refreshAll() }
    }

    background: Rectangle { color: root.pageColor }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 96
        clip: true

        ScrollBar.vertical: ScrollBar { }

        onContentYChanged: root.armIfPulled()
        onDragEnded: root.handlePullRelease()

        // Pull-to-refresh indicator: a small strip shown at the top while the
        // content is dragged down (or while a refresh is running).
        ColumnLayout {
            id: pullIndicator
            z: 10
            anchors.horizontalCenter: parent.horizontalCenter
            // Slide in from above the viewport as the content is pulled down.
            y: -40 + Math.abs(Math.min(0, flick.contentY))
            spacing: 4
            visible: root.refreshing || flick.contentY < -2
            opacity: Math.min(1, Math.abs(Math.min(0, flick.contentY)) / 56)

            AppSpinner {
                Layout.alignment: Qt.AlignHCenter
                size: 20
                lineWidth: 2
                color: root.mutedColor
                running: root.refreshing
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: root.refreshing ? qsTr("Refreshing…") : qsTr("Pull to refresh")
                color: root.mutedColor
                font.pixelSize: 11
            }
        }

        ColumnLayout {
            id: contentColumn
            x: Math.max(16, (flick.width - 560) / 2)
            y: 20
            width: Math.min(flick.width - 32, 560)
            spacing: 14

            AgentsDashboardPage {
                Layout.fillWidth: true

                onAddPropertyRequested: root.addPropertyRequested()
                onAttentionClicked: (kind, targetId) => {
                    if (kind === "server") {
                        // Rejected / missing-info server property: open the real
                        // property detail page so the agent can edit whatever is
                        // wrong there.
                        root.propertyClicked(targetId)
                    } else {
                        // Local draft awaiting review/resend.
                        var d = DraftViewModel.getDraft(targetId)
                        if (d) {
                            d.draftKey = targetId
                            root.draftClicked(d)
                        }
                    }
                }
                onBookingClicked: root.bookingClicked()
                onNotificationClicked: root.notificationClicked()
                onDisputeClicked: root.disputeClicked()
            }

            Item { Layout.preferredHeight: 4; Layout.fillWidth: true }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("My properties")
                actionLabel: qsTr("%1 shown").arg(root.resultCount)
            }

            AppSearchBar {
                Layout.fillWidth: true
                placeholder: qsTr("Search by name or location")
                backgroundColor: root.surfaceColor
                focusColor: root.primaryColor
                fieldHeight: 44
                text: root.searchText
                onTextEdited: {
                    root.searchText = text
                    root.applyFilters()
                }
                onCleared: {
                    root.searchText = ""
                    root.applyFilters()
                }
            }

            Flickable {
                Layout.fillWidth: true
                implicitHeight: filterChipsRow.implicitHeight
                contentWidth: filterChipsRow.implicitWidth
                clip: true
                interactive: filterChipsRow.implicitWidth > width

                Row {
                    id: filterChipsRow
                    spacing: 8

                    Repeater {
                        model: filterChipsModel

                        delegate: Rectangle {
                            required property var model
                            required property int index
                            width: chipLabel.implicitWidth + 26
                            height: 32
                            radius: 16
                            color: root.statusFilter === model.label ? root.primaryColor : root.surfaceColor
                            border.color: root.statusFilter === model.label ? root.primaryColor : root.borderColor
                            border.width: 1

                            Label {
                                id: chipLabel
                                anchors.centerIn: parent
                                text: model.label
                                color: root.statusFilter === model.label ? "#FFFFFF" : root.mutedColor
                                font.pixelSize: 12
                                font.bold: root.statusFilter === model.label
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.statusFilter = model.label
                                    root.applyFilters()
                                }
                            }
                        }
                    }
                }
            }

            // Inline loading state shown while the server list is fetching, on
            // first load and during pull-to-refresh (drafts still render under).
            ColumnLayout {
                visible: root.loading || root.refreshing
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 4

                AppSpinner {
                    Layout.alignment: Qt.AlignHCenter
                    size: 28
                    lineWidth: 3
                    color: root.primaryColor
                    running: root.loading || root.refreshing
                }

                Label {
                    Layout.fillWidth: true
                    text: root.refreshing ? qsTr("Refreshing properties…") : qsTr("Loading properties…")
                    color: root.mutedColor
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ColumnLayout {
                visible: root.resultCount > 0
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: allPropertiesModel

                    delegate: Rectangle {
                        required property var model
                        Layout.fillWidth: true
                        implicitHeight: propRow.implicitHeight + 24
                        radius: 12
                        color: propCardMouse.pressed ? root.softBlueColor : root.surfaceColor
                        border.color: propCardMouse.pressed ? "#BFDBFE" : root.borderColor
                        border.width: 1
                        visible: model.matches

                        RowLayout {
                            id: propRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                radius: 12
                                color: root.softBlueColor

                                Label {
                                    anchors.centerIn: parent
                                    text: String(model.title).charAt(0)
                                    color: root.primaryColor
                                    font.pixelSize: 17
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    Layout.fillWidth: true
                                    text: model.title
                                    color: root.textColor
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: (model.district ? model.district + " · " : "") +
                                          (model.village ? model.village + " · " : "") +
                                          qsTr("MK %1").arg(Number(model.price).toLocaleString()) + qsTr("/mo")
                                    color: root.mutedColor
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }

                            StatusChip {
                                textValue: root.prettyStatus(model.verificationStatus)
                                variant: {
                                    var s = String(model.verificationStatus).toUpperCase()
                                    if (s === "VERIFIED") return "success"
                                    if (s === "PENDING") return "warning"
                                    if (s === "REJECTED") return "danger"
                                    return "neutral"
                                }
                            }

                            Item {
                                Layout.preferredWidth: 9
                                Layout.preferredHeight: 16

                                Rectangle {
                                    width: 10
                                    height: 1.8
                                    radius: 0.9
                                    color: root.mutedColor
                                    rotation: 45
                                    transformOrigin: Item.Left
                                    x: 0
                                    y: 2.5
                                }

                                Rectangle {
                                    width: 10
                                    height: 1.8
                                    radius: 0.9
                                    color: root.mutedColor
                                    rotation: -45
                                    transformOrigin: Item.Left
                                    x: 0
                                    y: 13.5
                                }
                            }
                        }

                        MouseArea {
                            id: propCardMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (model.source === "draft") {
                                    var d = DraftViewModel.getDraft(model.propertyId)
                                    if (d) {
                                        d.draftKey = model.propertyId
                                        root.draftClicked(d)
                                    }
                                } else {
                                    root.propertyClicked(model.propertyId)
                                }
                            }
                        }
                    }
                }
            }

            // Empty state: no server properties at all (nothing fetched yet,
            // or the account genuinely has none).
            ColumnLayout {
                id: emptyServerState
                visible: false
                Layout.fillWidth: true
                Layout.topMargin: 12
                spacing: 8

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: 32
                    color: root.softBlueColor
                    border.color: "#BFDBFE"
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/ui/assets/properties-icon.svg"
                        sourceSize.width: 32
                        sourceSize.height: 32
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("No properties yet")
                    color: root.textColor
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 320
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Add your first property from the button below to get started.")
                    color: root.mutedColor
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }

            // No match for the selected filter/search (server has data).
            Label {
                id: noMatchState
                visible: false
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: qsTr("No properties match your search.")
                color: root.mutedColor
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Rectangle {
        id: fab
        width: 54
        height: 54
        radius: 27
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.primaryColor }
            GradientStop { position: 1.0; color: root.primaryDarkColor }
        }

        Label {
            anchors.centerIn: parent
            text: "+"
            color: "#FFFFFF"
            font.pixelSize: 24
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.addPropertyRequested()
        }
    }
}
