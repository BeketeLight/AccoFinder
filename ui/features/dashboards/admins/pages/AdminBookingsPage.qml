import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../components/indicators"
import "../../../properties/components"
import "../../models"
import "../../../../utils/Utils.js" as Utils
import "../delegates"

Item {
    id: root

    property AdminBookingsModel bookingsModel: AdminBookingsModel {}
    property string pageTitle: qsTr("Bookings")

    // Raised so the screen (and Main.qml) can react to an admin settling a
    // booking; the dashboard's own counters come from DashboardController.
    signal bookingAction(var action, var bookingId)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"

    function confirmBooking(bookingId) {
        if (!bookingId || root.bookingsModel.busyBookingId.length > 0)
            return
        root.bookingsModel.busyBookingId = bookingId
        BookingViewModel.confirmBooking(bookingId)
        root.bookingAction("confirm", bookingId)
    }

    function cancelBooking(bookingId) {
        if (!bookingId || root.bookingsModel.busyBookingId.length > 0)
            return
        root.bookingsModel.busyBookingId = bookingId
        BookingViewModel.cancelBooking(bookingId)
        root.bookingAction("cancel", bookingId)
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            StatCard {
                Layout.fillWidth: true
                label: qsTr("Total bookings")
                valueText: String(root.bookingsModel.totalCount)
                accentColor: root.textColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Awaiting review")
                valueText: String(root.bookingsModel.pendingCount)
                accentColor: root.warningColor
            }
            StatCard {
                lableFontSize: 18
                Layout.fillWidth: true
                label: qsTr("Confirmed")
                valueText: String(root.bookingsModel.confirmedCount)
                accentColor: root.successColor
            }
            StatCard {
                lableFontSize: 18
                Layout.fillWidth: true
                label: qsTr("Booking value")
                valueText: Utils.formatCurrency(BookingViewModel.totalBookingValue())
                accentColor: root.primaryColor
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { key: "ALL", label: qsTr("All") },
                    { key: "PENDING", label: qsTr("Pending") },
                    { key: "CONFIRMED", label: qsTr("Confirmed") },
                    { key: "CANCELLED", label: qsTr("Cancelled") }
                ]

                delegate: Button {
                    id: filterButton
                    required property var model
                    readonly property bool isCurrent: root.bookingsModel.statusFilter === model.key

                    Layout.preferredHeight: 30
                    padding: 0

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: filterButton.model.label
                        color: filterButton.isCurrent ? "#FFFFFF" : "#374151"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 15
                        color: filterButton.isCurrent ? "#2563EB" : "#FFFFFF"
                        border.color: filterButton.isCurrent ? "#2563EB" : "#E5E7EB"
                        border.width: 1
                    }

                    onClicked: {
                        root.bookingsModel.statusFilter = model.key
                        root.bookingsModel.applyFilters()
                    }
                }
            }
        }

        StatSummaryBar {
            Layout.fillWidth: true
            backgroundColor: "#EFF6FF"
            borderColor: "#BFDBFE"
            dividerColor: "#DBEAFE"
            model: [
                { value: String(root.bookingsModel.shownCount), label: qsTr("Shown"), color: "#1F2937" },
                { value: String(root.bookingsModel.pendingCount), label: qsTr("Pending"), color: "#B45309" },
                { value: String(root.bookingsModel.confirmedCount), label: qsTr("Confirmed"), color: "#15803D" }
            ]
        }

        Repeater {
            id: bookingRepeater
            model: root.bookingsModel.viewModel

            delegate: AdminBookingDelegate {
                required property var model
                Layout.fillWidth: true

                bookingId: model.bookingId
                clientId: model.clientId
                clientName: model.clientName || ""
                clientPhone: model.clientPhone || ""
                roomId: model.roomId
                bookingDate: model.bookingDate
                amount: model.amount
                commissionAmount: model.commissionAmount
                status: model.status
                busy: root.bookingsModel.busyBookingId === model.bookingId

                onConfirmRequested: (id) => root.confirmBooking(id)
                onCancelRequested: (id) => root.cancelBooking(id)
            }
        }

        AppEmptyState {
            Layout.fillWidth: true
            visible: bookingRepeater.count === 0
            iconSource: "qrc:/ui/assets/bookings-icon.svg"
            title: root.bookingsModel.statusFilter === "ALL"
                   ? qsTr("No bookings yet")
                   : qsTr("No bookings to show")
            subtitle: root.bookingsModel.statusFilter === "ALL"
                      ? qsTr("Bookings made by clients and agents will appear here.")
                      : qsTr("Try a different filter to see other bookings.")
        }
    }
}
