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

    property var pendingRejectId: ""
    property var pendingRejectTitle: ""

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

    function confirmReject(propertyId, title) {
        pendingRejectId = propertyId
        pendingRejectTitle = title
        rejectReasonField.text = ""
        rejectError.visible = false
        rejectDialog.open()
    }

    function doReject() {
        var reason = rejectReasonField.text.trim()
        if (reason.length < 5) {
            rejectError.visible = true
            return
        }
        rejectError.visible = false
        root.listingsModel.setPropertyStatus(pendingRejectId, "REJECTED", reason)
        // Persist the decision (with the reason) on the backend so it survives a
        // refresh. setPropertyStatus only edits the local list.
        PropertyViewModel.updatePropertyStatus(pendingRejectId, "REJECTED", reason)
        console.log("Approval:", pendingRejectId, "-> REJECTED")
        root.decisionMade(pendingRejectId, pendingRejectTitle, false)
        root.refreshQueue()
        rejectDialog.close()
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
                                // Persist the decision on the backend so it survives a
                                // refresh. setPropertyStatus only edits the local list.
                                PropertyViewModel.updatePropertyStatus(approvalRow.model.propertyId, "VERIFIED")
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

                            onClicked: root.confirmReject(approvalRow.model.propertyId, approvalRow.model.title)
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
            font.pixelSize: 12
            topPadding: 10
        }
    }

    Dialog {
        id: rejectDialog
        modal: true
        width: Math.min(parent ? parent.width - 40 : 320, 360)
        anchors.centerIn: parent
        padding: 18
        title: qsTr("Reject property")

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                Layout.fillWidth: true
                text: qsTr("Tell the agent what to fix so they can resubmit.")
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: "#374151"
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: rejectReasonField.implicitHeight + 20
                radius: 8
                color: "#FFFFFF"
                border.color: rejectReasonField.activeFocus || rejectError.visible ? root.primaryColor
                                      : "#E5E7EB"
                border.width: rejectReasonField.activeFocus || rejectError.visible ? 2 : 1

                TextArea {
                    id: rejectReasonField
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    placeholderText: qsTr("Reason for rejection...")
                    wrapMode: TextArea.Wrap
                    font.pixelSize: 12
                    color: "#111827"
                    background: Item {}
                    onTextChanged: {
                        rejectError.visible = false
                    }
                }
            }

            Label {
                id: rejectError
                visible: false
                Layout.fillWidth: true
                text: qsTr("Add a reason (at least a few words) so the agent can fix it.")
                color: root.dangerColor
                font.pixelSize: 11
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Cancel")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Cancel")
                        color: "#111827"
                        font.pixelSize: 13
                    }

                    background: Rectangle {
                        radius: 8
                        color: "#FFFFFF"
                        border.color: "#E5E7EB"
                        border.width: 1
                    }

                    onClicked: rejectDialog.reject()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Reject")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Reject")
                        color: "#B91C1C"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: "#FEF2F2"
                        border.color: "#FECACA"
                        border.width: 1
                    }

                    onClicked: root.doReject()
                }
            }
        }
    }
}
