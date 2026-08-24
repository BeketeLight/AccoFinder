import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("User Management")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal userToggled(var userId, var name, var active)

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: page.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            UserManagementPage {
                id: page

                Component.onCompleted: Qt.callLater(function() {console.log("UMSZ", "page", "root=" + root.width + "x" + root.height + " flick=" + flick.width + " page=" + width + " x=" + x) })
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                onUserToggled: (userId, name, active) => root.userToggled(userId, name, active)
            }
        }
    }
}
