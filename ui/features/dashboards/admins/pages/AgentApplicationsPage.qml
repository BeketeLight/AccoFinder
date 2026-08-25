import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../models"

Item {
    id: root

    property string pageTitle: qsTr("Agent Applications")
    property AdminAgentApplicationsModel applicationsListModel: AdminAgentApplicationsModel {}

    signal viewApplicationRequested(var applicationId)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Pending applications")
        }

        Repeater {
            model: root.applicationsListModel.applicationsModel

            delegate: Rectangle {
                id: appCard
                required property var model
                required property int index
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
                                text: appCard.model.name.charAt(0)
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
                                text: appCard.model.name
                                color: "#111827"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: appCard.model.email + " · " + appCard.model.phone
                                color: root.mutedColor
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            implicitHeight: 20
                            implicitWidth: statusChipLabel.implicitWidth + 14
                            radius: 10
                            color: appCard.model.status === "Approved" ? "#ECFDF5"
                                   : appCard.model.status === "Rejected" ? "#FEF2F2"
                                   : "#FFFBEB"

                            Label {
                                id: statusChipLabel
                                anchors.centerIn: parent
                                text: appCard.model.status
                                color: appCard.model.status === "Approved" ? "#166534"
                                       : appCard.model.status === "Rejected" ? "#B91C1C"
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
                                text: qsTr("Area: %1").arg(appCard.model.area)
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
                                text: qsTr("Applied: %1").arg(appCard.model.appliedDate)
                                color: "#374151"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    RowLayout {
                        visible: appCard.model.status === "Pending"
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
                                onClicked: root.viewApplicationRequested(appCard.model.applicationId)
                            }
                        }
                    }
                }

                MouseArea {
                    id: cardMouse
                    anchors.fill: parent
                    z: -1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.viewApplicationRequested(appCard.model.applicationId)
                }
            }
        }

        Label {
            visible: root.applicationsListModel.applicationsModel.count === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No pending agent applications.")
            color: root.mutedColor
            font.pixelSize: 12
            topPadding: 8
        }
    }
}
