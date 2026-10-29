import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../models"
import "../../../components/indicators"

// The scrollable results area. Reads from SearchPropertiesModel (reactive),
// shows one of three states based on the model + query, and renders cards via
// SearchPropertyCardDelegate.
Item {
    id: root

    property bool isSearching: false
    property bool hasQuery: false        // any text/filter set
    property int pageSize: 20

    signal loadMoreRequested

    SearchPropertiesModel {
        id: searchResults
    }

    Item {
        anchors.fill: parent

        AppSpinner {
            anchors.centerIn: parent
            size: 32
            lineWidth: 3
            color: "#2563EB"
            running: root.isSearching
            visible: root.isSearching && searchResults.count === 0
        }

        AppEmptyState {
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 320)
            visible: !root.isSearching && searchResults.count === 0 && root.hasQuery
            iconSource: "qrc:/ui/assets/search-icon.svg"
            title: qsTr("No results")
            subtitle: qsTr("Try a different location, or clear a filter.")
        }

        AppEmptyState {
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 320)
            visible: !root.isSearching && searchResults.count === 0 && !root.hasQuery
            iconSource: "qrc:/ui/assets/search-icon.svg"
            title: qsTr("Search properties")
            subtitle: qsTr("Type a location, or pick a filter.")
        }

        ScrollView {
            anchors.fill: parent
            visible: searchResults.count > 0
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 12

                Item {
                    Layout.preferredHeight: 8
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 10
                    readonly property real cellWidth: (width - spacing * 2) / 3

                    Repeater {
                        model: searchResults.model

                        delegate: Item {
                            required property var model
                            width: parent.cellWidth
                            height: width * 1.73

                            SearchPropertyCardDelegate {
                                anchors.fill: parent
                                propertyId: model.propertyId
                                propertyType: model.propertyType
                                title: model.title
                                district: model.district
                                price: model.price
                                amenities: model.amenities
                                status: model.status
                                isVerified: model.verificationStatus === "VERIFIED"
                            }
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    visible: searchResults.count > 0 && !root.isSearching && (searchResults.count % root.pageSize) === 0
                    text: root.isSearching ? qsTr("Loading…") : qsTr("Load more")
                    background: Rectangle {
                        radius: 12
                        color: "#EFF6FF"
                        border.color: "#BFDBFE"
                        border.width: 1
                    }
                    contentItem: Label {
                        text: parent.text
                        color: "#2563EB"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.loadMoreRequested()
                }

                Item {
                    Layout.preferredHeight: 8
                }
            }
        }
    }
}
