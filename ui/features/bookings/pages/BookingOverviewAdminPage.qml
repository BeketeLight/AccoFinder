import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../models"
import "../delegates"
import "../components"
import "../../../components/indicators"
import "../../properties/components"
import "../../../components/inputs"
import "../../../utils/NavigationUtils.js" as NavUtils
Page {
    id: root
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color secondaryColor: "#22C55E"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color softAmberColor: "#FFFBEB"
    readonly property color softRedColor: "#FEF2F2"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    readonly property bool busy: adminBookingsModel.loading
            || BookingViewModel.isLoading
    background: Rectangle { color: "#F8FAFC" }

    BookingsModel { id: adminBookingsModel }
    AppSpinner{
        id: loadingSpinner
        anchors.centerIn: parent
        running: adminBookingsModel.loading
        color: "#2563EB"
        size: 36
        z: 100
    }
    ScrollView {
        anchors.topMargin: 6
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // ---- 1. STAT GRID (2×2) ----
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Total Bookings")
                    valueText: String(adminBookingsModel.totalCount)
                    accentColor: root.primaryColor
                }
                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Pending Bookings")
                    valueText: String(adminBookingsModel.pendingPaymentCount)
                    accentColor: root.warningColor
                }
                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Confirmed Bookings")
                    valueText: String(adminBookingsModel.confirmedCount)
                    accentColor: root.successColor
                }
                StatCard {
                    Layout.fillWidth: true
                    label: qsTr("Cancelled Bookings")
                    valueText: String(adminBookingsModel.cancelledCount)
                    accentColor: root.dangerColor
                }

            }
            AppSearchBar{
                placeholder: "Search by ID, client, agent..."
            }
            //Status-filter
            FilterComponent {
                id: filterBar
                Layout.fillWidth: true
                model: ["All", "Pending payment", "Confirmed", "Cancelled"]
                onFilterChanged: function(text) {
                    adminBookingsModel.statusFilter = text
                }
            }

            // ---- 4. LIST ----
            ColumnLayout{
                id: columnId
                Layout.fillWidth: true
                spacing: 10

                Repeater{
                    id: repeater
                    model: adminBookingsModel.bookingsModel
                    delegate: AdminStatsDelegate {
                        Layout.fillWidth: true

                        onViewDetailsRequested: function(data) {
                            NavUtils.navigateToBookingDetailsForAdmin({
                                bookingId: model.bookingId ?? "",
                                houseName: model.houseName ?? "",
                                hostName: model.hostName,
                                hostInitials: model.hostInitials,
                                hostEmail: model.hostEmail ?? "",
                                hostPhone: model.hostPhone ?? "",
                                status: model.status ?? "",
                                clientName: model.clientName ?? "",
                                clientPhone: model.clientPhone ?? "",
                                landlord: model.landlord,
                                landlordInitials: model.landlordInitials,
                                landlordPhone: model.landlordPhone,
                                bookingDate: model.bookingDate ?? "",
                                price: model.amount ? model.amount.toString() : "0",
                                propertyLocation: model.propertyLocation ?? "", //(model.district && model.village) ? (model.district + ", " + model.village) : "N/A",
                                propertyImage: model.propertyImage,
                                roomType: model.roomType ?? "",
                                clientEmail: model.clientEmail ?? "",
                                clientInitial: model.clientInitial ?? "",
                                commission: model.commissionAmount ?? 0.0,
                            });
                        }
                    }
                }
            }
            AppEmptyState {
                anchors.bottom: repeater.bottom
                anchors.right: repeater.right
                anchors.left: repeater.left
                anchors.topMargin: 80
               // anchors.bottomMargin: 60
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                visible: !adminBookingsModel.loading && adminBookingsModel.resultCount === 0
                iconSource: "qrc:/ui/assets/bookings-icon.svg"
                title: {
                    switch (String(filterBar.currentText || "All")) {
                    case "Pending payment":
                        return qsTr("No pending bookings")
                    case "Confirmed":
                        return qsTr("No confirmed bookings")
                    case "Cancelled":
                        return qsTr("No cancelled bookings")
                    default:
                        return qsTr("No bookings yet")
                    }
                }
                subtitle: {
                    switch (String(filterBar.currentText || "All")) {
                    case "Pending payment":
                        return qsTr("Bookings waiting for payment will show up here.")
                    case "Confirmed":
                        return qsTr("Confirmed bookings will appear here after payment succeeds.")
                    case "Cancelled":
                        return qsTr("Cancelled or expired bookings will appear here.")
                    default:
                        return qsTr("Book a property to see your bookings here.")
                    }
                }
            }
        }
    }
}