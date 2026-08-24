import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../properties/components"
import "../../models"

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

    function statusVariant(status) {
        if (status === "Completed" || status === "Paid" || status === "Settled") return "success"
        if (status === "Pending" || status === "Due") return "warning"
        return "danger"
    }

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
                valueText: "MK " + Number(root.paymentsModel.totalCollected).toLocaleString()
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
                valueText: "MK " + Number(root.paymentsModel.commissionsDue).toLocaleString()
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
                        text: parent.model.label
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

                delegate: Rectangle {
                    id: payRow
                    required property var model
                    required property int index
                    Layout.fillWidth: true
                    implicitHeight: payContent.implicitHeight + 20
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1

                    ColumnLayout {
                        id: payContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                Layout.fillWidth: true
                                text: payRow.model.paymentId + " · MK " + Number(payRow.model.amount).toLocaleString()
                                color: "#111827"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            StatusChip {
                                textValue: payRow.model.status
                                variant: root.statusVariant(payRow.model.status)
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: payRow.model.user + " · " + payRow.model.kind
                            color: root.mutedColor
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                Layout.fillWidth: true
                                text: payRow.model.method + " · " + payRow.model.date
                                color: root.mutedColor
                                font.pixelSize: 11
                            }

                            Button {
                                id: payActionButton
                                visible: payRow.model.status === "Pending" || payRow.model.status === "Disputed"
                                Layout.preferredHeight: 28
                                text: payRow.model.status === "Pending" ? qsTr("Mark completed")
                                      : payRow.model.status === "Disputed" ? qsTr("Flag issue") : ""

                                contentItem: Label {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: payActionButton.text
                                    color: payRow.model.status === "Pending" ? "#166534" : "#B45309"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                background: Rectangle {
                                    radius: 14
                                    color: payActionButton.down ? "#F3F4F6" : "#F9FAFB"
                                    border.color: "#E5E7EB"
                                    border.width: 1
                                }

                                onClicked: {
                                    if (payRow.model.status === "Pending") {
                                        root.paymentsModel.setPaymentStatus(payRow.model.paymentId, "Completed")
                                        console.log("Payment settled:", payRow.model.paymentId)
                                        root.paymentAction("settled", payRow.model.paymentId)
                                    } else {
                                        console.log("Payment flagged for review:", payRow.model.paymentId)
                                        root.paymentAction("flagged", payRow.model.paymentId)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---- Commissions tab ----
        ColumnLayout {
            visible: root.activeTab === "COMMISSIONS"
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.paymentsModel.commissionsModel

                delegate: Rectangle {
                    id: commRow
                    required property var model
                    required property int index
                    Layout.fillWidth: true
                    implicitHeight: commContent.implicitHeight + 20
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1

                    ColumnLayout {
                        id: commContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                Layout.fillWidth: true
                                text: commRow.model.agent + " · MK " + Number(commRow.model.amount).toLocaleString()
                                color: "#111827"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            StatusChip {
                                textValue: commRow.model.status
                                variant: root.statusVariant(commRow.model.status)
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("%1 bookings in %2 · %3% rate").arg(commRow.model.bookings).arg(commRow.model.area).arg(commRow.model.rate)
                            color: root.mutedColor
                            font.pixelSize: 11
                        }

                        Button {
                            id: settleButton
                            visible: commRow.model.status === "Due"
                            Layout.preferredHeight: 28
                            Layout.alignment: Qt.AlignRight
                            text: qsTr("Settle now")

                            contentItem: Label {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: settleButton.text
                                color: "#166534"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            background: Rectangle {
                                radius: 14
                                color: settleButton.down ? "#DCFCE7" : "#F0FDF4"
                                border.color: "#BBF7D0"
                                border.width: 1
                            }

                            onClicked: {
                                root.paymentsModel.setCommissionStatus(commRow.model.agent, "Settled")
                                console.log("Commission settled:", commRow.model.agent)
                                root.paymentAction("commission-settled", commRow.model.agent)
                            }
                        }
                    }
                }
            }
        }

        // ---- Payouts tab ----
        ColumnLayout {
            visible: root.activeTab === "PAYOUTS"
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.paymentsModel.payoutsModel

                delegate: Rectangle {
                    id: payoutRow
                    required property var model
                    required property int index
                    Layout.fillWidth: true
                    implicitHeight: payoutContent.implicitHeight + 20
                    radius: 12
                    color: "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1

                    ColumnLayout {
                        id: payoutContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                Layout.fillWidth: true
                                text: payoutRow.model.landlord + " · MK " + Number(payoutRow.model.amount).toLocaleString()
                                color: "#111827"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            StatusChip {
                                textValue: payoutRow.model.status
                                variant: root.statusVariant(payoutRow.model.status)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Label {
                                Layout.fillWidth: true
                                text: payoutRow.model.property + " · " + payoutRow.model.period
                                color: root.mutedColor
                                font.pixelSize: 11
                            }

                            Button {
                                id: releaseButton
                                visible: payoutRow.model.status === "Pending"
                                Layout.preferredHeight: 28
                                text: qsTr("Release payout")

                                contentItem: Label {
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: releaseButton.text
                                    color: "#166534"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                background: Rectangle {
                                    radius: 14
                                    color: releaseButton.down ? "#DCFCE7" : "#F0FDF4"
                                    border.color: "#BBF7D0"
                                    border.width: 1
                                }

                                onClicked: {
                                    root.paymentsModel.setPayoutStatus(payoutRow.model.landlord, "Paid")
                                    console.log("Payout released:", payoutRow.model.landlord)
                                    root.paymentAction("payout-released", payoutRow.model.landlord)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
