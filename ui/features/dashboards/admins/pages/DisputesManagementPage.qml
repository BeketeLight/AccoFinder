import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../models"

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

    function statusVariant(status) {
        if (status === "Resolved") return "success"
        if (status === "In review") return "warning"
        if (status === "Open") return "danger"
        return "neutral"
    }

    function tintBg(variant) {
        if (variant === "success") return "#ECFDF5"
        if (variant === "warning") return "#FFFBEB"
        if (variant === "danger") return "#FEF2F2"
        return "#F3F4F6"
    }

    function tintFg(variant) {
        if (variant === "success") return "#166534"
        if (variant === "warning") return "#92400E"
        if (variant === "danger") return "#B91C1C"
        return "#6B7280"
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: summaryRow.implicitHeight + 24
            radius: 12
            color: "#FFFFFF"
            border.color: "#E5E7EB"
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
                        text: String(root.disputesModel.openCount)
                        font.pixelSize: 17
                        font.bold: true
                        color: root.dangerColor
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Open")
                        font.pixelSize: 11
                        color: root.mutedColor
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: parent.height - 24; color: "#E5E7EB" }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.disputesModel.inReviewCount)
                        font.pixelSize: 17
                        font.bold: true
                        color: root.warningColor
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("In review")
                        font.pixelSize: 11
                        color: root.mutedColor
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: parent.height - 24; color: "#E5E7EB" }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.disputesModel.resolvedCount)
                        font.pixelSize: 17
                        font.bold: true
                        color: root.successColor
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Resolved")
                        font.pixelSize: 11
                        color: root.mutedColor
                    }
                }
            }
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

            delegate: Rectangle {
                id: disputeCard
                required property var model
                required property int index
                readonly property string variant: root.statusVariant(model.status)
                Layout.fillWidth: true
                implicitHeight: cardRow.implicitHeight + 20
                radius: 12
                color: "#FFFFFF"
                border.color: "#E5E7EB"
                border.width: 1

                RowLayout {
                    id: cardRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        radius: 19
                        color: root.tintBg(disputeCard.variant)

                        Label {
                            anchors.centerIn: parent
                            text: disputeCard.model.client.charAt(0)
                            color: root.tintFg(disputeCard.variant)
                            font.pixelSize: 15
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Label {
                            Layout.fillWidth: true
                            text: disputeCard.model.subject
                            color: "#111827"
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: disputeCard.model.property + " · " + disputeCard.model.client
                            color: root.mutedColor
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            spacing: 6

                            Rectangle {
                                implicitHeight: 18
                                implicitWidth: chipLabel.implicitWidth + 14
                                radius: 9
                                color: root.tintBg(disputeCard.variant)

                                Label {
                                    id: chipLabel
                                    anchors.centerIn: parent
                                    text: disputeCard.model.status
                                    color: root.tintFg(disputeCard.variant)
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            Label {
                                text: disputeCard.model.opened
                                color: "#9CA3AF"
                                font.pixelSize: 10
                            }
                        }
                    }

                    Button {
                        id: reviewButton
                        visible: disputeCard.model.status === "Open" || disputeCard.model.status === "In review"
                        Layout.preferredHeight: 30
                        padding: 0
                        text: qsTr("Review")

                        contentItem: Label {
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: reviewButton.text
                            color: root.primaryColor
                            font.pixelSize: 11
                            font.bold: true
                        }

                        background: Rectangle {
                            radius: 15
                            color: reviewButton.down ? "#DBEAFE" : "#EFF6FF"
                            border.color: "#BFDBFE"
                            border.width: 1
                        }

                        onClicked: {
                            reviewDialog.disputeId = disputeCard.model.disputeId
                            reviewDialog.subject = disputeCard.model.subject
                            var d = root.disputesModel.findDispute(disputeCard.model.disputeId)
                            reviewDialog.detail = d ? d.detail : ""
                            reviewDialog.open()
                        }
                    }
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
