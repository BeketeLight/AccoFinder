import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../models"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/pages"

Item {
    id: root

    property string pageTitle: qsTr("Agent Applications")
    property bool showHeader: true
    property bool showBack: true

    property AdminAgentApplicationsModel applicationsListModel: AdminAgentApplicationsModel {}

    function goBack() { NavUtils.pop() }

    AppScrollablePage {
        anchors.fill: parent
        loading: AgentApplicationViewModel.isLoading

        AgentApplicationsPage {
            id: appsPage
            Layout.fillWidth: true

            applicationsListModel: root.applicationsListModel

            onViewApplicationRequested: (applicationId) => {
                NavUtils.push(Qt.resolvedUrl("AgentApplicationDetailsScreen.qml"), {
                    applicationId: applicationId,
                    applicationsListModel: root.applicationsListModel
                })
            }
        }
    }
}
