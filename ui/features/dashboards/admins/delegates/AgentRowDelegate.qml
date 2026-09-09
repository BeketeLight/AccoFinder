import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string agentId: ""
    property string name: ""
    property string email: ""
    property string phone: ""
    property string area: ""
    property var commissionRate: 0
    property bool active: false

    property color primaryColor: "#2563EB"
    property color mutedColor: "#6B7280"

    signal editRequested(var agentId)
    signal toggleRequested(var agentId, var name, var activate)

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
                    text: root.name.length > 0 ? root.name.charAt(0) : ""
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
                    text: root.name
                    color: "#111827"
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: root.email + " · " + root.phone
                    color: root.mutedColor
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                implicitHeight: 20
                implicitWidth: stateChipLabel.implicitWidth + 14
                radius: 10
                color: root.active ? "#ECFDF5" : "#FEF2F2"

                Label {
                    id: stateChipLabel
                    anchors.centerIn: parent
                    text: root.active ? qsTr("Active") : qsTr("Suspended")
                    color: root.active ? "#166534" : "#B91C1C"
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
                    text: qsTr("Area: %1").arg(root.area)
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
                    text: qsTr("%1% commission").arg(root.commissionRate)
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
                    onClicked: root.editRequested(root.agentId)
                }
            }

            Rectangle {
                id: toggleAgentButton
                implicitHeight: 24
                implicitWidth: agentToggleLabel.implicitWidth + 20
                radius: 12
                color: agentToggleArea.pressed
                       ? (root.active ? "#FEE2E2" : "#DCFCE7")
                       : (root.active ? "#FEF2F2" : "#F0FDF4")
                border.color: root.active ? "#FECACA" : "#BBF7D0"
                border.width: 1

                Label {
                    id: agentToggleLabel
                    anchors.centerIn: parent
                    text: root.active ? qsTr("Suspend") : qsTr("Activate")
                    color: root.active ? "#B91C1C" : "#166534"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    id: agentToggleArea
                    anchors.fill: parent
                    onClicked: root.toggleRequested(root.agentId, root.name, !root.active)
                }
            }
        }
    }
}