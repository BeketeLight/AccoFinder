import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../utils/Utils.js" as UtilsModule

Item {
    id: root

    property string pageTitle: qsTr("Review property")
    property bool showHeader: true
    property bool showBack: true

    property var propertyPayload: null
    property string propertyId: ""
    property var listingsModel: null

    signal decisionMade(var propertyId, var title, var approved)

    function goBack() { NavUtils.pop() }

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        PropertyApprovalDetailPage {
            id: detailPage
            anchors.fill: parent

            propertyPayload: root.propertyPayload
            propertyId: root.propertyId
            listingsModel: root.listingsModel

            onDecisionMade: (propertyId, title, approved) => root.decisionMade(propertyId, title, approved)
            onGoBackRequested: root.goBack()

            // Fired only once the backend has confirmed the delete, so this can
            // safely navigate. Drop the property's images from the local cache
            // first so a removed property can never be shown from a stale copy.
            // Guarded for the same reason as the agent detail screen: cache
            // invalidation must never block the navigation below.
            onPropertyDeleted: {
                try {
                    if (UtilsModule && typeof UtilsModule.invalidateImages === "function")
                        UtilsModule.invalidateImages(detailPage.propPhotos)
                } catch (err) {
                    console.log("PropertyApprovalDetailScreen: cache invalidation skipped:", err)
                }
                root.goBack()
            }
        }
    }
}
