import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../models"
import "../../../properties/components"
import "../../../../utils/Utils.js" as Utils

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
    signal attentionClicked(var propertyTitle)
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
                            text: qsTr("Area: %1").arg(AppSettings.assignedArea() || "Not assigned")
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

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: bookingsSummaryRow.implicitHeight + 26
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            RowLayout {
                id: bookingsSummaryRow
                anchors.fill: parent
                anchors.margins: 13
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.dashboardModel.pendingBookings + root.dashboardModel.confirmedBookings + root.dashboardModel.cancelledBookings)
                        font.pixelSize: 17
                        font.bold: true
                        color: root.textColor
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Bookings")
                        font.pixelSize: 11
                        color: root.mutedColor
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: parent.height - 26; color: root.borderColor }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.dashboardModel.pendingBookings)
                        font.pixelSize: 17
                        font.bold: true
                        color: root.warningColor
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Pending")
                        font.pixelSize: 11
                        color: root.mutedColor
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: parent.height - 26; color: root.borderColor }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.dashboardModel.confirmedBookings)
                        font.pixelSize: 17
                        font.bold: true
                        color: root.successColor
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Confirmed")
                        font.pixelSize: 11
                        color: root.mutedColor
                    }
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: parent.height - 26; color: root.borderColor }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root.dashboardModel.cancelledBookings)
                        font.pixelSize: 17
                        font.bold: true
                        color: root.dangerColor
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Cancelled")
                        font.pixelSize: 11
                        color: root.mutedColor
                    }
                }
            }
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

                    delegate: ColumnLayout {
                        required property var model
                        required property int index
                        Layout.fillWidth: true
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: attnRow.implicitHeight + 20
                            color: attnMouse.pressed ? root.softAmberColor : "transparent"

                            RowLayout {
                                id: attnRow
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                Rectangle {
                                    Layout.preferredWidth: 4
                                    Layout.preferredHeight: 36
                                    radius: 2
                                    color: "#F59E0B"
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.title
                                        color: root.textColor
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.reason
                                        color: root.mutedColor
                                        font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Button {
                                    id: attnActionButton
                                    Layout.preferredHeight: 30
                                    text: model.actionLabel

                                    contentItem: Label {
                                        text: attnActionButton.text
                                        color: "#B45309"
                                        font.pixelSize: 11
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        radius: 15
                                        color: attnActionButton.down ? "#FEF3C7" : "transparent"
                                        border.color: "#FDE68A"
                                        border.width: 1
                                    }

                                    onClicked: root.attentionClicked(model.title)
                                }
                            }

                            MouseArea {
                                id: attnMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.attentionClicked(model.title)
                            }
                        }

                        Rectangle {
                            visible: index < root.dashboardModel.attentionModel.count - 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.leftMargin: 16
                            color: root.borderColor
                        }
                    }
                }
            }
        }

        Label {
            visible: root.dashboardModel.attentionModel.count === 0
            Layout.fillWidth: true
            text: qsTr("All properties are in good standing.")
            color: root.mutedColor
            font.pixelSize: 12
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

                    delegate: ColumnLayout {
                        required property var model
                        required property int index
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
                                        text: model.client.charAt(0)
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
                                        text: model.propertyTitle + " · " + model.room
                                        color: root.textColor
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.client + " · " + model.date + " · " + Utils.formatCurrency(model.amount)
                                        color: root.mutedColor
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                StatusChip {
                                    textValue: model.status
                                    variant: model.status === "Confirmed" ? "success"
                                           : model.status === "Pending" ? "warning"
                                           : "danger"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.bookingClicked()
                            }
                        }

                        Rectangle {
                            visible: index < root.dashboardModel.recentBookingsModel.count - 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.borderColor
                        }
                    }
                }
            }
        }

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Notifications")
            actionLabel: qsTr("View all")
            onActionTriggered: root.notificationClicked()
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: notifCol.implicitHeight
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: notifCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 0

                Repeater {
                    model: root.dashboardModel.notificationsModel

                    delegate: ColumnLayout {
                        required property var model
                        required property int index
                        Layout.fillWidth: true
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: notifRow.implicitHeight + 20
                            color: model.unread ? root.softBlueColor : "transparent"

                            RowLayout {
                                id: notifRow
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Rectangle {
                                    Layout.preferredWidth: 8
                                    Layout.preferredHeight: 8
                                    radius: 4
                                    color: model.unread ? root.primaryColor : "transparent"
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.title
                                        color: root.textColor
                                        font.pixelSize: 13
                                        font.bold: model.unread
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.message
                                        color: root.mutedColor
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                Label {
                                    text: model.time
                                    color: root.mutedColor
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.notificationClicked()
                            }
                        }

                        Rectangle {
                            visible: index < root.dashboardModel.notificationsModel.count - 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.borderColor
                        }
                    }
                }
            }
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

                    delegate: ColumnLayout {
                        required property var model
                        required property int index
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
                                    color: root.softRedColor

                                    Label {
                                        anchors.centerIn: parent
                                        text: "?"
                                        color: root.dangerColor
                                        font.pixelSize: 15
                                        font.bold: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.subject
                                        color: root.textColor
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: model.propertyName
                                        color: root.mutedColor
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                StatusChip {
                                    textValue: model.state
                                    variant: model.state === "Open" ? "danger" : "warning"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.disputeClicked()
                            }
                        }

                        Rectangle {
                            visible: index < root.dashboardModel.disputesModel.count - 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.borderColor
                        }
                    }
                }
            }
        }

        Label {
            visible: root.dashboardModel.disputesModel.count === 0
            Layout.fillWidth: true
            text: qsTr("No open disputes. All clear.")
            color: root.mutedColor
            font.pixelSize: 12
        }
    }
}
