import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/models"
import "../../../properties/components"
import "../../../../components/inputs"
import "../../../../utils/Utils.js" as Utils
import "../delegates"

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

            delegate: AdminPropertyDelegate {
                propertyId: model.propertyId
                title: model.title
                district: model.district
                village: model.village
                landlord: model.landlord
                status: model.status
                statusText: root.propertiesModel.prettyStatus(model.status)
                approvedByName: model.approvedByName
                matches: model.matches
                onPropertyClicked: (propertyId) => root.propertyClicked(propertyId)
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
