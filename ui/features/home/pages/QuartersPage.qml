import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../delegates"
import "../models"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    // Injected by HomePage — the one shared PropertiesModel.
    property var propertiesModelRef: null

    function navigateToQuarters(quartersData) {
        //console.log(JSON.stringify(quartersData));
        NavUtils.push(Qt.resolvedUrl("../delegates/QuartersDetailDelegate.qml"), {
            quarterId: quartersData.propertyId,
            quarterTitle: quartersData.title,
            quarterType: quartersData.propertyType,
            location: quartersData.location,
            quarterPrice: quartersData.price,
            isquarterAvailable: quartersData.isActive,
            description: quartersData.description,
            roomImage: quartersData.imageUrl
        });
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: col.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: 0

            Label {
                text: "Quarters"
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
                    QuartersComponent {
                        width: (flow.width - 24 - 16) / 3
                        height: width * 1.25
                        quartersId: model.propertyId
                        quartersType: model.propertyType
                        quartersTitle: model.title
                        location: model.location
                        quartersPrice: model.price
                        imageUrl: model.imageUrl
                        imageUrls: model.imageUrls
                        isQuartersAvailable: model.isActive
                        onClicked: {
                            root.navigateToQuarters(model);
                        }
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
