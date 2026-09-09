import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/pages"

Item {
    id: root

    property string pageTitle: qsTr("Agent Management")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal agentUpdated(var agentId)

    AppScrollablePage {
        anchors.fill: parent
        loading: AgentViewModel.isLoading

        AgentManagementPage {
            id: agentsPage
            Layout.fillWidth: true

            onPromoteAgentRequested: NavUtils.push(Qt.resolvedUrl("UserManagementScreen.qml"))
            onAgentUpdated: (agentId) => root.agentUpdated(agentId)
        }
    }
}
