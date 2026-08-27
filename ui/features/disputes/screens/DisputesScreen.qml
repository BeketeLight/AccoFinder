import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"

Item {
    id: root

    property string pageTitle: qsTr("Open disputes")
    property bool showHeader: true
    property bool showBack: true

    Component.onCompleted: {
        DisputesListViewModel.getDisputes()
    }

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: disputesPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            DisputesPage {
                id: disputesPage
                x: Math.max(12, (flick.width - width) / 2)
                y: 24
                width: Math.min(flick.width - 24, 520)
            }
        }
    }
}
