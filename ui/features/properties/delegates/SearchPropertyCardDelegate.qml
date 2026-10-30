import QtQuick
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../home/delegates"
import "../../home/components"

// Search result card. Picks between PropertyCardDelegate (WHOLE / HOSTEL) and
// QuartersComponent (QUARTER) based on the row's propertyType.
//
// Media comes pre-populated from SearchPropertiesModel: it fires
// MediaViewModel.getMediaByProperty for each row, then writes the cover URL
// and comma-joined gallery back into the row. This delegate just reads
// imageUrl / imageUrls and forwards them.
//
// The tap destinations match home exactly:
//   • PropertyCardDelegate → PropertyDelegateDetails (who decides whether to
//     show the Book Now footer for WHOLE or the room grid for HOSTEL).
//   • QuartersComponent → QuartersDetailDelegate directly, with the same
//     6-field payload HomeListPage's quarter branch sends.
Item {
    id: root

    // ---- identity ----
    property string propertyId: ""
    property string propertyType: ""

    // ---- display ----
    property string title: ""
    property string description: ""
    property string location: ""
    property string district: ""
    property string village: ""
    property real price: 0

    // ---- media (populated by the model, not fetched here) ----
    property string imageUrl: ""
    property string imageUrls: ""

    // ---- classification ----
    property string status: ""
    property bool isVerified: false
    property bool isActive: true
    property var amenities: []
    property int roomCount: 0

    // ---- owner / landlord ----
    property string landlord: ""
    property string landlordPhone: ""
    property string ownerName: ""
    property string ownerPhone: ""

    // ---- meta ----
    property string rejectionReason: ""
    property string createdAt: ""

    readonly property bool isQuarter: String(root.propertyType).toUpperCase() === "QUARTER"

    Loader {
        anchors.fill: parent
        sourceComponent: root.isQuarter ? quarterCard : propertyCard

        Component {
            id: propertyCard
            PropertyCardDelegate {
                anchors.fill: parent
                propertyId: root.propertyId
                propertyType: root.propertyType
                title: root.title
                location: root.location
                price: root.price
                imageUrl: root.imageUrl
                imageUrls: root.imageUrls
                amenities: root.amenities
                status: root.status
                isVerified: root.isVerified
                insideInfoSection: false
                isInfoSectionVisible: true
            }
        }

        Component {
            id: quarterCard
            QuartersComponent {
                anchors.fill: parent
                quartersId: root.propertyId
                quartersType: root.propertyType
                quartersTitle: root.title
                location: root.location
                quartersPrice: root.price
                isQuartersAvailable: root.isActive
                imageUrl: root.imageUrl

                onClicked: {
                    if (!AppSettings.isLoggedIn()) {
                        NavUtils.navigateToAccount();
                        return;
                    }
                    NavUtils.push("qrc:/qt/qml/AccoFinder/ui/features/home/delegates/QuartersDetailDelegate.qml", {
                        quarterId: root.propertyId,
                        quarterTitle: root.title,
                        quarterType: root.propertyType,
                        location: root.location,
                        quarterPrice: root.price,
                        isquarterAvailable: root.isActive
                    });
                }
            }
        }
    }
}
