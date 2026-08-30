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
                text: qsTr("Agent menu")
                color: "#2563EB"
                font.pixelSize: 16
                font.bold: true
            }
        }

        Repeater {
            model: [
                { title: qsTr("My property"), detail: qsTr("Manage your listings and drafts"), kind: "properties" },
                { title: qsTr("Recent bookings"), detail: qsTr("Bookings on your listings"), kind: "bookings" },
                { title: qsTr("Open disputes"), detail: qsTr("Disputes raised on your listings"), kind: "disputes" }
            ]

            delegate: Rectangle {
                required property var model
                required property int index
                Layout.fillWidth: true
                Layout.topMargin: index === 0 ? 6 : 0
                implicitHeight: agentDrawerRow.implicitHeight + 18
                radius: 10
                color: agentDrawerMouse.pressed ? "#F0F4FF" : "transparent"

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
                    id: agentDrawerRow
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
                    id: agentDrawerMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.close()
                        if (model.kind === "properties")
                            NavUtils.push(Qt.resolvedUrl("../../features/properties/screens/MyPropertiesScreen.qml"))
                        else if (model.kind === "bookings")
                            NavUtils.push(Qt.resolvedUrl("../../features/bookings/screens/BookingsScreen.qml"))
                        else if (model.kind === "disputes")
                            NavUtils.push(Qt.resolvedUrl("../../features/disputes/screens/DisputesScreen.qml"))
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
