import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: paymentCard
    property string cardTitle: "Payment Summary"
    property string cardIcon: "qrc:/ui/assets/payment-icon.svg"
    property int customIconHeight: 12
    property int customIconWidth: 12
    property string roomPrice: "0"
    property string   totalAmount: ""
    property string commission: ""
    property string currencySymbol: "MK"
    Layout.fillWidth: true
    implicitHeight: payCol.implicitHeight + 24
    radius: 12
    color: "#FFFFFF"
    border.color: "#E2E8F0"
    border.width: 1

    ColumnLayout {
        id: payCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 4

        // Card Header
        RowLayout {
            spacing: 0
            ToolButton {
                icon.source: paymentCard.cardIcon
                icon.height: paymentCard.customIconHeight
                icon.width: paymentCard.customIconWidth
                background: null
            }
            Text {
                text: paymentCard.cardTitle
                font.pixelSize: 14
                font.bold: true
                color: "#0F172A"
            }
        }
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Room price"; font.pixelSize: 12; color: "#64748B" }
                    Item { Layout.fillWidth: true }
                    Text { text: paymentCard.currencySymbol + paymentCard.roomPrice; font.pixelSize: 12; font.bold: true; color: "#0F172A" }
                }
            }
        }
        // Commission row collapse if empty
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: paymentCard.commission !== "" && paymentCard.commission !== "0"

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Agent Commission"; font.pixelSize: 12; color: "#64748B" }
                Item { Layout.fillWidth: true }
                Text { text: paymentCard.currencySymbol + paymentCard.commission; font.pixelSize: 12; font.bold: true; color: "#16A34A" } // Green accent for commission
            }
        }
        // Separator Line
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: "#F1F5F9"
        }
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Total"; font.pixelSize: 13; font.bold: true; color: "#0F172A" }
            Item { Layout.fillWidth: true }
            Text {
                text: paymentCard.currencySymbol + paymentCard.totalAmount
                font.pixelSize: 13
                font.bold: true
                color: "#0F172A"
            }
        }
    }
}