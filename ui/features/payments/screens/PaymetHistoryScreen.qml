// features/payments/screens/PaymetHistoryScreen.qml
import QtQuick 2.15
import "../pages"
import "../models"

// If AppSettings is a QML singleton, uncomment and adjust:
// import AccoFinder.AppSettings 1.0

Item {
    id: root

    // Wraps PaymentController.paymentListModel into a QML ListModel
    PaymentsModel {
        id: paymentsModel
    }

    PaymentsHistoryPage {
        anchors.fill: parent
        paymentsListModel: paymentsModel.paymentsModel
        onRefreshRequested: PaymentController.refreshForUser(AppSettings.userId)
    }

    Component.onCompleted: {
        if (AppSettings && AppSettings.userId)
            PaymentController.refreshForUser(AppSettings.userId);
    }
}
