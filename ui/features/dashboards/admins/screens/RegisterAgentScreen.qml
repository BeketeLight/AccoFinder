import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Register Agent")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal agentRegistered(var payload)

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: regPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            RegisterAgentPage {
                id: regPage

                Component.onCompleted: Qt.callLater(function() {console.log("RASZ", "regPage", "root=" + root.width + "x" + root.height + " flick=" + flick.width + " page=" + width + " x=" + x) })
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                onAgentRegistered: (payload) => root.agentRegistered(payload)
            }
        }
    }
}
