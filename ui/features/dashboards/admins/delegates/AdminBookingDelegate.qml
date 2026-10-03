import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../components/indicators"
import "../../../../utils/Utils.js" as Utils

// One row in the admin bookings oversight list. Renders the fields the
// BookingListModel actually exposes (id, client, room, date, amount,
// commission, status) rather than the placeholder data the legacy booking
// prototypes assumed, so the values on screen are the real ones from the API.
Rectangle {
    id: root

    property string bookingId: ""
    property string clientId: ""
    property string roomId: ""
    property string bookingDate: ""
    property real amount: 0
    property real commissionAmount: 0
    property string status: ""

    // Set while this specific row has a confirm/cancel request in flight, so
    // only the affected row shows progress.
    property bool busy: false

    signal confirmRequested(var bookingId)
    signal cancelRequested(var bookingId)

    readonly property color statusTint: root.status === "Confirmed" ? "#16A34A"
                                         : root.status === "Cancelled" ? "#DC2626"
                                         : root.status === "Paid"      ? "#2563EB"
                                         : "#D97706"
    readonly property bool isActionable: root.status === "Pending"

    Layout.fillWidth: true
    implicitHeight: cardColumn.implicitHeight + 20
    radius: 12
    color: "#FFFFFF"
    border.color: "#E5E7EB"
    border.width: 1

    ColumnLayout {
        id: cardColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
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
                    text: root.bookingDate.length >= 5 ? root.bookingDate.substring(0, 2) : "--"
                    color: "#1D4ED8"
                    font.pixelSize: 15
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    Layout.fillWidth: true
                    text: root.bookingId.length > 0 ? qsTr("Booking %1").arg(root.bookingId) : qsTr("Booking")
                    color: "#111827"
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    // Identifiers are long and unbounded, so they wrap rather
                    // than being cut off at the right edge of the card.
                    text: root.clientId.length > 0 || root.roomId.length > 0
                          ? qsTr("Client %1  ·  Room %2").arg(root.clientId, root.roomId)
                          : qsTr("No client or room details")
                    color: "#6B7280"
                    font.pixelSize: 11
                    lineHeight: 1.1
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                implicitHeight: 22
                implicitWidth: statusLabel.implicitWidth + 14
                radius: 11
                color: Qt.lighter(root.statusTint, 1.82)

                Label {
                    id: statusLabel
                    anchors.centerIn: parent
                    text: root.status.length > 0 ? root.status : qsTr("Pending")
                    color: root.statusTint
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                Layout.fillWidth: true
                text: {
                    var date = root.bookingDate.length > 0 ? root.bookingDate : qsTr("No date")
                    var commission = root.commissionAmount > 0
                        ? qsTr("  ·  Commission %1").arg(Utils.formatCurrency(root.commissionAmount))
                        : ""
                    return qsTr("Booked %1%2").arg(date, commission)
                }
                color: "#6B7280"
                font.pixelSize: 11
                lineHeight: 1.1
                wrapMode: Text.WordWrap
            }

            Label {
                text: Utils.formatCurrency(root.amount)
                color: "#111827"
                font.pixelSize: 14
                font.bold: true
            }
        }

        // Confirm / cancel are only offered while a booking is still pending;
        // a settled booking is read-only from oversight.
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.isActionable

            Button {
                id: confirmButton
                visible: root.isActionable
                enabled: !root.busy
                text: qsTr("Confirm")
                implicitHeight: 30

                contentItem: Label {
                    text: confirmButton.text
                    color: "#FFFFFF"
                    font.pixelSize: 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8
                    color: confirmButton.down ? "#15803D" : "#16A34A"
                }

                onClicked: root.confirmRequested(root.bookingId)
            }

            Button {
                id: cancelButton
                visible: root.isActionable
                enabled: !root.busy
                text: qsTr("Cancel booking")
                implicitHeight: 30

                contentItem: Label {
                    text: cancelButton.text
                    color: "#B91C1C"
                    font.pixelSize: 11
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8
                    color: cancelButton.down ? "#FEE2E2" : "#FFFFFF"
                    border.color: "#FECACA"
                    border.width: 1
                }

                onClicked: root.cancelRequested(root.bookingId)
            }

            AppSpinner {
                visible: root.busy
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                size: 16
                lineWidth: 2
                color: "#2563EB"
                running: visible
            }

            Item { Layout.fillWidth: true }
        }
    }
}
