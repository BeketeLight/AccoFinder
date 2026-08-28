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

    property AdminDashboardModel dashboardModel: AdminDashboardModel {}

    signal addPropertyRequested()
    signal attentionClicked(var propertyTitle)
    signal quickActionTriggered(var actionTitle)
    signal usersRequested()
    signal agentsRequested()
    signal propertiesRequested()
    signal approvalsRequested()
    signal bookingsRequested()
    signal paymentsRequested()
    signal disputesRequested()
    signal notificationsRequested()
    signal activityTriggered(var kind)

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
                            text: qsTr("System overview")
                            color: Qt.rgba(1, 1, 1, 0.75)
                            font.pixelSize: 13
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.dashboardModel.adminName
                            color: "#FFFFFF"
                            font.pixelSize: 20
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: roleLabel.implicitWidth + 20
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.16)

                        Label {
                            id: roleLabel
                            anchors.centerIn: parent
                            text: qsTr("Administrator")
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
                            text: qsTr("%1 users · %2 agents").arg(root.dashboardModel.totalUsers).arg(root.dashboardModel.registeredAgents)
                            color: "#FFFFFF"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        id: heroNotifButton
                        Layout.preferredHeight: 38
                        text: qsTr("Announce")

                        contentItem: Label {
                            text: heroNotifButton.text
                            color: root.primaryDarkColor
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 19
                            color: heroNotifButton.down ? "#DBEAFE" : "#FFFFFF"
                        }

                        onClicked: root.notificationsRequested()
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
                Layout.preferredHeight: 100
                label: qsTr("Total users")
                valueText: String(root.dashboardModel.totalUsers)
                accentColor: root.primaryColor
                actionHint: qsTr("Manage")
                clickable: true
                onClicked: root.usersRequested()
            }
            StatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                label: qsTr("Registered agents")
                valueText: String(root.dashboardModel.registeredAgents)
                accentColor: root.secondaryColor
                actionHint: qsTr("View all")
                clickable: true
                onClicked: root.agentsRequested()
            }
            StatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                label: qsTr("Total properties")
                valueText: String(root.dashboardModel.totalProperties)
                accentColor: root.primaryDarkColor
                actionHint: qsTr("View all")
                clickable: true
                onClicked: root.propertiesRequested()
            }
            StatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                label: qsTr("Pending verifications")
                valueText: String(root.dashboardModel.pendingVerifications)
                accentColor: root.warningColor
                actionHint: qsTr("Review queue")
                clickable: true
                onClicked: root.approvalsRequested()
            }
            StatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                label: qsTr("Open disputes")
                valueText: String(root.dashboardModel.openDisputes)
                accentColor: root.dangerColor
                actionHint: qsTr("Resolve")
                clickable: true
                onClicked: root.disputesRequested()
            }
            StatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                lableFontSize: 18
                label: qsTr("Total bookings")
                valueText: String(root.dashboardModel.totalBookings)
                accentColor: root.textColor
                actionHint: qsTr("View all")
                clickable: true
                onClicked: root.bookingsRequested()
            }
            StatCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                lableFontSize: 18
                label: qsTr("Booking value")
                valueText: Utils.formatCurrency(root.dashboardModel.totalBookingValue)
                accentColor: root.successColor
                actionHint: qsTr("Oversight")
                clickable: true
                onClicked: root.paymentsRequested()
            }
            StatCard {
                Layout.preferredHeight: 100
                lableFontSize: 18
                Layout.fillWidth: true
                label: qsTr("Platform commission")
                valueText: Utils.formatCurrency(root.dashboardModel.platformCommission)
                accentColor: root.warningColor
                actionHint: qsTr("Oversight")
                clickable: true
                onClicked: root.paymentsRequested()
            }
        }

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Actions & activity")
        }

        Repeater {
            model: root.dashboardModel.pendingActivitiesModel

            delegate: Rectangle {
                id: activityRow
                required property var model
                required property int index
                Layout.fillWidth: true
                implicitHeight: activityContent.implicitHeight + 16
                radius: 12
                color: mouseArea.pressed ? root.softAmberColor : root.surfaceColor
                border.color: root.borderColor
                border.width: 1

                RowLayout {
                    id: activityContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 4
                        Layout.preferredHeight: 34
                        radius: 2
                        color: "#F59E0B"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            text: activityRow.model.title
                            color: root.textColor
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: activityRow.model.detail
                            color: root.mutedColor
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }


                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activityTriggered(activityRow.model.kind)
                }
            }
        }

        // Empty state: show a friendly message instead of leaving the section
        // blank when there is nothing requiring the admin's attention.
        ColumnLayout {
            id: caughtUpState
            visible: root.dashboardModel.pendingActivitiesModel.count === 0
            Layout.fillWidth: true
            Layout.topMargin: 2
            spacing: 6

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: root.softBlueColor
                border.color: "#BFDBFE"
                border.width: 1

                Label {
                    anchors.centerIn: parent
                    text: "✓"
                    color: root.primaryColor
                    font.pixelSize: 18
                    font.bold: true
                }
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("All caught up")
                color: root.textColor
                font.pixelSize: 13
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                Layout.fillWidth: true
                Layout.maximumWidth: 320
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("No pending actions or recent activity right now.")
                color: root.mutedColor
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

    }
}
