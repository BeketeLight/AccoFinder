import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string status: ""

    readonly property string statusKey: String(status).trim().toUpperCase()

    implicitWidth: statusLabel.implicitWidth + 16
    implicitHeight: 22
    radius: 14
    color: {
        switch (statusKey) {
        case "CONFIRMED":
        case "PAID":
            return "#DCFCE7"
        case "PENDING PAYMENT":
        case "PAYMENT PROCESSING":
        case "PAYMENT FAILED":
        case "PENDING":
            return "#FEF3C7"
        case "CANCELLED":
        case "EXPIRED":
        case "REJECTED":
            return "#FEE2E2"
        default:
            return "#F1F5F9"
        }
    }

    Text {
        id: statusLabel
        anchors.centerIn: parent
        text: root.status
        font.pixelSize: 12
        font.bold: true
        color: {
            switch (root.statusKey) {
            case "CONFIRMED":
            case "PAID":
                return "#15803D"
            case "PENDING PAYMENT":
            case "PAYMENT PROCESSING":
            case "PAYMENT FAILED":
            case "PENDING":
                return "#D97706"
            case "CANCELLED":
            case "EXPIRED":
            case "REJECTED":
                return "#B91C1C"
            default:
                return "#64748B"
            }
        }
    }
}