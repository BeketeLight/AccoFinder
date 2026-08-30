import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/models"
import "../../../properties/components"
import "../../../../components/inputs"
import "../../../../utils/Utils.js" as Utils

Item {
    id: root

    property MyPropertiesModel propertiesModel: MyPropertiesModel {}

    property string statusFilter: "All"
    property string searchText: ""

    signal propertyClicked(var propertyId)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color textColor: "#1F2937"
    readonly property color mutedColor: "#6B7280"
    readonly property color borderColor: "#E5E7EB"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color softBlueColor: "#EFF6FF"

    function applyFilters() {
        root.propertiesModel.statusFilter = root.statusFilter === "All" ? "All" : root.statusFilter.toUpperCase()
        root.propertiesModel.searchText = root.searchText
        root.propertiesModel.applyFilters()
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        AppSearchBar {
            Layout.fillWidth: true
            placeholder: qsTr("Search by name, district or village")
            backgroundColor: "#FFFFFF"
            focusColor: root.primaryColor
            fieldHeight: 48
            text: root.searchText
            onTextEdited: {
                root.searchText = text
                root.applyFilters()
            }
        }

        Flickable {
            Layout.fillWidth: true
            implicitHeight: filterRow.implicitHeight
            contentWidth: filterRow.implicitWidth
            clip: true
            interactive: filterRow.implicitWidth > width

            Row {
                id: filterRow
                spacing: 8

                Repeater {
                    model: ["All", "Verified", "Pending", "Rejected"]

                    delegate: Rectangle {
                        required property string modelData
                        required property int index
                        width: chipLabel.implicitWidth + 26
                        height: 32
                        radius: 16
                        color: root.statusFilter === modelData ? root.primaryColor : root.surfaceColor
                        border.color: root.statusFilter === modelData ? root.primaryColor : root.borderColor
                        border.width: 1

                        Label {
                            id: chipLabel
                            anchors.centerIn: parent
                            text: modelData
                            color: root.statusFilter === modelData ? "#FFFFFF" : root.mutedColor
                            font.pixelSize: 12
                            font.bold: root.statusFilter === modelData
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.statusFilter = modelData
                                root.applyFilters()
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Label {
                Layout.fillWidth: true
                text: qsTr("%1 properties shown").arg(root.propertiesModel.resultCount)
                color: root.mutedColor
                font.pixelSize: 12
            }
        }

        Repeater {
            model: root.propertiesModel.propertiesModel

            delegate: Rectangle {
                id: propCard
                required property var model
                required property int index
                Layout.fillWidth: true
                implicitHeight: propRow.implicitHeight + 24
                radius: 12
                color: propMouse.pressed ? root.softBlueColor : root.surfaceColor
                border.color: root.borderColor
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
                            text: propCard.model.title.charAt(0)
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
                            text: propCard.model.title
                            color: root.textColor
                            font.pixelSize: 14
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: propCard.model.district + " \u00B7 " + propCard.model.village
                            color: root.mutedColor
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Landlord: %1").arg(propCard.model.landlord)
                            color: root.mutedColor
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        implicitHeight: 22
                        implicitWidth: statusLabel.implicitWidth + 14
                        radius: 11
                        color: {
                            var s = String(propCard.model.status).toUpperCase()
                            if (s === "VERIFIED") return "#ECFDF5"
                            if (s === "PENDING") return "#FFFBEB"
                            if (s === "REJECTED") return "#FEF2F2"
                            return "#F3F4F6"
                        }

                        Label {
                            id: statusLabel
                            anchors.centerIn: parent
                            text: root.propertiesModel.prettyStatus(propCard.model.status)
                            color: {
                                var s = String(propCard.model.status).toUpperCase()
                                if (s === "VERIFIED") return "#166534"
                                if (s === "PENDING") return "#B45309"
                                if (s === "REJECTED") return "#B91C1C"
                                return "#6B7280"
                            }
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }

                MouseArea {
                    id: propMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.propertyClicked(propCard.model.propertyId)
                }
            }
        }

        Label {
            visible: root.propertiesModel.resultCount === 0
            Layout.fillWidth: true
            Layout.topMargin: 8
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No properties match this filter.")
            color: root.mutedColor
            font.pixelSize: 13
        }
    }
}
