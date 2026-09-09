import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../components/inputs"
import "../../models"
import "../../../properties/components"
import "../delegates"

Item {
    id: root

    property AdminUsersModel usersModel: AdminUsersModel {}

    signal userToggled(var userId, var name, var active)
    signal userRoleChanged(var userId, var name, var newRole)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

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
                    { key: "AGENT", label: qsTr("Agents") },
                    { key: "ADMIN", label: qsTr("Admins") }
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

        StatSummaryBar {
            Layout.fillWidth: true
            backgroundColor: "#EFF6FF"
            borderColor: "#BFDBFE"
            dividerColor: "#DBEAFE"
            model: [
                { value: String(root.usersModel.viewModel.count), label: qsTr("Shown"), color: "#1F2937" },
                { value: String(root.usersModel.activeCount), label: qsTr("Active"), color: "#16A34A" },
                { value: String(root.usersModel.suspendedCount), label: qsTr("Suspended"), color: "#DC2626" }
            ]
        }

        Repeater {
            model: root.usersModel.viewModel

            delegate: UserRowDelegate {
                name: model.name
                email: model.email
                joined: model.joined
                role: model.role
                userId: model.userId
                active: model.active
                busyUserId: root.usersModel.busyUserId
                onRoleChangeRequested: (userId, newRole) => {
                    console.log("ADMIN promote attempt:", userId,
                                "from", model.role, "to", newRole)
                    if (newRole !== model.role) {
                        root.usersModel.setUserRole(userId, newRole)
                        root.userRoleChanged(userId, model.name, newRole)
                    }
                }
                onToggleRequested: (userId, name, activate) => {
                    confirmDialog.userId = userId
                    confirmDialog.userName = name
                    confirmDialog.activate = activate
                    confirmDialog.open()
                }
                onForceClearBusyRequested: (userId) => {
                    if (root.usersModel.busyUserId === userId)
                        root.usersModel.busyUserId = ""
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
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.down ? "#1D4ED8" : "#2563EB"
                    }

                    onClicked: confirmDialog.reject()
                }

                Button {
                    id: confirmButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: confirmDialog.activate ? qsTr("Activate") : qsTr("Suspend")

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
                        color: confirmButton.down ? "#B91C1C" : (confirmDialog.activate ? "#16A34A" : "#DC2626")
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
