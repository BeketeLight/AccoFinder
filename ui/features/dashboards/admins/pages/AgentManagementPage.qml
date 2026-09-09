import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../../components/inputs"
import "../../models"
import "../delegates"

Item {
    id: root

    property AdminAgentsModel agentsModel: AdminAgentsModel {}
    property string pageTitle: qsTr("Agent Management")

    signal promoteAgentRequested()
    signal agentUpdated(var agentId)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    function openEditor(agent) {
        editDialog.agentId = agent.agentId
        editDialog.agentName = agent.name
        editAreaDropdown.currentIndex = ["Lilongwe", "Blantyre", "Mzuzu", "Zomba", "Kasungu", "Salima", "Mangochi"].indexOf(agent.area)
        editRateInput.text = String(agent.commissionRate)
        editError.text = ""
        editDialog.open()
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("Agents")
            }

            Button {
                id: newAgentButton
                Layout.preferredHeight: 32
                text: qsTr("+ Promote agent")

                contentItem: Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: newAgentButton.text
                    color: root.primaryColor
                    font.pixelSize: 12
                    font.bold: true
                }

                background: Rectangle {
                    radius: 16
                    color: newAgentButton.down ? "#DBEAFE" : "#EFF6FF"
                    border.color: "#BFDBFE"
                    border.width: 1
                }

                onClicked: root.promoteAgentRequested()
            }

            Button {
                id: commissionButton
                Layout.preferredHeight: 32
                text: qsTr("Set commission")

                contentItem: Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: commissionButton.text
                    color: root.warningColor
                    font.pixelSize: 12
                    font.bold: true
                }

                background: Rectangle {
                    radius: 16
                    color: commissionButton.down ? "#FEF3C7" : "#FFFBEB"
                    border.color: "#FDE68A"
                    border.width: 1
                }

                onClicked: commissionDialog.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            StatCard {
                Layout.fillWidth: true
                label: qsTr("Active agents")
                valueText: String(root.agentsModel.activeAgents)
                accentColor: root.successColor
            }

            StatCard {
                Layout.fillWidth: true
                lableFontSize: 18
                label: qsTr("Platform commission")
                valueText: (root.agentsModel.averageCommission > 0
                            ? Number(root.agentsModel.averageCommission).toFixed(1)
                            : "10") + "%"
                accentColor: root.warningColor
            }
        }

        Repeater {
            model: root.agentsModel.agentsModel

            delegate: AgentRowDelegate {
                agentId: model.agentId
                name: model.name
                email: model.email
                phone: model.phone
                area: model.area
                commissionRate: model.commissionRate
                active: model.active
                onEditRequested: (agentId) => root.openEditor(root.agentsModel.findAgent(agentId))
                onToggleRequested: (agentId, name, activate) => {
                    agentConfirmDialog.agentId = agentId
                    agentConfirmDialog.agentName = name
                    agentConfirmDialog.activate = activate
                    agentConfirmDialog.open()
                }
            }
        }
    }

    Dialog {
        id: agentConfirmDialog
        modal: true
        parent: Overlay.overlay
        width: Math.min(340, Overlay.overlay ? Overlay.overlay.width - 40 : 340)
        x: Overlay.overlay ? Math.round((Overlay.overlay.width - width) / 2) : 0
        y: Overlay.overlay ? Math.round((Overlay.overlay.height - height) / 2) : 0
        padding: 18

        property string agentId: ""
        property string agentName: ""
        property bool activate: false

        title: qsTr("%1 account").arg(agentName)

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: agentConfirmDialog.activate
                      ? qsTr("Reactivate %1's access to AccoFinder?").arg(agentConfirmDialog.agentName)
                      : qsTr("Suspend %1's access? They will be signed out and unable to sign in.").arg(agentConfirmDialog.agentName)
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                color: "#374151"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: agentConfirmCancelButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Cancel")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: agentConfirmCancelButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.down ? "#1D4ED8" : "#2563EB"
                    }

                    onClicked: agentConfirmDialog.reject()
                }

                Button {
                    id: agentConfirmButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: agentConfirmDialog.activate ? qsTr("Activate") : qsTr("Suspend")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: agentConfirmButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: agentConfirmButton.down ? "#B91C1C" : (agentConfirmDialog.activate ? "#16A34A" : "#DC2626")
                    }

                    onClicked: {
                        root.agentsModel.updateAgent(agentConfirmDialog.agentId, { active: agentConfirmDialog.activate })
                        console.log("Agent status:", agentConfirmDialog.agentId, "->", agentConfirmDialog.activate ? "ACTIVE" : "SUSPENDED")
                        root.agentUpdated(agentConfirmDialog.agentId)
                        agentConfirmDialog.accept()
                    }
                }
            }
        }

        background: Rectangle {
            radius: 14
            color: "#FFFFFF"
        }
    }

    Dialog {
        id: editDialog
        modal: true
        width: Math.min(parent ? parent.width - 40 : 320, 340)
        anchors.centerIn: parent
        padding: 18

        property string agentId: ""
        property string agentName: ""

        title: qsTr("Edit %1").arg(agentName)

        contentItem: ColumnLayout {
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label { text: qsTr("Assigned area"); font.pixelSize: 12; font.bold: true; color: "#1F2937" }

                AppDropdown {
                    id: editAreaDropdown
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    placeholder: qsTr("Select district")
                    model: ["Lilongwe", "Blantyre", "Mzuzu", "Zomba", "Kasungu", "Salima", "Mangochi"]
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label { text: qsTr("Commission rate (%)"); font.pixelSize: 12; font.bold: true; color: "#1F2937" }

                AppTextInput {
                    id: editRateInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    fieldHeight: 44
                    label: ""
                    placeholder: ""
                    fontPixelSize: 13
                    inputMethodHints: Qt.ImhDigitsOnly
                    backgroundColor: "#FFFFFF"
                    textColor: "#111827"
                    borderColor: "#E5E7EB"
                    focusColor: "#2563EB"
                    errorColor: "#DC2626"
                }

                Label { id: editError; visible: text.length > 0; text: ""; color: "#DC2626"; font.pixelSize: 11 }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: editCancelButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Cancel")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: editCancelButton.text
                        color: "#6B7280"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: editCancelButton.down ? "#F3F4F6" : "#FFFFFF"
                        border.color: "#E5E7EB"
                    }

                    onClicked: editDialog.reject()
                }

                Button {
                    id: editSaveButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Save")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: editSaveButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: editSaveButton.down ? "#1D4ED8" : "#2563EB"
                    }

                    onClicked: {
                        if (editAreaDropdown.currentIndex < 0) {
                            editError.text = qsTr("Select an assigned area")
                            return
                        }
                        var rate = parseFloat(editRateInput.text)
                        if (isNaN(rate) || rate <= 0 || rate > 50) {
                            editError.text = qsTr("Commission must be between 1 and 50")
                            return
                        }
                        root.agentsModel.updateAgent(editDialog.agentId, {
                            area: editAreaDropdown.currentText,
                            commissionRate: Math.round(rate)
                        })
                        console.log("Agent updated:", JSON.stringify(
                                        root.agentsModel.findAgent(editDialog.agentId)))
                        root.agentUpdated(editDialog.agentId)
                        editDialog.accept()
                    }
                }
            }
        }

        background: Rectangle {
            radius: 14
            color: "#FFFFFF"
        }
    }

    Dialog {
        id: commissionDialog
        modal: true
        width: Math.min(parent ? parent.width - 40 : 320, 340)
        anchors.centerIn: parent
        padding: 18

        title: qsTr("Set commission for all agents")

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: qsTr("This applies the same commission rate to every agent on the platform.")
                color: root.mutedColor
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label { text: qsTr("Commission rate (%)"); font.pixelSize: 12; font.bold: true; color: "#1F2937" }

                AppTextInput {
                    id: commissionRateInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    fieldHeight: 44
                    label: ""
                    placeholder: ""
                    text: root.agentsModel.agentsModel.count > 0
                          ? String(root.agentsModel.averageCommission)
                          : "10"
                    fontPixelSize: 13
                    inputMethodHints: Qt.ImhDigitsOnly
                    backgroundColor: "#FFFFFF"
                    textColor: "#111827"
                    borderColor: "#E5E7EB"
                    focusColor: "#2563EB"
                    errorColor: "#DC2626"
                }

                Label { id: commissionError; visible: text.length > 0; text: ""; color: "#DC2626"; font.pixelSize: 11 }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: commissionCancelButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Cancel")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: commissionCancelButton.text
                        color: "#6B7280"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: commissionCancelButton.down ? "#F3F4F6" : "#FFFFFF"
                        border.color: "#E5E7EB"
                    }

                    onClicked: commissionDialog.reject()
                }

                Button {
                    id: commissionSaveButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Apply to all")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: commissionSaveButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: commissionSaveButton.down ? "#B45309" : root.warningColor
                    }

                    onClicked: {
                        var rate = parseFloat(commissionRateInput.text)
                        if (isNaN(rate) || rate < 0 || rate > 100) {
                            commissionError.text = qsTr("Commission must be between 0 and 100")
                            return
                        }
                        root.agentsModel.setAllCommission(Math.round(rate))
                        commissionError.text = ""
                        commissionDialog.accept()
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
