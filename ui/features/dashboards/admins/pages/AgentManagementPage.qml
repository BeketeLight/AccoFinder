import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../../components/inputs"
import "../../models"

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
                label: qsTr("Average commission")
                valueText: Number(root.agentsModel.averageCommission).toFixed(1) + "%"
                accentColor: root.warningColor
            }
        }

        Repeater {
            model: root.agentsModel.agentsModel

            delegate: Rectangle {
                id: agentRow
                required property var model
                required property int index
                Layout.fillWidth: true
                implicitHeight: agentContent.implicitHeight + 20
                radius: 12
                color: "#FFFFFF"
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    id: agentContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
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
                                text: agentRow.model.name.charAt(0)
                                color: root.primaryColor
                                font.pixelSize: 15
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                Layout.fillWidth: true
                                text: agentRow.model.name
                                color: "#111827"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: agentRow.model.email + " · " + agentRow.model.phone
                                color: root.mutedColor
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            implicitHeight: 20
                            implicitWidth: stateChipLabel.implicitWidth + 14
                            radius: 10
                            color: agentRow.model.active ? "#ECFDF5" : "#FEF2F2"

                            Label {
                                id: stateChipLabel
                                anchors.centerIn: parent
                                text: agentRow.model.active ? qsTr("Active") : qsTr("Suspended")
                                color: agentRow.model.active ? "#166534" : "#B91C1C"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            implicitHeight: 22
                            implicitWidth: areaChipLabel.implicitWidth + 16
                            radius: 11
                            color: "#F3F4F6"

                            Label {
                                id: areaChipLabel
                                anchors.centerIn: parent
                                text: qsTr("Area: %1").arg(agentRow.model.area)
                                color: "#374151"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        Rectangle {
                            implicitHeight: 22
                            implicitWidth: rateChipLabel.implicitWidth + 16
                            radius: 11
                            color: "#FEF3C7"

                            Label {
                                id: rateChipLabel
                                anchors.centerIn: parent
                                text: qsTr("%1% commission").arg(agentRow.model.commissionRate)
                                color: "#92400E"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        Rectangle {
                            id: editAgentButton
                            implicitHeight: 24
                            implicitWidth: editLabel.implicitWidth + 20
                            radius: 12
                            color: editArea.pressed ? "#DBEAFE" : "#EFF6FF"
                            border.color: "#BFDBFE"
                            border.width: 1

                            Label {
                                id: editLabel
                                anchors.centerIn: parent
                                text: qsTr("Edit")
                                color: root.primaryColor
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                id: editArea
                                anchors.fill: parent
                                onClicked: root.openEditor(root.agentsModel.findAgent(agentRow.model.agentId))
                            }
                        }

                        Rectangle {
                            id: toggleAgentButton
                            implicitHeight: 24
                            implicitWidth: agentToggleLabel.implicitWidth + 20
                            radius: 12
                            color: agentToggleArea.pressed
                                   ? (agentRow.model.active ? "#FEE2E2" : "#DCFCE7")
                                   : (agentRow.model.active ? "#FEF2F2" : "#F0FDF4")
                            border.color: agentRow.model.active ? "#FECACA" : "#BBF7D0"
                            border.width: 1

                            Label {
                                id: agentToggleLabel
                                anchors.centerIn: parent
                                text: agentRow.model.active ? qsTr("Suspend") : qsTr("Activate")
                                color: agentRow.model.active ? "#B91C1C" : "#166534"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                id: agentToggleArea
                                anchors.fill: parent

                                onClicked: {
                                    var newState = !agentRow.model.active
                                    root.agentsModel.updateAgent(agentRow.model.agentId, { active: newState })
                                    console.log("Agent status:", agentRow.model.agentId, "->", newState ? "ACTIVE" : "SUSPENDED")
                                    root.agentUpdated(agentRow.model.agentId)
                                }
                            }
                        }
                    }
                }
            }
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

                TextField {
                    id: editRateInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    font.pixelSize: 13
                    inputMethodHints: Qt.ImhDigitsOnly
                    background: Rectangle {
                        radius: 8
                        border.color: editRateInput.activeFocus ? "#2563EB" : "#E5E7EB"
                        border.width: 1
                    }
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

                TextField {
                    id: commissionRateInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    font.pixelSize: 13
                    text: root.agentsModel.agentsModel.count > 0
                          ? String(root.agentsModel.averageCommission)
                          : "10"
                    inputMethodHints: Qt.ImhDigitsOnly
                    background: Rectangle {
                        radius: 8
                        border.color: commissionRateInput.activeFocus ? "#2563EB" : "#E5E7EB"
                        border.width: 1
                    }
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
