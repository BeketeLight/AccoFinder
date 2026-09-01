import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../delegates"
import "../models"
import "../pages"

Page {
    id: homePageId

    // ========== HEADER (already contains title + search bar) ==========
    header: HeaderComponent {
        id: header
    }

    // ========== CONTENT (this is the important part) ==========
    background: Rectangle {
        color: "#FFFFFF"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Category Row
        PropertyCategoryRow {
            id: categoryRow
            Layout.fillWidth: true
            Layout.preferredHeight: 48
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
                console.log("Category selected:", name);
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // 2. Property Grid
            GridView {
                id: propertyGrid
                anchors.fill: parent         // ← Important!
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                anchors.topMargin: 8

                cellWidth: (width - 12) / 2
                cellHeight: 280
                clip: true
                visible: count > 0

                model: PropertyListModel {}     // your dummy model

                delegate: Item {
                    width: propertyGrid.cellWidth
                    height: propertyGrid.cellHeight

                    PropertyCardDelegate {
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: parent.height - 12

                        propertyId: model.propertyId
                        title: model.title
                        location: model.location
                        price: model.price
                        imageUrl: model.imageUrl
                        imageUrls: model.imageUrls
                        status: model.status
                        isVerified: model.isVerified

                        onClicked: console.log("Clicked:", model.propertyId)
                        onFavoriteClicked: console.log("Favorite:", model.propertyId)
                    }
                }
            }
            // Empty state
            Label {
                anchors.centerIn: parent
                text: "No Properties Found"
                visible: propertyGrid.count === 0
                font.pixelSize: 18
            }
        }
    }
}
