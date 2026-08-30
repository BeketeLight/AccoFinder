import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../utils/NavigationUtils.js" as NavUtils

Drawer {
    id: root
    width: 300
    height: parent.height
    edge: Qt.LeftEdge
    background: Rectangle { color: "#FFFFFF" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 6

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 56
            radius: 12
            color: "#EFF6FF"

            Label {
                anchors.centerIn: parent
                text: qsTr("Quick actions")
                color: "#2563EB"
                font.pixelSize: 16
                font.bold: true
            }
        }

        Repeater {
            model: [
                { title: qsTr("Verification queue"), detail: qsTr("Approve or reject listings"), kind: "approvals" },
                { title: qsTr("User management"), detail: qsTr("View clients and agents"), kind: "users" },
                { title: qsTr("Register agent"), detail: qsTr("Create a new agent account"), kind: "agents-register" },
                { title: qsTr("Property approvals"), detail: qsTr("Pending verification queue"), kind: "approvals" },
                { title: qsTr("Dispute resolution"), detail: qsTr("Review open disputes"), kind: "disputes" },
                { title: qsTr("Payments oversight"), detail: qsTr("Commissions and payouts"), kind: "payments" }
            ]

            delegate: Rectangle {
                required property var model
                required property int index
                Layout.fillWidth: true
                Layout.topMargin: index === 0 ? 6 : 0
                implicitHeight: drawerRow.implicitHeight + 18
                radius: 10
                color: drawerMouse.pressed ? "#F0F4FF" : "transparent"

                Rectangle {
                    visible: index > 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    height: 1
                    color: "#E5E7EB"
                }

                RowLayout {
                    id: drawerRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 4
                        Layout.preferredHeight: 32
                        radius: 2
                        color: "#2563EB"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            text: model.title
                            color: "#1F2937"
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.detail
                            color: "#6B7280"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    id: drawerMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.close()
                        if (model.kind === "users")
                            NavUtils.push(Qt.resolvedUrl("../../features/dashboards/admins/screens/UserManagementScreen.qml"))
                        else if (model.kind === "approvals")
                            NavUtils.push(Qt.resolvedUrl("../../features/dashboards/admins/screens/PropertyApprovalScreen.qml"))
                        else if (model.kind === "agents-register")
                            NavUtils.push(Qt.resolvedUrl("../../features/dashboards/admins/screens/RegisterAgentScreen.qml"))
                        else if (model.kind === "disputes")
                            NavUtils.push(Qt.resolvedUrl("../../features/dashboards/admins/screens/DisputesScreen.qml"))
                        else if (model.kind === "payments")
                            NavUtils.push(Qt.resolvedUrl("../../features/dashboards/admins/screens/PaymentsOversightScreen.qml"))
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
