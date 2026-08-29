import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Review property")
    property bool showHeader: true
    property bool showBack: true

    property var propertyPayload: null
    property string propertyId: ""
    property var listingsModel: null

    signal decisionMade(var propertyId, var title, var approved)

    function goBack() { NavUtils.pop() }

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }

        header: ToolBar {
            background: Rectangle { color: "#FFFFFF" }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 16
                spacing: 4

                ToolButton {
                    text: qsTr("←")
                    font.pixelSize: 20
                    onClicked: root.goBack()
                }

                Label {
                    Layout.fillWidth: true
                    text: root.pageTitle
                    font.pixelSize: 18
                    font.bold: true
                    color: "#1F2937"
                    elide: Text.ElideRight
                }
            }
        }

        PropertyApprovalDetailPage {
            id: detailPage
            anchors.fill: parent

            propertyPayload: root.propertyPayload
            propertyId: root.propertyId
            listingsModel: root.listingsModel

            onDecisionMade: (propertyId, title, approved) => root.decisionMade(propertyId, title, approved)
            onGoBackRequested: root.goBack()
        }
    }
}
