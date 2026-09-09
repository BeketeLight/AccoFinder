import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../properties/components"

ColumnLayout {
    id: root

    property string issue: ""
    property string bookingId: ""
    property string status: ""
    property bool showSeparator: true

    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    function tintBg(s) {
        if (String(s).toLowerCase() === "resolved") return "#ECFDF5"
        if (String(s).toLowerCase() === "in review") return "#FFFBEB"
        return "#FEF2F2"
    }

    function tintFg(s) {
        if (String(s).toLowerCase() === "resolved") return "#166534"
        if (String(s).toLowerCase() === "in review") return "#92400E"
        return "#B91C1C"
    }

    Layout.fillWidth: true
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: disputeRow.implicitHeight + 20
        color: "transparent"

        RowLayout {
            id: disputeRow
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 17
                color: root.tintBg(root.status)

                Label {
                    anchors.centerIn: parent
                    text: "?"
                    color: root.tintFg(root.status)
                    font.pixelSize: 15
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    Layout.fillWidth: true
                    text: root.issue.length > 0 ? root.issue : qsTr("Dispute")
                    color: root.textColor
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Booking %1").arg(root.bookingId.length > 0 ? root.bookingId : "—")
                    color: root.mutedColor
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            StatusChip {
                textValue: root.status.length > 0 ? root.status : qsTr("Open")
                variant: String(root.status).toLowerCase() === "resolved" ? "warning" : "danger"
            }
        }
    }

    Rectangle {
        visible: root.showSeparator
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: root.borderColor
    }
}