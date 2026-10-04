import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/pages"

Item {
    id: root

    property string pageTitle: qsTr("Property Approvals")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal decisionMade(var propertyId, var title, var approved)

    AppScrollablePage {
        anchors.fill: parent
        // Also cover the owner walk that fills the verification queue: the
        // queue is not part of the shared property list, so isLoading alone
        // would stop spinning while the page is still empty.
        loading: PropertyViewModel.isLoading || approvalsPage.queueLoading

        PropertyApprovalPage {
            id: approvalsPage
            Layout.fillWidth: true

            onDecisionMade: (propertyId, title, approved) => root.decisionMade(propertyId, title, approved)
            onReviewRequested: (propertyId) => {
                var payload = approvalsPage.listingsModel.registrationPayloadFor(propertyId, "propertyId")
                NavUtils.push(Qt.resolvedUrl("PropertyApprovalDetailScreen.qml"), {
                    propertyPayload: payload,
                    propertyId: propertyId,
                    listingsModel: approvalsPage.listingsModel
                })
            }
        }
    }
}
