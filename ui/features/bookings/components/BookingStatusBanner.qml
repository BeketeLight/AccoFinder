import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property string status: "Pending"

    readonly property string statusKey: String(status).toUpperCase()

    readonly property var style: {
        switch (statusKey) {
        case "CONFIRMED":
        case "APPROVED":
            return {
                bg: "#E6F4EA",
                iconBg: "#1E8E3E",
                iconSource: "qrc:/ui/assets/good-standing-icon.svg",
                title: qsTr("Booking confirmed"),
                subtitle: qsTr("Your reservation is confirmed."),
                titleColor: "#1E8E3E",
                subtitleColor: "#2D6A4F"
            }
        case "PENDING":
            return {
                bg: "#FEF3C7",
                iconBg: "#D97706",
                iconSource: "qrc:/ui/assets/pending-icon.svg",
                title: qsTr("Awaiting host confirmation"),
                subtitle: qsTr("The host has not confirmed this booking yet."),
                titleColor: "#B45309",
                subtitleColor: "#92400E"
            }
        case "PAID":
            return {
                bg: "#DBEAFE",
                iconBg: "#2563EB",
                iconSource: "qrc:/ui/assets/good-standing-icon.svg",
                title: qsTr("Payment received"),
                subtitle: qsTr("Waiting for the host to confirm your stay."),
                titleColor: "#1D4ED8",
                subtitleColor: "#1E40AF"
            }
        case "CANCELLED":
        case "CANCELED":
        case "REJECTED":
            return {
                bg: "#FEE2E2",
                iconBg: "#DC2626",
                iconSource: "qrc:/ui/assets/cancelled-icon.svg",
                title: qsTr("Booking cancelled"),
                subtitle: qsTr("This reservation is no longer active."),
                titleColor: "#B91C1C",
                subtitleColor: "#991B1B"
            }
        default:
            return {
                bg: "#F1F5F9",
                iconBg: "#64748B",
                iconSource: "i",
                title: status.length ? status : qsTr("Booking"),
                subtitle: qsTr("See details below."),
                titleColor: "#334155",
                subtitleColor: "#64748B"
            }
        }
    }

    Layout.fillWidth: true
    implicitHeight: row.implicitHeight + 24
    radius: 12
    color: style.bg

    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 12

        Rectangle {
            implicitWidth: 32
            implicitHeight: 32
            radius: 16
            color: root.style.iconBg
            // Text {
            //     anchors.centerIn: parent
            //     text: root.style.icon
            //     font.pixelSize: 16
            //     font.bold: true
            //     color: "#FFFFFF"
            // }
            ToolButton {
                id: statusIconButton

                anchors.centerIn: parent

                width: 32
                height: 32
                enabled: false
                icon.source: root.style.iconSource
                icon.width: 18
                icon.height: 18
                icon.color: "#FFFFFF"
                // Remove the default ToolButton background
                background: null
            }
        }

        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true
            Text {
                text: root.style.title
                font.pixelSize: 13
                font.bold: true
                color: root.style.titleColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            Text {
                text: root.style.subtitle
                font.pixelSize: 11
                color: root.style.subtitleColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}