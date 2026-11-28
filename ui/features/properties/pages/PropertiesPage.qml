import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../delegates"
import "../../dashboards/Agets/pages"
import "../../../components/inputs"
import "../../../components/indicators"
import "../../../components/scrollbars"
import "../../../utils/Utils.js" as Utils

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

    // Root pages are cached, so a hidden Properties tab must not rebuild its
    // QML models in response to C++ signals fired by another tab. The parent
    // page's enabled binding already tracks visible + stack depth; walking the
    // chain also covers this embedded page.
    readonly property bool pageActive: Utils.isPageActive(root)
    // Main.qml uses this to defer the shared property feed while this tab is
    // being flicked. The local rebuild path already checks the same state.
    readonly property bool scrollIdle: !flick.moving && !flick.dragging && !flick.flicking

    // C++ view models emit rowsInserted/countChanged once per row. Rebuilding
    // allPropertiesModel on every signal made the Repeater destroy and recreate
    // every card while the user was flicking, which stopped the flick and made
    // the page look frozen on first navigation. Coalesce the signals and wait
    // until the Flickable is idle before applying them.
    property bool _refreshPending: false
    property real _savedScrollY: 0

    function requestRefreshAll() {
        root._refreshPending = true
        // Keep the changes for later if a pushed page or another tab is active;
        // onPageActiveChanged applies them when this tab comes back.
        if (!root.pageActive)
            return
        refreshCoalesceTimer.restart()
    }

    function applyPendingRefresh() {
        if (!root._refreshPending || !root.pageActive)
            return
        root._refreshPending = false
        root.refreshAll()
    }

    Timer {
        id: refreshCoalesceTimer
        interval: 80
        repeat: false
        running: false
        onTriggered: {
            if (flick.moving || flick.dragging || flick.flicking) {
                if (!waitForFlickEndTimer.running)
                    waitForFlickEndTimer.start()
                return
            }
            root.applyPendingRefresh()
        }
    }

    Timer {
        id: waitForFlickEndTimer
        interval: 50
        repeat: true
        running: false
        onTriggered: {
            if (!flick.moving && !flick.dragging && !flick.flicking) {
                stop()
                root.applyPendingRefresh()
            }
        }
    }

    Timer {
        // contentHeight is only final after the Repeater has laid out; restore
        // the scroll offset on the next event-loop turn, before the next frame.
        id: restoreScrollTimer
        interval: 0
        repeat: false
        running: false
        onTriggered: {
            if (flick.moving || flick.dragging || flick.flicking)
                return
            var maxY = Math.max(0, flick.contentHeight - flick.height)
            flick.contentY = Math.min(root._savedScrollY, maxY)
        }
    }

    onPageActiveChanged: {
        if (root.pageActive && root._refreshPending)
            refreshCoalesceTimer.restart()
    }

    // Server-backed properties (VERIFIED/PENDING/REJECTED) merged with local
    // DRAFT rows in a single QML model, so the same filtering code serves both.
    ListModel { id: filterChipsModel }

    ListModel { id: allPropertiesModel }

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
        var m = PropertyViewModel ? PropertyViewModel.propertyListModel : null
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
            propertyType: full ? (full.propertyType || "") : "",
            rejectionReason: (full ? (full.rejectionReason || "") : (row.rejectionReason || "")),
            propertyId: String(row.propertyId),
            isActive: true,
            amenities: m ? m.amenitiesFor(String(row.propertyId)) : [],
            landlord: full ? (full.landlord || "") : "",
            landlordPhone: full ? (full.landlordPhone || "") : "",
            ownerName: full ? (full.ownerName || "") : "",
            ownerPhone: full ? (full.ownerPhone || "") : "",
            rooms: (full && full.propertyId && RoomViewModel && RoomViewModel.roomsForProperty)
                   ? RoomViewModel.roomsForProperty(full.propertyId) : [],
            photos: []
        }
    }

    function refreshAll() {
        // Remember where the user was before clear() temporarily collapses the
        // content height. Pull-to-refresh starts at the top, so never restore a
        // negative contentY.
        root._savedScrollY = Math.max(0, flick.contentY)
        allPropertiesModel.clear()

        // The agent dashboard is the "My properties" view, so we only ever show
        // listings owned by the currently logged-in user. The backend is asked
        // for the owner's listings (?owner=userId), but as a second layer of
        // defence we also filter here by the parsed owner/agentId — the shared
        // C++ PropertyViewModel can be refreshed by other screens (My
        // Properties, admin, etc.) and must not leak another user's listings
        // into this view. Drafts are local and always belong to this device.
        var myId = AppSettings.userId()
        var server = (PropertyViewModel && PropertyViewModel.propertiesForView)
                     ? PropertyViewModel.propertiesForView() : []
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
                rejectionReason: sp.rejectionReason || "",
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
        restoreScrollTimer.restart()
    }

    // Triggered by pull-to-refresh (and guarded against overlap): re-fetch the
    // server list. The result flows back through PropertyViewModel signals.
    function refresh() {
        if (root.refreshing)
            return
        root.refreshing = true
        // Fetch only the current user's listings on the agent dashboard.
        if (PropertyViewModel) PropertyViewModel.getProperties(AppSettings.userId())
        if (RoomViewModel) RoomViewModel.loadRooms()
        // Also refresh the dashboard sections' data from their C++ view models.
        if (BookingViewModel) BookingViewModel.fetchBookings()
        if (NotificationViewModel)
            NotificationViewModel.getNotificationsByRole(Utils.notificationRoleForViewer())
        if (DisputesListViewModel) DisputesListViewModel.getDisputes()
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
        // Fetch only the current user's listings on the agent dashboard, plus
        // the dashboard sections' data (bookings, agent-scoped notifications,
        // disputes). Without this the bell badge keeps the previous screen's
        // count until the user manually pulls to refresh.
        if (PropertyViewModel) PropertyViewModel.getProperties(AppSettings.userId())
        if (RoomViewModel) RoomViewModel.loadRooms()
        if (BookingViewModel) BookingViewModel.fetchBookings()
        if (NotificationViewModel)
            NotificationViewModel.getNotificationsByRole(Utils.notificationRoleForViewer())
        if (DisputesListViewModel) DisputesListViewModel.getDisputes()
        root.refreshAll()
    }

    Connections {
        enabled: root.pageActive
        target: DraftViewModel
        function onDraftsChanged() { root.requestRefreshAll() }
    }

    Connections {
        enabled: root.pageActive
        target: PropertyViewModel
        function onIsLoadingChanged(loading) {
            root.loading = loading
            if (!loading)
                root.refreshing = false
            root.requestRefreshAll()
        }
    }

    Connections {
        enabled: root.pageActive
        target: PropertyViewModel ? PropertyViewModel.propertyListModel : null
        function onModelReset() { root.requestRefreshAll() }
        function onRowsInserted(parent, first, last) { root.requestRefreshAll() }
        function onRowsRemoved(parent, first, last) { root.requestRefreshAll() }
    }

    background: Rectangle { color: root.pageColor }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 96
        clip: true

        ScrollBar.vertical: AppScrollBar { }

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
            x: Math.max(12, (flick.width - width) / 2)
            y: 20
            width: flick.width > 48 ? Math.min(flick.width - 24, 520) : 520
            spacing: 14

            AgentsDashboardPage {
                Layout.fillWidth: true
                refreshAllowed: root.pageActive && root.scrollIdle

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

            ColumnLayout {
                visible: root.resultCount > 0
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: allPropertiesModel

                    delegate: AgentPropertyCardDelegate {
                        title: model.title
                        district: model.district
                        village: model.village
                        price: model.price
                        verificationStatus: model.verificationStatus
                        rejectionReason: model.rejectionReason
                        source: model.source
                        propertyId: model.propertyId
                        matches: model.matches
                        onOpened: (propertyId, source) => {
                            if (source === "draft") {
                                var d = DraftViewModel.getDraft(propertyId)
                                if (d) {
                                    d.draftKey = propertyId
                                    root.draftClicked(d)
                                }
                            } else {
                                root.propertyClicked(propertyId)
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

    // Centered non-blocking spinner shown while the server list (and the
    // embedded dashboard sections) are loading, mirroring the admin
    // dashboard's AppScrollablePage loader during first load and refresh.
    AppSpinner {
        visible: root.loading || root.refreshing
        anchors.centerIn: parent
        z: 20
        size: 32
        lineWidth: 3
        color: root.primaryColor
        running: root.loading || root.refreshing
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
