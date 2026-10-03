import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../models"
import "../delegates"
import "../components"
import "../../../components/indicators"
import "../../properties/components"
import "../../../components/inputs"
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
            anchors.margins: 16
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
                    valueText: String(adminBookingsModel.pendingCount)
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
                model: ["All", "Pending", "Confirmed", "Cancelled"]
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

                    model: adminBookingsModel.bookingsModel
                    delegate: AdminStatsDelegate {
                        Layout.fillWidth: true
                        // prefer model.matches from BookingsModel
                        // visible handled inside via matches or activeFilter
                        activeFilter: filterBar.currentText

                        bookingId: model.bookingId ?? ""
                        houseName: model.houseName ?? ""
                        imageUrl: model.propertyImage ?? ""
                        status: model.status ?? ""
                        clientName: model.clientName ?? ""
                        hostName: model.hostName ?? ""
                        roomType: model.roomType ?? ""
                        propertyLocation: (model.district && model.village)
                            ? (model.district + ", " + model.village)
                            : (model.district || model.village || "")
                        price: Number(model.amount ?? 0)
                        dateRange: model.bookingDate ?? ""

                        onViewDetailsRequested: {
                            NavUtils.navigateToBookingsDetailsAdmin({ /* payload */ })
                        }
                    }
                }
            }
        }
    }
}