import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/pages"

Item {
    id: root

    property string pageTitle: qsTr("Dispute Management")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal disputeResolved(var disputeId)
    signal disputeRejected(var disputeId)

    AppScrollablePage {
        anchors.fill: parent
        loading: DisputesListViewModel.isLoading

        DisputesManagementPage {
            id: disputesPage
            Layout.fillWidth: true

            onDisputeResolved: (disputeId) => root.disputeResolved(disputeId)
            onDisputeRejected: (disputeId) => root.disputeRejected(disputeId)
        }
    }
}
