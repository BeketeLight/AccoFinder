import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../models"
import "../../../../components/inputs"
import "../../../../components/indicators"

Item {
    id: root

    property AdminUsersModel usersModel: AdminUsersModel {}

    signal userToggled(var userId, var name, var active)
    signal userRoleChanged(var userId, var name, var newRole)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    function roleColor(role) {
        if (role === "AGENT") return "#2563EB"
        return "#16A34A"
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            AppSearchBar {
                Layout.fillWidth: true
                placeholder: qsTr("Search name or email")
                backgroundColor: "#FFFFFF"
                focusColor: "#2563EB"
                fieldHeight: 48
                text: root.usersModel.searchQuery
                onTextEdited: {
                    root.usersModel.searchQuery = text
                    root.usersModel.applyFilters()
                }
                onCleared: {
                    root.usersModel.searchQuery = ""
                    root.usersModel.applyFilters()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { key: "ALL", label: qsTr("All") },
                    { key: "CLIENT", label: qsTr("Clients") },
                    { key: "AGENT", label: qsTr("Agents") }
                ]

                delegate: Button {
                    required property var model
                    readonly property bool isCurrent: root.usersModel.roleFilter === model.key
                    Layout.preferredHeight: 30
                    padding: 0

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: model.label
                        color: parent.isCurrent ? "#FFFFFF" : "#374151"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 15
                        color: parent.isCurrent ? "#2563EB" : (parent.hovered ? "#EFF6FF" : "#FFFFFF")
                        border.color: parent.isCurrent ? "#2563EB" : "#E5E7EB"
                    }

                    onClicked: {
                        root.usersModel.roleFilter = model.key
                        root.usersModel.applyFilters()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: summaryRow.implicitHeight + 24
            radius: 12
            color: "#EFF6FF"
            border.color: "#BFDBFE"
            border.width: 1

            RowLayout {
                id: summaryRow
                anchors.fill: parent
                anchors.margins: 12
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.usersModel.viewModel.count)
                        font.pixelSize: 17
                        font.bold: true
                        color: "#1F2937"
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Shown")
                        font.pixelSize: 11
                        color: "#6B7280"
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: parent.height - 24; color: "#DBEAFE" }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.usersModel.activeCount)
                        font.pixelSize: 17
                        font.bold: true
                        color: "#16A34A"
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Active")
                        font.pixelSize: 11
                        color: "#6B7280"
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: parent.height - 24; color: "#DBEAFE" }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.usersModel.suspendedCount)
                        font.pixelSize: 17
                        font.bold: true
                        color: "#DC2626"
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Suspended")
                        font.pixelSize: 11
                        color: "#6B7280"
                    }
                }
            }
        }

        Repeater {
            model: root.usersModel.viewModel

            delegate: Rectangle {
                id: userCard
                required property var model
                required property int index
                readonly property string roleTint: root.roleColor(model.role)
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
                                text: userCard.model.name.charAt(0)
                                color: userCard.roleTint
                                font.pixelSize: 15
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: userCard.model.name
                                color: "#111827"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: userCard.model.email + " · " + userCard.model.joined
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
                                visible: root.usersModel.busyUserId === userCard.model.userId
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
                                        if (root.usersModel.busyUserId === userCard.model.userId)
                                            root.usersModel.busyUserId = ""
                                    }
                                }
                            }

                            ComboBox {
                                id: roleCombo
                                anchors.centerIn: parent
                                visible: !roleBusy.visible
                                width: 86
                                height: 20
                                enabled: !roleBusy.visible
                                font.pixelSize: 10
                                model: ["CLIENT", "AGENT"]
                                currentIndex: {
                                    var r = userCard.model.role
                                    if (r === "AGENT") return 1
                                    return 0
                                }
                                // Use onActivated (fires only on real user selection)
                                // rather than onCurrentIndexChanged, which also fires
                                // when the currentIndex binding initialises a card and
                                // would otherwise fire a spurious role-change PATCH.
                                onActivated: function (index) {
                                    var newRole = roleCombo.currentText
                                    console.log("ADMIN promote attempt:", userCard.model.userId,
                                                "from", userCard.model.role, "to", newRole)
                                    if (newRole !== userCard.model.role) {
                                        root.usersModel.setUserRole(userCard.model.userId, newRole)
                                        root.userRoleChanged(userCard.model.userId, userCard.model.name, newRole)
                                    }
                                }
                                contentItem: Label {
                                    text: roleCombo.displayText
                                    color: root.roleColor(userCard.model.role)
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
                            color: userCard.model.active ? "#ECFDF5" : "#FEF2F2"

                            Label {
                                id: stateLabel
                                anchors.centerIn: parent
                                text: userCard.model.active ? qsTr("Active") : qsTr("Suspended")
                                color: userCard.model.active ? "#166534" : "#B91C1C"
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
                                   ? (userCard.model.active ? "#FEE2E2" : "#DCFCE7")
                                   : (userCard.model.active ? "#FEF2F2" : "#F0FDF4")
                            border.color: userCard.model.active ? "#FECACA" : "#BBF7D0"
                            border.width: 1

                            Label {
                                id: toggleLabel
                                anchors.centerIn: parent
                                text: userCard.model.active ? qsTr("Suspend") : qsTr("Activate")
                                color: userCard.model.active ? "#B91C1C" : "#166534"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                id: toggleArea
                                anchors.fill: parent
                                onClicked: {
                                    confirmDialog.userId = userCard.model.userId
                                    confirmDialog.userName = userCard.model.name
                                    confirmDialog.activate = !userCard.model.active
                                    confirmDialog.open()
                                }
                            }
                        }
                    }
                }
            }
        }

        Label {
            visible: root.usersModel.viewModel.count === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No accounts match this view.")
            color: "#6B7280"
            font.pixelSize: 12
            topPadding: 8
        }
    }

    Dialog {
        id: confirmDialog
        modal: true
        parent: Overlay.overlay
        width: Math.min(340, Overlay.overlay ? Overlay.overlay.width - 40 : 340)
        x: Overlay.overlay ? Math.round((Overlay.overlay.width - width) / 2) : 0
        y: Overlay.overlay ? Math.round((Overlay.overlay.height - height) / 2) : 0
        padding: 18

        property string userName: ""
        property string userId: ""
        property bool activate: false

        title: qsTr("%1 account").arg(userName)

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: confirmDialog.activate
                      ? qsTr("Reactivate %1's access to AccoFinder?").arg(confirmDialog.userName)
                      : qsTr("Suspend %1's access? They will be signed out and unable to sign in.").arg(confirmDialog.userName)
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                color: "#374151"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: cancelButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Cancel")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: cancelButton.text
                        color: "#6B7280"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.down ? "#F3F4F6" : "#FFFFFF"
                        border.color: "#E5E7EB"
                    }

                    onClicked: confirmDialog.reject()
                }

                Button {
                    id: confirmButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: confirmDialog.activate ? qsTr("Activate") : qsTr("Deactivate")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: confirmButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: confirmButton.down ? "#1D4ED8" : "#2563EB"
                    }

                    onClicked: {
                        root.usersModel.setAccountActive(confirmDialog.userId, confirmDialog.activate)
                        root.userToggled(confirmDialog.userId, confirmDialog.userName, confirmDialog.activate)
                        console.log("Admin account action:", confirmDialog.userId,
                                    confirmDialog.userName, "->", confirmDialog.activate ? "ACTIVE" : "SUSPENDED")
                        confirmDialog.accept()
                    }
                }
            }
        }

        background: Rectangle {
            radius: 14
            color: "#FFFFFF"
        }
    }
}
