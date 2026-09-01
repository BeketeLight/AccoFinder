import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../pages"
import "../../../../components/indicators"
import "../../../../utils/NavigationUtils.js" as NavUtils

Item {
    id: root

    property string pageTitle: qsTr("Payments Oversight")
    property bool showHeader: true
    property bool showBack: true

    function goBack() { NavUtils.pop() }

    signal paymentAction(var action, var reference)

    function refresh() {
        PaymentsOverviewViewModel.refresh()
    }

    Page {
        anchors.fill: parent
        background: Rectangle { color: "#F8FAFC" }


        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: paymentsPage.implicitHeight + 48
            clip: true

            ScrollBar.vertical: ScrollBar { }

            PaymentsOversightPage {
                id: paymentsPage

                Component.onCompleted: Qt.callLater(function() {console.log("POSZ", "paymentsPage", "root=" + root.width + "x" + root.height + " flick=" + flick.width + " page=" + width + " x=" + x) })
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                width: flick.width > 48 ? Math.min(flick.width - 24, 520) : implicitWidth

                onPaymentAction: (action, reference) => root.paymentAction(action, reference)
            }
        }

        // Non-blocking spinner while the payments overview is being fetched.
        AppSpinner {
            visible: PaymentsOverviewViewModel.isLoading
            anchors.centerIn: parent
            z: 20
            size: 32
            lineWidth: 3
            color: "#2563EB"
            running: PaymentsOverviewViewModel.isLoading
        }
    }

    Component.onCompleted: root.refresh()
}
