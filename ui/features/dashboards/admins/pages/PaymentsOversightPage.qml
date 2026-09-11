import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../models"
import "../../../../utils/Utils.js" as Utils
import "../delegates"

Item {
    id: root

    property AdminPaymentsModel paymentsModel: AdminPaymentsModel {}
    property string pageTitle: qsTr("Payments")

    signal paymentAction(var action, var reference)

    implicitWidth: 400
    implicitHeight: contentColumn.implicitHeight

    readonly property color primaryColor: "#2563EB"
    readonly property color successColor: "#16A34A"
    readonly property color warningColor: "#D97706"
    readonly property color dangerColor: "#DC2626"
    readonly property color mutedColor: "#6B7280"

    property string activeTab: "PAYMENTS"   // PAYMENTS | COMMISSIONS | PAYOUTS

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            StatCard {
                lableFontSize: 18
                Layout.fillWidth: true
                label: qsTr("Collected")
                valueText: Utils.formatCurrency(root.paymentsModel.totalCollected)
                accentColor: root.successColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Pending payments")
                valueText: String(root.paymentsModel.pendingCount)
                accentColor: root.warningColor
            }
            StatCard {
                lableFontSize: 18
                Layout.fillWidth: true
                label: qsTr("Commissions due")
                valueText: Utils.formatCurrency(root.paymentsModel.commissionsDue)
                accentColor: root.primaryColor
            }
            StatCard {
                Layout.fillWidth: true
                label: qsTr("Payouts pending")
                valueText: String(root.paymentsModel.payoutsPending)
                accentColor: root.dangerColor
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { key: "PAYMENTS", label: qsTr("Payments") },
                    { key: "COMMISSIONS", label: qsTr("Commissions") },
                    { key: "PAYOUTS", label: qsTr("Payouts") }
                ]

                delegate: Button {
                    required property var model
                    readonly property bool isCurrent: root.activeTab === model.key
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    padding: 0

                    contentItem: Label {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: model.label
                        color: parent.isCurrent ? "#FFFFFF" : "#374151"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    background: Rectangle {
                        radius: 16
                        color: parent.isCurrent ? root.primaryColor : "#FFFFFF"
                        border.color: parent.isCurrent ? root.primaryColor : "#E5E7EB"
                    }

                    onClicked: root.activeTab = model.key
                }
            }
        }

        // ---- Payments tab ----
        ColumnLayout {
            visible: root.activeTab === "PAYMENTS"
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.paymentsModel.paymentsModel

                delegate: PaymentRowDelegate {
                    paymentId: model.paymentId
                    amount: model.amount
                    status: model.status
                    user: model.user
                    kind: model.kind
                    method: model.method
                    date: model.date
                    onActionRequested: (paymentId, kind) => {
                        if (kind === "settled") {
                            root.paymentsModel.setPaymentStatus(paymentId, "Completed")
                            console.log("Payment settled:", paymentId)
                            root.paymentAction("settled", paymentId)
                        } else {
                            console.log("Payment flagged for review:", paymentId)
                            root.paymentAction("flagged", paymentId)
                        }
                    }
                }
            }

            Label {
                visible: root.paymentsModel.paymentsModel.count === 0
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("No payments recorded yet.")
                color: root.mutedColor
                font.pixelSize: 12
                topPadding: 8
            }
        }

        // ---- Commissions tab ----
        ColumnLayout {
            visible: root.activeTab === "COMMISSIONS"
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.paymentsModel.commissionsModel

                delegate: CommissionRowDelegate {
                    agent: model.agent
                    amount: model.amount
                    status: model.status
                    bookings: model.bookings
                    area: model.area
                    rate: model.rate
                    onSettleRequested: (agent) => {
                        root.paymentsModel.setCommissionStatus(agent, "Settled")
                        console.log("Commission settled:", agent)
                        root.paymentAction("commission-settled", agent)
                    }
                }
            }

            Label {
                visible: root.paymentsModel.commissionsModel.count === 0
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("No commissions due yet.")
                color: root.mutedColor
                font.pixelSize: 12
                topPadding: 8
            }
        }

        // ---- Payouts tab ----
        ColumnLayout {
            visible: root.activeTab === "PAYOUTS"
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.paymentsModel.payoutsModel

                delegate: PayoutRowDelegate {
                    landlord: model.landlord
                    amount: model.amount
                    status: model.status
                    propertyName: model.property
                    period: model.period
                    onReleaseRequested: (landlord) => {
                        root.paymentsModel.setPayoutStatus(landlord, "Paid")
                        console.log("Payout released:", landlord)
                        root.paymentAction("payout-released", landlord)
                    }
                }
            }

            Label {
                visible: root.paymentsModel.payoutsModel.count === 0
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("No payouts scheduled yet.")
                color: root.mutedColor
                font.pixelSize: 12
                topPadding: 8
            }
        }
    }
}
