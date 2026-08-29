import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/models"
import "../../../properties/components"
import "../../../../utils/Utils.js" as Utils

Item {
    id: root

    property MyPropertiesModel listingsModel: MyPropertiesModel {}

    signal decisionMade(var propertyId, var title, var approved)
    signal reviewRequested(var propertyId)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color dangerColor: "#DC2626"

    function refreshQueue() {
        queueModel.clear()
        for (var i = 0; i < root.listingsModel.propertiesModel.count; i++) {
            var p = root.listingsModel.propertiesModel.get(i)
            if (String(p.status || "").toUpperCase() !== "PENDING")
                continue
            queueModel.append({
                propertyId: p.propertyId,
                title: p.title,
                district: p.district,
                village: p.village,
                price: p.price,
                landlord: p.landlord
            })
        }
        emptyState.visible = queueModel.count === 0
    }

    ListModel { id: queueModel }

    // The shared property model is populated asynchronously after the network
    // fetch resolves. Rebuild the queue whenever it changes so newly fetched
    // PENDING listings actually appear (instead of only at Component.onCompleted).
    Connections {
        target: root.listingsModel.propertiesModel
        function onCountChanged() { root.refreshQueue() }
    }

    Component.onCompleted: refreshQueue()

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
                title: qsTr("Verification queue")
            }

            Rectangle {
                implicitHeight: 24
                implicitWidth: countLabel.implicitWidth + 16
                radius: 12
                color: "#FFFBEB"

                Label {
                    id: countLabel
                    anchors.centerIn: parent
                    text: String(queueModel.count)
                    color: "#B45309"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }

        Repeater {
            model: queueModel

            delegate: Rectangle {
                id: approvalRow
                required property var model
                required property int index
                Layout.fillWidth: true
                implicitHeight: approvalContent.implicitHeight + 20
                radius: 12
                color: "#FFFFFF"
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    id: approvalContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        Layout.fillWidth: true
                        text: approvalRow.model.title
                        color: "#111827"
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: approvalRow.model.district + " · " + approvalRow.model.village
                              + " · " + Utils.formatCurrency(approvalRow.model.price) + "/mo"
                        color: "#6B7280"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Landlord: %1").arg(approvalRow.model.landlord)
                        color: "#6B7280"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Button {
                        id: reviewButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        text: qsTr("Review & decide")

                        contentItem: Label {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: reviewButton.text
                            color: "#2563EB"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        background: Rectangle {
                            radius: 19
                            color: reviewButton.down ? "#DBEAFE" : "#EFF6FF"
                            border.color: "#BFDBFE"
                            border.width: 1
                        }

                        onClicked: root.reviewRequested(approvalRow.model.propertyId)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            id: approveButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            text: qsTr("Approve")

                            contentItem: Label {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: approveButton.text
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                font.bold: true
                            }

                            background: Rectangle {
                                radius: 18
                                color: approveButton.down ? "#15803D" : root.successColor
                            }

                            onClicked: {
                                root.listingsModel.setPropertyStatus(approvalRow.model.propertyId, "VERIFIED")
                                console.log("Approval:", approvalRow.model.propertyId, "-> VERIFIED")
                                root.decisionMade(approvalRow.model.propertyId, approvalRow.model.title, true)
                                root.refreshQueue()
                            }
                        }

                        Button {
                            id: rejectButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            text: qsTr("Reject")

                            contentItem: Label {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: rejectButton.text
                                color: "#B91C1C"
                                font.pixelSize: 12
                                font.bold: true
                            }

                            background: Rectangle {
                                radius: 18
                                color: rejectButton.down ? "#FEE2E2" : "#FEF2F2"
                                border.color: "#FECACA"
                                border.width: 1
                            }

                            onClicked: {
                                root.listingsModel.setPropertyStatus(approvalRow.model.propertyId, "REJECTED")
                                console.log("Approval:", approvalRow.model.propertyId, "-> REJECTED")
                                root.decisionMade(approvalRow.model.propertyId, approvalRow.model.title, false)
                                root.refreshQueue()
                            }
                        }
                    }
                }
            }
        }

        Label {
            id: emptyState
            visible: false
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No properties waiting for verification.")
            color: "#6B7280"
            font.pixelSize: 12
            topPadding: 10
        }
    }
}
