import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../models"
import "../delegates"
import "../../../components/indicators"

// Search results area. Owns the SearchPropertiesModel mirror, renders its
// three states based on query/searching/count, and hosts the results grid.
Item {
    id: root

    property bool isSearching: false
    property bool hasQuery: false
    property int pageSize: 20

    signal loadMoreRequested

    SearchPropertiesModel {
        id: searchResults
    }

    // Watch the C++ model directly to force the UI to update when data arrives
    Connections {
        target: PropertyViewModel
        function onIsSearchingChanged() {
            // Just sync the local isSearching state.
            // We don't need to guess if it loaded.
        }
    }

    Item {
        anchors.fill: parent
        // ---- Loading (no prior results) ----
        AppSpinner {
            anchors.centerIn: parent
            size: 32
            lineWidth: 3
            color: "#2563EB"
            // Show ONLY if actively searching AND we have no results yet
            running: root.isSearching && searchResults.count === 0
            visible: running
        }

        // ---- Empty with query (or if database is empty) ----
        AppEmptyState {
            anchors.centerIn: parent
            width: Math.min(parent.width - 48, 320)
            height: implicitHeight
            visible: !root.isSearching && searchResults.count === 0 && root.hasQuery
            iconSource: "qrc:/ui/assets/search-icon.svg"
            title: qsTr("No results")
            subtitle: qsTr("There are no properties available at the moment.")
        }

        // ---- Results ----
        ScrollView {
            anchors.fill: parent
            visible: searchResults.count > 0
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 12
                Layout.leftMargin: 12
                Layout.rightMargin: 12

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

                                propertyId: String(model.propertyId || "")
                                propertyType: String(model.propertyType || "")
                                title: String(model.title || "")
                                description: String(model.description || "")
                                location: String(model.location || "")
                                district: String(model.district || "")
                                village: String(model.village || "")
                                price: Number(model.price || 0)

                                imageUrl: String(model.imageUrl || "")
                                imageUrls: String(model.imageUrls || "")

                                status: String(model.status || "")
                                isVerified: model.isVerified === true
                                isActive: model.isActive === true
                                amenities: model.amenities || ""
                                roomCount: Number(model.roomCount || 0)

                                landlord: String(model.landlord || "")
                                landlordPhone: String(model.landlordPhone || "")
                                ownerName: String(model.ownerName || "")
                                ownerPhone: String(model.ownerPhone || "")

                                rejectionReason: String(model.rejectionReason || "")
                                createdAt: String(model.createdAt || "")
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
