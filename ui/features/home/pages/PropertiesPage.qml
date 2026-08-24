import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../delegates"

Page {
    id: root

    // Expose the model so the Screen can set/filter it
    property alias model: grid.model

    signal propertyClicked(string propertyId)
    signal favoriteClicked(string propertyId)
    signal categorySelected(string categoryName)

    background: Rectangle {
        color: "#FFFFFF"          // Official background
    }

    // We don’t use the default Page header because
    // the search bar already exists above this page.

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========== CATEGORY ROW ==========
        PropertyCategoryRow {
            id: categoryRow
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 4

            model: ListModel {
                ListElement {
                    name: "All"
                }
                ListElement {
                    name: "Apartments"
                }
                ListElement {
                    name: "Houses"
                }
                ListElement {
                    name: "Rooms"
                }
                ListElement {
                    name: "Studios"
                }
                ListElement {
                    name: "Shared"
                }
                ListElement {
                    name: "Luxury"
                }
            }

            onCategoryClicked: function (index, name) {
                root.categorySelected(name);
            // Simple client-side filter example (optional)
            // You can later replace this with real filtering
            }
        }

        // ========== PROPERTY GRID ==========
        // GridView {
        //     id: grid
        //     Layout.fillWidth: true
        //     Layout.fillHeight: true
        //     Layout.leftMargin: 12
        //     Layout.rightMargin: 12
        //     Layout.topMargin: 6

        //     cellWidth: (width - 12) / 2          // 2 columns with spacing
        //     cellHeight: 280

        //     clip: true
        //     boundsBehavior: Flickable.StopAtBounds

        //     // Pull-to-refresh (simple version)
        //     // You can later connect this to a real reload function
        //     // onMovementEnded: { if (contentY < -80) reload() }

        //     delegate: Item {
        //         width: grid.cellWidth
        //         height: grid.cellHeight

        //         PropertyCardDelegate {
        //             anchors.centerIn: parent
        //             width: parent.width - 8
        //             height: parent.height - 12

        //             propertyId: model.propertyId
        //             title: model.title
        //             location: model.location
        //             price: model.price
        //             imageUrl: model.imageUrl
        //             status: model.status
        //             isVerified: model.isVerified

        //             onClicked: root.propertyClicked(model.propertyId)
        //             onFavoriteClicked: root.favoriteClicked(model.propertyId)
        //         }
        //     }

        //     // Empty state
        //     Label {
        //         anchors.centerIn: parent
        //         visible: grid.count === 0
        //         text: "No properties found"
        //         font.pixelSize: 15
        //         color: "#6B7280"
        //     }

        //     ScrollBar.vertical: ScrollBar {
        //         policy: ScrollBar.AsNeeded
        //     }
        // }
    }
}
