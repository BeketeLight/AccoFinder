import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../../../components/inputs"
import "../../../components/indicators"

Item {
    id: root

    readonly property color pageColor: "#F8FAFC"
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    signal addPropertyRequested()
    signal propertyClicked(var propertyId)
    signal draftClicked(var payload)

    // Selected filter chip: All / Verified / Pending / Draft / Rejected
    property string statusFilter: "All"
    property string searchText: ""
    property int resultCount: 0
    property int serverCount: 0
    property bool loading: false
    property bool refreshing: false

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
        var haveAny = root.serverCount > 0 || DraftViewModel.count > 0
        emptyServerState.visible = !root.loading && !haveAny
        noMatchState.visible = !root.loading && haveAny && count === 0
    }

    function payloadForId(propertyId) {
        for (var i = 0; i < allPropertiesModel.count; i++) {
            var r = allPropertiesModel.get(i)
            if (r.source === "draft")
                continue
            if (String(r.propertyId) === String(propertyId)) {
                return {
                    title: r.title,
                    district: r.district,
                    village: r.village,
                    price: r.price,
                    verificationStatus: r.verificationStatus,
                    propertyId: r.propertyId
                }
            }
        }
        return null
    }

    function refreshAll() {
        allPropertiesModel.clear()

        // "My properties" must show only the current user's own listings. The
        // backend is asked for owner-scoped rows (?owner=userId), but as a
        // second layer of defence we also filter here by the parsed
        // owner/agentId — the shared C++ PropertyViewModel can be refreshed by
        // other screens (admin, etc.) and must not leak another user's listings
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

    function refresh() {
        if (root.refreshing)
            return
        root.refreshing = true
        // Fetch only the current user's listings.
        PropertyViewModel.getProperties(AppSettings.userId())
        BookingViewModel.fetchBookings()
        NotificationViewModel.getNotifications()
        DisputesListViewModel.getDisputes()
    }

    property bool pullArmed: false

    function armIfPulled() {
        if (flick.dragging && flick.contentY <= -56)
            root.pullArmed = true
    }

    function handlePullRelease() {
        if (root.pullArmed && !root.refreshing) {
            root.refresh()
            flick.returnToBounds()
        }
        root.pullArmed = false
    }

    Component.onCompleted: {
        filterChipsModel.append([{ label: "All" }, { label: "Verified" },
                                 { label: "Pending" }, { label: "Draft" },
                                 { label: "Rejected" }])
        PropertyViewModel.getProperties(AppSettings.userId())
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
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 120
        clip: true

        ScrollBar.vertical: ScrollBar { }

        onContentYChanged: root.armIfPulled()
        onDragEnded: root.handlePullRelease()

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
            y: 0
            width: Math.min(flick.width - 32, 560)
            spacing: 14

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
