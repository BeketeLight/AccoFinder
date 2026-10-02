import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../delegates"
import "../components"
import "../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    // Injected by HomePage — the shared PropertiesModel.
    property var propertiesModelRef: null

    // "property" → PropertyCardDelegate
    // "quarter"  → QuartersComponent
    property string renderAs: "property"

    readonly property int _columns: 3
    readonly property int _gap: 10
    readonly property int _sidePad: 5   // 0 inside the already-padded column

    // The Flow's computed height becomes this item's implicit height so
    // AppScrollablePage's column can size itself.
    implicitHeight: flow.implicitHeight

    Flow {
        id: flow
        width: parent.width
        spacing: root._gap

        // Cell width for the fixed 3-column grid.
        readonly property real cellWidth: (width - root._gap * (root._columns - 1)) / root._columns

        Repeater {
            model: root.propertiesModelRef ? root.propertiesModelRef.propertiesModel : null

            delegate: Loader {
                // The `matches` role is recomputed by PropertiesModel every
                // time the filter changes. Hide rows that don't match.
                visible: model.matches === true
                width: flow.cellWidth
                height: width * 1.73

                sourceComponent: root.renderAs === "quarter" ? quarterCard : propertyCard

                Component {
                    id: propertyCard
                    PropertyCardDelegate {
                        anchors.fill: parent
                        propertyId: model.propertyId
                        title: model.title
                        location: model.location
                        price: model.price
                        imageUrl: model.imageUrl
                        imageUrls: model.imageUrls
                        amenities: model.amenities
                        status: model.status
                        isVerified: model.isVerified
                    }
                }

                Component {
                    id: quarterCard
                    QuartersComponent {
                        anchors.fill: parent
                        quartersId: model.propertyId
                        quartersType: model.propertyType
                        quartersTitle: model.title
                        location: model.location
                        quartersPrice: model.price
                        imageUrl: model.imageUrl
                        imageUrls: model.imageUrls
                        isQuartersAvailable: model.isActive
                        onClicked: {
                            if (!AppSettings.isLoggedIn()) {
                                NavUtils.navigateToAccount();
                                return;
                            }
                            NavUtils.push(Qt.resolvedUrl("../delegates/QuartersDetailDelegate.qml"), {
                                quarterId: model.propertyId,
                                quarterTitle: model.title,
                                quarterType: model.propertyType,
                                location: model.location,
                                quarterPrice: model.price,
                                isquarterAvailable: model.isActive,
                                description: model.description,
                                roomImage: model.imageUrl
                            });
                        }
                    }
                }
            }
        }
    }
}
