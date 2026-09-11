import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../delegates"
import "../models"

Item {
    id: root

    // Injected by HomePage — the one shared PropertiesModel.
    property var propertiesModelRef: null


    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: col.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: 3

            SuperDeals {
                width: parent.width
                cardWidth: 190
                cardHeight: 140
                infoSectionVisible: false
                model: PropertyListModel {}
            }

            Rectangle {
                width: parent.width
                height: 8
                color: "#F5F5F5"
            }

            Label {
                text: "All Properties"
                font.pixelSize: 16
                font.bold: true
                color: "#1F2937"
                leftPadding: 16
                topPadding: 12
                bottomPadding: 8
            }

            Flow {
                id: flow
                width: parent.width
                leftPadding: 12
                rightPadding: 12
                spacing: 8

                Repeater {
                    model: root.propertiesModelRef ? root.propertiesModelRef.propertiesModel : null

                    PropertyCardDelegate {
                        width: (flow.width - 24 - 16) / 3
                        height: width * 1.25
                        propertyId: model.propertyId
                        title: model.title
                        location: model.location
                        price: model.price
                        imageUrl: model.imageUrl
                        amenities:model.amenities
                        status: model.status
                        isVerified: model.isVerified
                    }
                }
            }

            Item {
                width: 1
                height: 80
            }
        }
    }
}
