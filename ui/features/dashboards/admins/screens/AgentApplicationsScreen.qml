import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../models"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Agent Applications")
    property bool showHeader: true
    property bool showBack: true

    property AdminAgentApplicationsModel applicationsListModel: AdminAgentApplicationsModel {}
    property AdminUsersModel usersModel: AdminUsersModel {}
    property AdminAgentsModel agentsModel: AdminAgentsModel {}

    function goBack() { NavUtils.pop() }

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: appsPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            AgentApplicationsPage {
                id: appsPage

                Component.onCompleted: Qt.callLater(function() { console.log("AASZ", "appsPage", "root=" + root.width + "x" + root.height + " flick=" + flick.width + " page=" + width + " x=" + x) })
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                applicationsListModel: root.applicationsListModel

                onViewApplicationRequested: (applicationId) => {
                    NavUtils.push(Qt.resolvedUrl("AgentApplicationDetailsScreen.qml"), {
                        applicationId: applicationId,
                        applicationsListModel: root.applicationsListModel,
                        usersModel: root.usersModel,
                        agentsModel: root.agentsModel
                    })
                }
            }
        }
    }
}
