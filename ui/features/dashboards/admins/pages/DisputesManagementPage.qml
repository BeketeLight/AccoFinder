 import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../models"
import "../../../properties/components"
import "../delegates"

Item {
    id: root

    property AdminDisputesModel disputesModel: AdminDisputesModel {}
    property string pageTitle: qsTr("Disputes")

    signal disputeResolved(var disputeId)
    signal disputeRejected(var disputeId)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color mutedColor: "#6B7280"

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        StatSummaryBar {
            Layout.fillWidth: true
            model: [
                { value: String(root.disputesModel.openCount), label: qsTr("Open"), color: root.dangerColor },
                { value: String(root.disputesModel.inReviewCount), label: qsTr("In review"), color: root.warningColor },
                { value: String(root.disputesModel.resolvedCount), label: qsTr("Resolved"), color: root.successColor }
            ]
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { key: "ALL", label: qsTr("All") },
                    { key: "Open", label: qsTr("Open") },
                    { key: "In review", label: qsTr("In review") },
                    { key: "Resolved", label: qsTr("Resolved") },
                    { key: "Rejected", label: qsTr("Rejected") }
                ]

                delegate: Button {
                    id: filterPill
                    required property var model
                    readonly property bool isCurrent: root.disputesModel.statusFilter === filterPill.model.key
                    implicitHeight: 30
                    padding: 0

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: filterPill.model.label
                        color: parent.isCurrent ? "#FFFFFF" : "#374151"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 15
                        color: parent.isCurrent ? root.primaryColor : "#FFFFFF"
                        border.color: parent.isCurrent ? root.primaryColor : "#E5E7EB"
                    }

                    onClicked: {
                        root.disputesModel.statusFilter = filterPill.model.key
                        root.disputesModel.applyFilters()
                    }
                }
            }
        }

        Repeater {
            model: root.disputesModel.viewModel

            delegate: DisputeCardDelegate {
                disputeId: model.disputeId
                subject: model.subject
                propertyName: model.property
                client: model.client
                status: model.status
                opened: model.opened
                onReviewRequested: (disputeId, subject) => {
                    reviewDialog.disputeId = disputeId
                    reviewDialog.subject = subject
                    var d = root.disputesModel.findDispute(disputeId)
                    reviewDialog.detail = d ? d.detail : ""
                    reviewDialog.open()
                }
            }
        }

        Label {
            visible: root.disputesModel.viewModel.count === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No disputes in this view.")
            color: root.mutedColor
            font.pixelSize: 12
            topPadding: 8
        }
    }

    Dialog {
        id: reviewDialog
        modal: true
        width: Math.min(parent ? parent.width - 40 : 320, 360)
        anchors.centerIn: parent
        padding: 18

        property string disputeId: ""
        property string subject: ""
        property string detail: ""

        title: subject

        contentItem: ColumnLayout {
            spacing: 14

            Label {
                Layout.fillWidth: true
                text: reviewDialog.detail
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                color: "#374151"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: rejectDisputeButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Reject")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: rejectDisputeButton.text
                        color: "#B91C1C"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: rejectDisputeButton.down ? "#FEE2E2" : "#FEF2F2"
                        border.color: "#FECACA"
                        border.width: 1
                    }

                    onClicked: {
                        root.disputesModel.setStatus(reviewDialog.disputeId, "Rejected")
                        console.log("Dispute rejected:", reviewDialog.disputeId)
                        root.disputeRejected(reviewDialog.disputeId)
                        reviewDialog.close()
                    }
                }

                Button {
                    id: resolveDisputeButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: qsTr("Resolve")

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: resolveDisputeButton.text
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 8
                        color: resolveDisputeButton.down ? "#15803D" : root.successColor
                    }

                    onClicked: {
                        root.disputesModel.setStatus(reviewDialog.disputeId, "Resolved")
                        console.log("Dispute resolved:", reviewDialog.disputeId)
                        root.disputeResolved(reviewDialog.disputeId)
                        reviewDialog.close()
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
