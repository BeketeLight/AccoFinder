import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../models"
import "../../../properties/components"
import "../../../../components/indicators"
import "../../../../utils/Utils.js" as Utils
import "../delegates"

Item {
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

    property AgentDashboardModel dashboardModel: AgentDashboardModel {}

    signal addPropertyRequested()
    signal attentionClicked(var kind, var targetId)
    signal bookingClicked()
    signal notificationClicked()
    signal disputeClicked()

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 18

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: heroContent.implicitHeight + 40
            radius: 16
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.primaryColor }
                GradientStop { position: 1.0; color: root.primaryDarkColor }
            }

            Rectangle {
                x: parent.width - 70
                y: -30
                width: 140
                height: 140
                radius: 70
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            Rectangle {
                x: parent.width - 150
                y: 60
                width: 90
                height: 90
                radius: 45
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            ColumnLayout {
                id: heroContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Welcome back,")
                            color: Qt.rgba(1, 1, 1, 0.75)
                            font.pixelSize: 13
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.dashboardModel.agentName
                            color: "#FFFFFF"
                            font.pixelSize: 20
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: rateLabel.implicitWidth + 20
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.16)

                        Label {
                            id: rateLabel
                            anchors.centerIn: parent
                            text: qsTr("Commission %1%").arg(Number(root.dashboardModel.commissionRate).toFixed(0))
                            color: "#FFFFFF"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: areaLabel.implicitWidth + 22
                        Layout.preferredHeight: 30
                        radius: 15
                        color: Qt.rgba(1, 1, 1, 0.14)

                        Label {
                            id: areaLabel
                            anchors.centerIn: parent
                            text: qsTr("Area: %1").arg(root.dashboardModel.agentArea || "Not assigned")
                            color: "#FFFFFF"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        id: heroAddButton
                        Layout.preferredHeight: 38
                        text: qsTr("+ Add Property")

                        contentItem: Label {
                            text: heroAddButton.text
                            color: root.primaryDarkColor
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 19
                            color: heroAddButton.down ? "#DBEAFE" : "#FFFFFF"
                        }

                        onClicked: root.addPropertyRequested()
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            StatCard {
                Layout.fillWidth: true
                label: qsTr("Properties assigned")
                valueText: String(root.dashboardModel.totalProperties)
                accentColor: root.primaryColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Pending verifications")
                valueText: String(root.dashboardModel.pendingVerifications)
                accentColor: root.warningColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Verified properties")
                valueText: String(root.dashboardModel.verifiedProperties)
                accentColor: root.successColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Available rooms")
                valueText: String(root.dashboardModel.availableRooms)
                accentColor: root.secondaryColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Booked rooms")
                valueText: String(root.dashboardModel.bookedRooms)
                accentColor: root.primaryDarkColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Open disputes")
                valueText: String(root.dashboardModel.disputesModel.count)
                accentColor: root.dangerColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Total booking value")
                lableFontSize: 16
                valueText: Utils.formatCurrency(root.dashboardModel.totalBookingValue)
                accentColor: root.textColor
            }
            StatCard {
                Layout.fillWidth: true
                lableFontSize: 16
                label: qsTr("Commission earned")
                valueText: Utils.formatCurrency(root.dashboardModel.commissionEarned)
                accentColor: root.successColor
            }
        }

        StatSummaryBar {
            Layout.fillWidth: true
            margin: 13
            model: [
                { value: String(root.dashboardModel.pendingBookings + root.dashboardModel.confirmedBookings + root.dashboardModel.cancelledBookings), label: qsTr("Bookings"), color: root.textColor },
                { value: String(root.dashboardModel.pendingBookings), label: qsTr("Pending"), color: root.warningColor },
                { value: String(root.dashboardModel.confirmedBookings), label: qsTr("Confirmed"), color: root.successColor },
                { value: String(root.dashboardModel.cancelledBookings), label: qsTr("Cancelled"), color: root.dangerColor }
            ]
        }

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Properties requiring attention")
        }

        Rectangle {
            visible: root.dashboardModel.attentionModel.count > 0
            Layout.fillWidth: true
            implicitHeight: attnListColumn.implicitHeight
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: attnListColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 0

                Repeater {
                    model: root.dashboardModel.attentionModel

                    delegate: AttentionRowDelegate {
                        title: model.title
                        reason: model.reason
                        actionLabel: model.actionLabel
                        kind: model.kind
                        targetId: model.targetId
                        showSeparator: index < root.dashboardModel.attentionModel.count - 1
                        onClicked: (kind, targetId) => root.attentionClicked(kind, targetId)
                    }
                }
            }
        }
        AppEmptyState {
            visible: root.dashboardModel.recentBookingsModel.count === 0
            Layout.fillWidth: true
            Layout.topMargin: 2
            iconSource: "qrc:/ui/assets/bookings-icon.svg"
            iconBgColor: root.softBlueColor
            iconBorderColor: "#BFDBFE"
            title: qsTr("Nothing yet")
            subtitle: qsTr("All properties are in good standing.")
        }

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Recent bookings")
            actionLabel: qsTr("View all")
            onActionTriggered: root.bookingClicked()
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: recentBookingsCol.implicitHeight
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: recentBookingsCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 0

                Repeater {
                    model: root.dashboardModel.recentBookingsModel

                    delegate: BookingRowDelegate {
                        bookingId: model.bookingId
                        roomId: model.roomId
                        bookingDate: model.bookingDate
                        amount: model.amount
                        status: model.status
                        showSeparator: index < root.dashboardModel.recentBookingsModel.count - 1
                        onClicked: root.bookingClicked()
                    }
                }
            }
        }

        AppEmptyState {
            visible: root.dashboardModel.recentBookingsModel.count === 0
            Layout.fillWidth: true
            Layout.topMargin: 2
            iconSource: "qrc:/ui/assets/bookings-icon.svg"
            iconBgColor: root.softBlueColor
            iconBorderColor: "#BFDBFE"
            title: qsTr("No bookings yet")
            subtitle: qsTr("Bookings for your listed properties will show here.")
        }

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Open disputes")
            actionLabel: root.dashboardModel.disputesModel.count > 0 ? qsTr("View all") : ""
            onActionTriggered: root.disputeClicked()
        }

        Rectangle {
            visible: root.dashboardModel.disputesModel.count > 0
            Layout.fillWidth: true
            implicitHeight: disputeCol.implicitHeight
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: disputeCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 0

                Repeater {
                    model: root.dashboardModel.disputesModel

                    delegate: AgentDisputeRowDelegate {
                        issue: model.issue
                        bookingId: model.bookingId
                        status: model.status
                        showSeparator: index < root.dashboardModel.disputesModel.count - 1
                        onClicked: root.disputeClicked()
                    }
                }
            }
        }

        AppEmptyState {
            visible: root.dashboardModel.disputesModel.count === 0
            Layout.fillWidth: true
            Layout.topMargin: 2
            iconSource: "qrc:/ui/assets/disputes-icon.svg"
            iconBgColor: "#FEF2F2"
            iconBorderColor: "#FECACA"
            title: qsTr("No open disputes")
            subtitle: qsTr("All clear — no disputes on your listings.")
        }
    }
}
