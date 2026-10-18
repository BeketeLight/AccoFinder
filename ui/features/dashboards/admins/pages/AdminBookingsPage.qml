import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../../components/indicators"
import "../../../properties/components"
import "../../models"
import "../../../../utils/Utils.js" as Utils
import "../../../../utils/NavigationUtils.js" as NavUtils
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

    function releaseBooking(bookingId) {
        if (!bookingId || root.bookingsModel.busyBookingId.length > 0)
            return
        root.bookingsModel.busyBookingId = bookingId
        BookingViewModel.releaseBooking(bookingId)
        root.bookingAction("release", bookingId)
    }

    // The list rows only carry the booking's own columns; the detail screen
    // also shows the room and property the stay belongs to, so the row is
    // joined against the room/property view models here - the same join
    // BookingsModel performs for the client and agent booking lists.
    function findPropertyFor(propId) {
        if (!propId || !PropertyViewModel || !PropertyViewModel.propertiesForView)
            return {}
        var list = PropertyViewModel.propertiesForView() || []
        for (var i = 0; i < list.length; i++) {
            if (list[i] && String(list[i].id) === String(propId))
                return list[i]
        }
        return {}
    }

    function initialsFor(name) {
        var s = String(name || "").trim()
        if (s.length === 0)
            return ""
        var parts = s.split(/\s+/).filter(function (p) { return p.length > 0 })
        if (parts.length === 1)
            return parts[0].charAt(0).toUpperCase()
        return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
    }

    function openBookingDetails(row) {
        var roomInfo = (row.roomId && typeof RoomViewModel !== "undefined")
            ? (RoomViewModel.getRoomById(row.roomId) || {})
            : {}
        var propId = roomInfo.propertyId ? String(roomInfo.propertyId) : ""
        var propInfo = propId.length > 0 ? root.findPropertyFor(propId) : {}

        var hostName = ((propInfo.ownerFirstName || "") + " " + (propInfo.ownerSurname || "")).trim()
        if (hostName.length === 0)
            hostName = propInfo.ownerName || propInfo.landlord || ""
        var landlord = propInfo.landlord || ""

        NavUtils.navigateToBookingDetailsForAdmin({
            bookingId: row.bookingId || "",
            status: row.status || "",
            bookingDate: row.bookingDate || "",
            price: Number(row.amount) || 0,
            commission: Number(row.commissionAmount) || 0,

            clientName: row.clientName || "",
            clientPhone: row.clientPhone || "",
            clientEmail: row.clientEmail || "",
            clientInitial: root.initialsFor(row.clientName),

            houseName: propInfo.title || "",
            propertyLocation: (propInfo.district && propInfo.village)
                ? (propInfo.district + ", " + propInfo.village)
                : (propInfo.district || propInfo.village || ""),
            roomType: roomInfo.type || "",

            // No photo travels with the list row: the detail screen pulls the
            // booked room's image from the (asynchronously loaded) media model.
            propertyId: propId,
            roomId: row.roomId || "",
            propertyImage: "",

            hostName: hostName,
            hostInitials: root.initialsFor(hostName),
            hostEmail: propInfo.ownerEmail || "",
            hostPhone: propInfo.ownerPhone || "",
            landlord: landlord,
            landlordInitials: root.initialsFor(landlord),
            landlordPhone: propInfo.landlordPhone || ""
        })
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
                clientEmail: model.clientEmail || ""
                roomId: model.roomId
                bookingDate: model.bookingDate
                amount: model.amount
                commissionAmount: model.commissionAmount
                status: model.status
                busy: root.bookingsModel.busyBookingId === model.bookingId

                onConfirmRequested: (id) => root.confirmBooking(id)
                onCancelRequested: (id) => root.cancelBooking(id)
                onReleaseRequested: (id) => root.releaseBooking(id)
                onViewDetailsRequested: (data) => root.openBookingDetails(data)
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
