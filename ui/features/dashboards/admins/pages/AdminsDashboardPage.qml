import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"

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
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property string adminName: AppSettings.isLoggedIn() && AppSettings.userName().length > 0 ? AppSettings.userName() : "Admin"

    property int totalUsers: 1284
    property int totalAgents: 36
    property int totalProperties: 214
    property int pendingVerifications: 9
    property int verifiedProperties: 168
    property int openDisputes: 4
    property int totalBookings: 512
    property real bookingValue: 12480000
    property real platformCommission: 998400

    signal quickActionTriggered(var actionTitle)

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
                spacing: 10

                Label {
                    Layout.fillWidth: true
                    text: qsTr("System overview")
                    color: Qt.rgba(1, 1, 1, 0.75)
                    font.pixelSize: 13
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        Layout.fillWidth: true
                        text: root.adminName
                        color: "#FFFFFF"
                        font.pixelSize: 20
                        font.bold: true
                        elide: Text.ElideRight
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
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            StatCard {
                Layout.fillWidth: true
                label: qsTr("Total users")
                valueText: Number(root.totalUsers).toLocaleString()
                accentColor: root.primaryColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Registered agents")
                valueText: String(root.totalAgents)
                accentColor: root.secondaryColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Total properties")
                valueText: String(root.totalProperties)
                accentColor: root.successColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Pending verifications")
                valueText: String(root.pendingVerifications)
                accentColor: root.warningColor
                hint: root.pendingVerifications > 0 ? qsTr("Action needed") : ""
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Verified properties")
                valueText: String(root.verifiedProperties)
                accentColor: root.successColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Open disputes")
                valueText: String(root.openDisputes)
                accentColor: root.dangerColor
                hint: root.openDisputes > 0 ? qsTr("Needs review") : ""
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Total bookings")
                valueText: String(root.totalBookings)
                lableFontSize: 18
                accentColor: root.primaryDarkColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Booking value")
                valueText: "MK " + Number(root.bookingValue).toLocaleString()
                lableFontSize: 14
                accentColor: root.textColor
            }
        }

        StatCard {
            Layout.fillWidth: true
            label: qsTr("Platform commission earned")
            valueText: "MK " + Number(root.platformCommission).toLocaleString()
            lableFontSize: 16
            accentColor: root.successColor
        }

        SectionHeader {
            Layout.fillWidth: true
            title: qsTr("Quick actions")
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: quickActionsCol.implicitHeight
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                id: quickActionsCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 0

                Repeater {
                    model: [
                        qsTr("Verification queue"),
                        qsTr("User management"),
                        qsTr("Register agent"),
                        qsTr("Property approvals"),
                        qsTr("Dispute resolution")
                    ]

                    delegate: ColumnLayout {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: actionRow.implicitHeight + 20
                            color: actionMouse.pressed ? root.softBlueColor : "transparent"

                            RowLayout {
                                id: actionRow
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    radius: 17
                                    color: root.softBlueColor

                                    Label {
                                        anchors.centerIn: parent
                                        text: String(index + 1)
                                        color: root.primaryColor
                                        font.pixelSize: 13
                                        font.bold: true
                                    }
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: modelData
                                    color: root.textColor
                                    font.pixelSize: 13
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Item {
                                    Layout.preferredWidth: 9
                                    Layout.preferredHeight: 16

                                    Rectangle {
                                        width: 10
                                        height: 1.8
                                        radius: 0.9
                                        color: root.mutedColor
                                        rotation: 45
                                        transformOrigin: Item.Left
                                        x: 0
                                        y: 2.5
                                    }

                                    Rectangle {
                                        width: 10
                                        height: 1.8
                                        radius: 0.9
                                        color: root.mutedColor
                                        rotation: -45
                                        transformOrigin: Item.Left
                                        x: 0
                                        y: 13.5
                                    }
                                }
                            }

                            MouseArea {
                                id: actionMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.quickActionTriggered(modelData)
                            }
                        }

                        Rectangle {
                            visible: index < 4
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.leftMargin: 16
                            color: root.borderColor
                        }
                    }
                }
            }
        }
    }
}
