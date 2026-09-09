import QtQuick
import QtQuick.Layouts
import "../pages"
import "../../../../components/pages"
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

    AppScrollablePage {
        anchors.fill: parent
        loading: PaymentsOverviewViewModel.isLoading

        PaymentsOversightPage {
            id: paymentsPage
            Layout.fillWidth: true

            onPaymentAction: (action, reference) => root.paymentAction(action, reference)
        }
    }

    Component.onCompleted: root.refresh()
}
