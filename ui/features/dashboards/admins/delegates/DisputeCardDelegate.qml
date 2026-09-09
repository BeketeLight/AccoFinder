import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string disputeId: ""
    property string subject: ""
    property string propertyName: ""
    property string client: ""
    property string status: ""
    property string opened: ""

    property color primaryColor: "#2563EB"
    property color mutedColor: "#6B7280"

    signal reviewRequested(var disputeId, var subject)

    readonly property string variant: {
        if (root.status === "Resolved") return "success"
        if (root.status === "In review") return "warning"
        if (root.status === "Open") return "danger"
        return "neutral"
    }

    function tintBg(v) {
        if (v === "success") return "#ECFDF5"
        if (v === "warning") return "#FFFBEB"
        if (v === "danger") return "#FEF2F2"
        return "#F3F4F6"
    }

    function tintFg(v) {
        if (v === "success") return "#166534"
        if (v === "warning") return "#92400E"
        if (v === "danger") return "#B91C1C"
        return "#6B7280"
    }

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
            color: root.tintBg(root.variant)

            Label {
                anchors.centerIn: parent
                text: root.client.length > 0 ? root.client.charAt(0) : ""
                color: root.tintFg(root.variant)
                font.pixelSize: 15
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Label {
                Layout.fillWidth: true
                text: root.subject
                color: "#111827"
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                text: root.propertyName + " · " + root.client
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
                    color: root.tintBg(root.variant)

                    Label {
                        id: chipLabel
                        anchors.centerIn: parent
                        text: root.status
                        color: root.tintFg(root.variant)
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                Label {
                    text: root.opened
                    color: "#9CA3AF"
                    font.pixelSize: 10
                }
            }
        }

        Button {
            id: reviewButton
            visible: root.status === "Open" || root.status === "In review"
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

            onClicked: root.reviewRequested(root.disputeId, root.subject)
        }
    }
}