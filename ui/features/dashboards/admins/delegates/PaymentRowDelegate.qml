import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../../utils/Utils.js" as Utils

Rectangle {
    id: root

    property string paymentId: ""
    property real amount: 0
    property string status: ""
    property string user: ""
    property string kind: ""
    property string method: ""
    property string date: ""

    property color mutedColor: "#6B7280"

    signal actionRequested(var paymentId, var kind)

    function statusVariant(status) {
        if (status === "Completed" || status === "Paid" || status === "Settled") return "success"
        if (status === "Pending" || status === "Due") return "warning"
        return "danger"
    }

    Layout.fillWidth: true
    implicitHeight: payContent.implicitHeight + 20
    radius: 12
    color: "#FFFFFF"
    border.color: "#E5E7EB"
    border.width: 1

    ColumnLayout {
        id: payContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: root.paymentId + " · " + Utils.formatCurrency(root.amount)
                color: "#111827"
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }

            StatusChip {
                textValue: root.status
                variant: root.statusVariant(root.status)
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.user + " · " + root.kind
            color: root.mutedColor
            font.pixelSize: 11
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: root.method + " · " + root.date
                color: root.mutedColor
                font.pixelSize: 11
            }

            Button {
                id: payActionButton
                visible: root.status === "Pending" || root.status === "Disputed"
                Layout.preferredHeight: 28
                text: root.status === "Pending" ? qsTr("Mark completed")
                      : root.status === "Disputed" ? qsTr("Flag issue") : ""

                contentItem: Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: payActionButton.text
                    color: root.status === "Pending" ? "#166534" : "#B45309"
                    font.pixelSize: 10
                    font.bold: true
                }

                background: Rectangle {
                    radius: 14
                    color: payActionButton.down ? "#F3F4F6" : "#F9FAFB"
                    border.color: "#E5E7EB"
                    border.width: 1
                }

                onClicked: {
                    if (root.status === "Pending")
                        root.actionRequested(root.paymentId, "settled")
                    else
                        root.actionRequested(root.paymentId, "flagged")
                }
            }
        }
    }
}