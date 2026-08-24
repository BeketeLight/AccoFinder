import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../models"
import "../../dashboards/Agets/pages"

Page {
    id: root

    readonly property color pageColor: "#F8FAFC"
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"

    property string pageTitle: qsTr("Properties")
    property bool showHeader: true
    property bool showBack: false

    signal addPropertyRequested()
    signal attentionClicked(var propertyTitle)
    signal propertyClicked(var propertyId)
    signal bookingClicked()
    signal notificationClicked()
    signal disputeClicked()

    property MyPropertiesModel listModel: MyPropertiesModel {}

    background: Rectangle { color: root.pageColor }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 96
        clip: true

        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: contentColumn
            x: Math.max(16, (flick.width - 560) / 2)
            y: 0
            width: Math.min(flick.width - 32, 560)
            spacing: 14

            AgentsDashboardPage {
                Layout.fillWidth: true

                onAddPropertyRequested: root.addPropertyRequested()
                onAttentionClicked: (propertyTitle) => root.attentionClicked(propertyTitle)
                onBookingClicked: root.bookingClicked()
                onNotificationClicked: root.notificationClicked()
                onDisputeClicked: root.disputeClicked()
            }

            Item { Layout.preferredHeight: 4; Layout.fillWidth: true }

            SectionHeader {
                Layout.fillWidth: true
                title: qsTr("My properties")
                actionLabel: qsTr("%1 shown").arg(root.listModel.resultCount)
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 22
                color: root.surfaceColor
                border.color: searchField.activeFocus ? root.primaryColor : root.borderColor
                border.width: searchField.activeFocus ? 2 : 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Item {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16

                        Rectangle {
                            x: 0.5
                            y: 0.5
                            width: 11
                            height: 11
                            radius: 5.5
                            color: "transparent"
                            border.color: root.mutedColor
                            border.width: 1.7
                        }

                        Rectangle {
                            width: 6
                            height: 1.7
                            radius: 0.85
                            color: root.mutedColor
                            rotation: 45
                            transformOrigin: Item.Left
                            x: 10.2
                            y: 10.2
                        }
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Search by name or location")
                        font.pixelSize: 13
                        color: root.textColor
                        background: null
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: {
                            root.listModel.searchText = text
                            root.listModel.applyFilters()
                        }
                    }

                    Item {
                        visible: searchField.text.length > 0
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: searchField.text = ""
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 13
                            height: 1.7
                            radius: 0.85
                            color: root.mutedColor
                            rotation: 45
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 13
                            height: 1.7
                            radius: 0.85
                            color: root.mutedColor
                            rotation: -45
                        }
                    }
                }
            }

            Flickable {
                Layout.fillWidth: true
                implicitHeight: filterChipsRow.implicitHeight
                contentWidth: filterChipsRow.implicitWidth
                clip: true
                interactive: filterChipsRow.implicitWidth > width

                Row {
                    id: filterChipsRow
                    spacing: 8

                    Repeater {
                        model: root.listModel.filterChipsModel

                        delegate: Rectangle {
                            required property var model
                            required property int index
                            width: chipLabel.implicitWidth + 26
                            height: 32
                            radius: 16
                            color: root.listModel.statusFilter === model.label ? root.primaryColor : root.surfaceColor
                            border.color: root.listModel.statusFilter === model.label ? root.primaryColor : root.borderColor
                            border.width: 1

                            Label {
                                id: chipLabel
                                anchors.centerIn: parent
                                text: model.label
                                color: root.listModel.statusFilter === model.label ? "#FFFFFF" : root.mutedColor
                                font.pixelSize: 12
                                font.bold: root.listModel.statusFilter === model.label
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.listModel.statusFilter = model.label
                                    root.listModel.applyFilters()
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                visible: root.listModel.resultCount > 0
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: root.listModel.propertiesModel

                    delegate: Rectangle {
                        required property var model
                        Layout.fillWidth: true
                        implicitHeight: propRow.implicitHeight + 24
                        radius: 12
                        color: propCardMouse.pressed ? root.softBlueColor : root.surfaceColor
                        border.color: propCardMouse.pressed ? "#BFDBFE" : root.borderColor
                        border.width: 1
                        visible: model.matches

                        RowLayout {
                            id: propRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                radius: 12
                                color: root.softBlueColor

                                Label {
                                    anchors.centerIn: parent
                                    text: model.title.charAt(0)
                                    color: root.primaryColor
                                    font.pixelSize: 17
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    Layout.fillWidth: true
                                    text: model.title
                                    color: root.textColor
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: model.location + " · " + model.rooms + qsTr(" rooms") + " · MK " + Number(model.price).toLocaleString() + qsTr("/mo")
                                    color: root.mutedColor
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                            }

                            StatusChip {
                                textValue: model.status
                                variant: model.status === "Verified" ? "success"
                                       : model.status === "Pending" ? "warning"
                                       : model.status === "Draft" ? "neutral"
                                       : "danger"
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
                            id: propCardMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.propertyClicked(model.propertyId)
                        }
                    }
                }
            }

            Label {
                visible: root.listModel.resultCount === 0
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: qsTr("No properties match your search.")
                color: root.mutedColor
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Rectangle {
        id: fab
        width: 54
        height: 54
        radius: 27
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.primaryColor }
            GradientStop { position: 1.0; color: root.primaryDarkColor }
        }

        Label {
            anchors.centerIn: parent
            text: "+"
            color: "#FFFFFF"
            font.pixelSize: 24
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.addPropertyRequested()
        }
    }
}
