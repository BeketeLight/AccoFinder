import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../utils/NavigationUtils.js" as NavUtils
import "../../../../components/indicators"

Item {
    id: root

    property string pageTitle: qsTr("Property Approvals")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal decisionMade(var propertyId, var title, var approved)

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: approvalsPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            PropertyApprovalPage {
                id: approvalsPage

                Component.onCompleted: Qt.callLater(function() {console.log("PASZ", "approvalsPage", "root=" + root.width + "x" + root.height + " flick=" + flick.width + " page=" + width + " x=" + x) })
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                onDecisionMade: (propertyId, title, approved) => root.decisionMade(propertyId, title, approved)
                onReviewRequested: (propertyId) => {
                    var payload = approvalsPage.listingsModel.registrationPayloadFor(propertyId, "propertyId")
                    NavUtils.push(Qt.resolvedUrl("PropertyApprovalDetailScreen.qml"), {
                        propertyPayload: payload,
                        propertyId: propertyId,
                        listingsModel: approvalsPage.listingsModel
                    })
                }
            }
        }

        // Non-blocking spinner while the pending properties are being fetched.
        AppSpinner {
            visible: PropertyViewModel.isLoading
            anchors.centerIn: parent
            z: 20
            size: 32
            lineWidth: 3
            color: "#2563EB"
            running: PropertyViewModel.isLoading
        }
    }
}
