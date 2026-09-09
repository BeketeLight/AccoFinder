import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../components/indicators"

Rectangle {
    id: root

    property string name: ""
    property string email: ""
    property string joined: ""
    property string role: ""
    property string userId: ""
    property bool active: false
    property var busyUserId: ""

    signal roleChangeRequested(var userId, var newRole)
    signal toggleRequested(var userId, var name, var activate)
    signal forceClearBusyRequested(var userId)

    function roleColor(role) {
        if (role === "ADMIN") return "#7C3AED"
        if (role === "AGENT") return "#2563EB"
        return "#16A34A"
    }

    readonly property string roleTint: root.roleColor(root.role)
    readonly property bool isSelfAccount: String(root.userId) === String(AppSettings.userId())

    Layout.fillWidth: true
    implicitHeight: cardColumn.implicitHeight + 20
    radius: 12
    color: "#FFFFFF"
    border.color: "#E5E7EB"
    border.width: 1

    ColumnLayout {
        id: cardColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 19
                color: "#EFF6FF"

                Label {
                    anchors.centerIn: parent
                    text: root.name.length > 0 ? root.name.charAt(0) : ""
                    color: root.roleTint
                    font.pixelSize: 15
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    Layout.fillWidth: true
                    text: root.name
                    color: "#111827"
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: root.email + " · " + root.joined
                    color: "#6B7280"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                implicitHeight: 24
                implicitWidth: roleCombo.width + 14
                radius: 12
                color: "#F3F4F6"
                border.color: roleCombo.activeFocus ? "#2563EB" : "#E5E7EB"

                // Inline per-card loader shown while the role-change
                // PATCH is in flight, so the user sees progress on the
                // affected row without a page-wide overlay.
                AppSpinner {
                    id: roleBusy
                    // Show the per-card loader only while a genuine
                    // role-change request is in flight: the card is
                    // flagged busy AND the C++ UserViewModel is
                    // actively loading. On page load, loading is
                    // false by the time data renders, so the loader
                    // can never appear spuriously.
                    visible: root.busyUserId === root.userId
                             && UserViewModel.isLoading
                    anchors.centerIn: parent
                    size: 16
                    lineWidth: 2
                    color: "#2563EB"
                    running: visible

                    // Safety net: never let the loader spin forever.
                    // If busyUserId isn't cleared (a request that
                    // hangs or errors without a signal), force-clear
                    // it shortly after it appears.
                    Timer {
                        interval: 6000
                        running: roleBusy.visible
                        onTriggered: {
                            if (root.busyUserId === root.userId)
                                root.forceClearBusyRequested(root.userId)
                        }
                    }
                }

                ComboBox {
                    id: roleCombo
                    anchors.centerIn: parent
                    visible: !roleBusy.visible
                    width: 96
                    height: 20
                    // The signed-in admin must not edit their own
                    // role (avoids demoting yourself out of the
                    // dashboard). Everyone else can be set to any
                    // role, including promoted to ADMIN.
                    enabled: !roleBusy.visible && !root.isSelfAccount
                    font.pixelSize: 10
                    model: ["CLIENT", "AGENT", "ADMIN"]
                    currentIndex: {
                        var r = root.role
                        if (r === "AGENT") return 1
                        if (r === "ADMIN") return 2
                        return 0
                    }
                    // Use onActivated (fires only on real user selection)
                    // rather than onCurrentIndexChanged, which also fires
                    // when the currentIndex binding initialises a card and
                    // would otherwise fire a spurious role-change PATCH.
                    onActivated: function (index) {
                        var newRole = roleCombo.currentText
                        root.roleChangeRequested(root.userId, newRole)
                    }
                    contentItem: Label {
                        text: roleCombo.displayText
                        color: root.roleColor(root.role)
                        font.pixelSize: 10
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    background: Rectangle {
                        radius: 10
                        color: roleCombo.pressed ? "#E5E7EB" : "transparent"
                    }

                    popup: Popup {
                        id: rolePopup
                        width: 108
                        padding: 4
                        modal: true
                        focus: true

                        // popup.x / popup.y are relative to the combo, so
                        // opening below means y = combo.height + 4 (the
                        // original behaviour). For the row that sits at the
                        // very bottom of the screen we flip the list to open
                        // above the combo so it never extends past the window
                        // edge into the Android system bottom nav bar. The
                        // flip decision is made in window coordinates.
                        function openHeight() {
                            var h = 8 // padding top + bottom
                            var m = roleCombo.delegateModel
                            var rows = (m && m.count) ? m.count : 2
                            return h + rows * 30
                        }
                        function place() {
                            var win = roleCombo.Window.contentItem
                            var bottom = roleCombo.mapToItem(win, 0, roleCombo.height)
                            if (win && bottom.y + 4 + rolePopup.openHeight() > win.height - 4) {
                                rolePopup.y = -rolePopup.openHeight() - 4
                            } else {
                                rolePopup.y = roleCombo.height + 4
                            }
                        }
                        onAboutToShow: rolePopup.place()

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: roleCombo.popup.visible ? roleCombo.delegateModel : null
                            currentIndex: roleCombo.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator {}
                        }

                        background: Rectangle {
                            radius: 8
                            color: "#FFFFFF"
                            border.color: "#E5E7EB"
                            border.width: 1
                        }
                    }

                    delegate: ItemDelegate {
                        width: roleCombo.popup.width - 8
                        height: 30

                        contentItem: Label {
                            text: modelData
                            color: "#374151"
                            font.pixelSize: 11
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            leftPadding: 8
                        }

                        background: Rectangle {
                            radius: 6
                            color: highlighted ? "#EFF6FF" : "transparent"
                        }
                    }
                }
            }

            Rectangle {
                implicitHeight: 18
                implicitWidth: stateLabel.implicitWidth + 14
                radius: 9
                color: root.active ? "#ECFDF5" : "#FEF2F2"

                Label {
                    id: stateLabel
                    anchors.centerIn: parent
                    text: root.active ? qsTr("Active") : qsTr("Suspended")
                    color: root.active ? "#166534" : "#B91C1C"
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Rectangle {
                id: togglePill
                implicitHeight: 24
                implicitWidth: toggleLabel.implicitWidth + 20
                radius: 12
                color: toggleArea.pressed
                       ? (root.active ? "#FEE2E2" : "#DCFCE7")
                       : (root.active ? "#FEF2F2" : "#F0FDF4")
                border.color: root.active ? "#FECACA" : "#BBF7D0"
                border.width: 1

                Label {
                    id: toggleLabel
                    anchors.centerIn: parent
                    text: root.active ? qsTr("Suspend") : qsTr("Activate")
                    color: root.active ? "#B91C1C" : "#166534"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    id: toggleArea
                    anchors.fill: parent
                    onClicked: root.toggleRequested(root.userId, root.name, !root.active)
                }
            }
        }
    }
}