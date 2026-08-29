import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/indicators"

Item {
    id: root

    property string pageTitle: qsTr("Agent Management")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal createAgentRequested()
    signal agentUpdated(var agentId)

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: agentsPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            AgentManagementPage {
                id: agentsPage

                Component.onCompleted: Qt.callLater(function() {console.log("AGSZ", "agentsPage", "root=" + root.width + "x" + root.height + " flick=" + flick.width + " page=" + width + " x=" + x) })
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                onCreateAgentRequested: NavUtils.push(Qt.resolvedUrl("RegisterAgentScreen.qml"))
                onAgentUpdated: (agentId) => root.agentUpdated(agentId)
            }
        }

        // Non-blocking spinner while the agent list is being fetched.
        AppSpinner {
            visible: AgentViewModel.isLoading
            anchors.centerIn: parent
            z: 20
            size: 32
            lineWidth: 3
            color: "#2563EB"
            running: AgentViewModel.isLoading
        }
    }
}
