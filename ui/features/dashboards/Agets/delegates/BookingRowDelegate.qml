import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../../../utils/Utils.js" as Utils

ColumnLayout {
    id: root

    property string bookingId: ""
    property string roomId: ""
    property string bookingDate: ""
    property real amount: 0
    property string status: ""
    property bool showSeparator: true

    property color primaryColor: "#2563EB"
    property color softBlueColor: "#EFF6FF"
    property color textColor: "#1F2937"
    property color mutedColor: "#6B7280"
    property color borderColor: "#E5E7EB"

    signal clicked()

    Layout.fillWidth: true
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: bookingRow.implicitHeight + 20
        color: "transparent"

        RowLayout {
            id: bookingRow
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 19
                color: root.softBlueColor

                Label {
                    anchors.centerIn: parent
                    text: (root.bookingId || "?").length > 0
                          ? String(root.bookingId).charAt(String(root.bookingId).length - 1)
                          : "?"
                    color: root.primaryColor
                    font.pixelSize: 15
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Booking %1 · Room %2")
                            .arg(root.bookingId || "—")
                            .arg(root.roomId || "—")
                    color: root.textColor
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("%1 · %2")
                            .arg(root.bookingDate || "—")
                            .arg(Utils.formatCurrency(root.amount))
                    color: root.mutedColor
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            StatusChip {
                textValue: String(root.status).length > 0 ? root.status : qsTr("Pending")
                variant: {
                    var st = String(root.status).toLowerCase()
                    if (st === "confirmed" || st === "paid") return "success"
                    if (st === "cancelled") return "danger"
                    return "warning"
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }

    Rectangle {
        visible: root.showSeparator
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: root.borderColor
    }
}