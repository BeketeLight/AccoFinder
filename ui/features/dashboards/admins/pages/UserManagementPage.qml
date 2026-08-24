import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../models"

Item {
    id: root

    property AdminUsersModel usersModel: AdminUsersModel {}

    signal userToggled(var userId, var name, var active)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    function roleColor(role) {
        if (role === "AGENT") return "#2563EB"
        if (role === "LANDLORD") return "#D97706"
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

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 30
                radius: 15
                color: "#FFFFFF"
                border.color: searchField.activeFocus ? "#2563EB" : "#E5E7EB"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 6

                    Text { text: "⌕"; color: "#9CA3AF"; font.pixelSize: 15 }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Search name or email")
                        font.pixelSize: 13
                        background: null
                        onTextChanged: {
                            root.usersModel.searchQuery = text
                            root.usersModel.applyFilters()
                        }
                    }
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
                    { key: "LANDLORD", label: qsTr("Landlords") }
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
                            implicitHeight: 18
                            implicitWidth: roleLabel.implicitWidth + 14
                            radius: 9
                            color: "#F3F4F6"

                            Label {
                                id: roleLabel
                                anchors.centerIn: parent
                                text: userCard.model.role
                                color: userCard.roleTint
                                font.pixelSize: 10
                                font.bold: true
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
        width: Math.min(parent ? parent.width - 40 : 320, 340)
        anchors.centerIn: parent
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
