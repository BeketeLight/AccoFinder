import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/pages"

Item {
    id: root

    property string pageTitle: qsTr("Announcements")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal announcementSent(var payload)

    AppScrollablePage {
        anchors.fill: parent

        SystemNotificationsPage {
            id: notifPage
            Layout.fillWidth: true

            onAnnouncementSent: (payload) => root.announcementSent(payload)
        }
    }
}
