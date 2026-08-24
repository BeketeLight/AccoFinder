import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Announcements")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal announcementSent(var payload)

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: notifPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            SystemNotificationsPage {
                id: notifPage
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                onAnnouncementSent: (payload) => root.announcementSent(payload)
            }
        }
    }
}
