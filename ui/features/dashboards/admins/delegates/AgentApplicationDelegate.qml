import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string applicationId: ""
    property string name: ""
    property string email: ""
    property string phone: ""
    property string area: ""
    property string appliedDate: ""
    property string status: ""

    property color primaryColor: "#2563EB"
    property color mutedColor: "#6B7280"

    signal viewRequested(var applicationId)

    Layout.fillWidth: true
    implicitHeight: cardContent.implicitHeight + 20
    radius: 12
    color: cardMouse.pressed ? "#F0F5FF" : "#FFFFFF"
    border.color: "#E5E7EB"
    border.width: 1

    ColumnLayout {
        id: cardContent
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
                implicitWidth: statusChipLabel.implicitWidth + 14
                radius: 10
                color: root.status === "Approved" ? "#ECFDF5"
                       : root.status === "Rejected" ? "#FEF2F2"
                       : "#FFFBEB"

                Label {
                    id: statusChipLabel
                    anchors.centerIn: parent
                    text: root.status
                    color: root.status === "Approved" ? "#166534"
                           : root.status === "Rejected" ? "#B91C1C"
                           : "#92400E"
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
                implicitWidth: areaChip.implicitWidth + 16
                radius: 11
                color: "#F3F4F6"

                Label {
                    id: areaChip
                    anchors.centerIn: parent
                    text: qsTr("Area: %1").arg(root.area)
                    color: "#374151"
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Rectangle {
                implicitHeight: 22
                implicitWidth: dateChip.implicitWidth + 16
                radius: 11
                color: "#F3F4F6"

                Label {
                    id: dateChip
                    anchors.centerIn: parent
                    text: qsTr("Applied: %1").arg(root.appliedDate)
                    color: "#374151"
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        RowLayout {
            visible: root.status === "Pending"
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            Rectangle {
                implicitHeight: 30
                implicitWidth: viewDetailsLabel.implicitWidth + 20
                radius: 15
                color: viewDetailsArea.pressed ? "#DBEAFE" : "#EFF6FF"
                border.color: "#BFDBFE"
                border.width: 1

                Label {
                    id: viewDetailsLabel
                    anchors.centerIn: parent
                    text: qsTr("View details  ›")
                    color: root.primaryColor
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    id: viewDetailsArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.viewRequested(root.applicationId)
                }
            }
        }
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: root.viewRequested(root.applicationId)
    }
}