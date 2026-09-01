import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../models"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Application Details")
    property bool showHeader: true
    property bool showBack: true

    property string applicationId: ""
    property AdminAgentApplicationsModel applicationsListModel: AdminAgentApplicationsModel {}

    function goBack() { NavUtils.pop() }

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: detailsPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            AgentApplicationDetailsPage {
                id: detailsPage

                Component.onCompleted: Qt.callLater(function() { console.log("AADSZ", "detailsPage", "root=" + root.width + "x" + root.height + " flick=" + flick.width + " page=" + width + " x=" + x) })
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                applicationId: root.applicationId
                applicationsListModel: root.applicationsListModel

                onApplicationApproved: NavUtils.pop()
                onApplicationRejected: NavUtils.pop()
            }
        }
    }
}
