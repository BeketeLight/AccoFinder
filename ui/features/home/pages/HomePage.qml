import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../delegates"
import "../models"

Page {
    id: homePageId
    background: Rectangle {
        color: "#FFFFFF"
    }

    // ===== Header as overlay (not using Page.header) =====
    HeaderComponent {
        id: headerComponent
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 10                          // stay on top of content
        scrollPosition: mainFlick.contentY
        maxCollapse: 50
    }

    // ===== Scrollable content =====
    Flickable {
        id: mainFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: mainFlick.width
            spacing: 2

            // Spacer = full height of header when not collapsed
            // This pushes the real content below the header
            Item {
                width: 1
                height: 50 + 16 + 40   // titleRow + margins + searchBar approx
            }

            // Categories
            PropertyCategoryRow {
                width: parent.width
                height: 48
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
            }
            // space
            Rectangle {
                width: parent.width
                height: 8
                color: "#F5F5F5"
            }

            // Super Deals
            SuperDeals {
                id: superDeals
                width: parent.width
                cardHeight: 150
                cardWidth: 190
                model: PropertyListModel {}
            }

            // space
            Rectangle {
                width: parent.width
                height: 8
                color: "#F5F5F5"
            }

            // Near you
            SuperDeals {
                id: nearYou
                title: "Near You"
                width: parent.width
                cardWidth: 130
                cardHeight: 160
                model: PropertyListModel {}
                // height: 220
            }

            // space
            Rectangle {
                width: parent.width
                height: 8
                color: "#F5F5F5"
            }

            // Section title
            Label {
                text: "All Properties"
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
                leftPadding: 16
                topPadding: 12
                bottomPadding: 8
            }

            // Properties
            Flow {
                id: propertyFlow
                width: parent.width
                leftPadding: 12
                rightPadding: 12
                spacing: 8

                Repeater {
                    model: PropertyListModel {}

                    PropertyCardDelegate {
                        width: (propertyFlow.width - propertyFlow.leftPadding - propertyFlow.rightPadding - propertyFlow.spacing * 2) / 3

                        height: width * 1.25
                        // width: (propertyFlow.width - 24 - 10) / 2
                        // height: width * 1.35

                        propertyId: model.propertyId
                        title: model.title
                        location: model.location
                        price: model.price
                        imageUrl: model.imageUrl
                        imageUrls: model.imageUrls
                        status: model.status
                        isVerified: model.isVerified
                    }
                }
            }
            Item {
                width: 1
                height: headerComponent.maxCollapse + 52
                //height: 48 + 12 + 40
                // height: 48 + 48
            }
        }
    }
}
