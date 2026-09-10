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
                id: categoryRow
                width: parent.width
                height: 48
                model: ListModel {
                    ListElement {
                        name: "All"
                    }
                    ListElement {
                        name: "Hostels"
                    }
                    ListElement {
                        name: "Quarters"
                    }
                    ListElement {
                        name: "House"
                    }
                }
                onCategoryClicked: function (index, name) {
                    contentSwipe.currentIndex = index;
                }
            }
            SwipeView {
                id: contentSwipe
                width: parent.width
                height: Math.max(mainFlick.height - y, 600) // or bind better later
                clip: true
                currentIndex: categoryRow.currentIndex

                // When user swipes → update chips
                onCurrentIndexChanged: {
                    categoryRow.currentIndex = currentIndex;
                }

                // Page 0 - All
                AllPage {
                    width: contentSwipe.width
                    height: contentSwipe.height
                }

                // Page 1 - Hostels
                HostelsPage {
                    width: contentSwipe.width
                    height: contentSwipe.height
                }

                // Page 2 - Rooms
                RoomsPage {
                    width: contentSwipe.width
                    height: contentSwipe.height
                }

                // Page 3 - Houses
                HousesPage {
                    width: contentSwipe.width
                    height: contentSwipe.height
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
