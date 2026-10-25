import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: reservationCard
    property string cardTitle: "Room & Date Info"
    property string cardIcon: "qrc:/ui/assets/reservation-icon.svg"
    property int customIconHeight: 12
    property int custonIconWidth: 12
    property string bookingDateLabel: "Booking date"
    property string bookingDate: ""
    property string roomTypeLabel: "Room Type"
    property string roomType: ""

    Layout.fillWidth: true
    implicitHeight: resCol.implicitHeight + 24
    radius: 12
    color: "#FFFFFF"
    border.color: "#E2E8F0"
    border.width: 1

    ColumnLayout {
        id: resCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 4

        // Card Header
        RowLayout {
            spacing: 0
            ToolButton {
                implicitHeight: 24
                implicitWidth: 24
                icon.source: reservationCard.cardIcon
                icon.height: reservationCard.customIconHeight
                icon.width: reservationCard.custonIconWidth
                background: Rectangle{
                    radius: 12
                    color: "#DBEAFE"//"#EFF6FF"
                }
            }
            Text {
                text: reservationCard.cardTitle
                font.pixelSize: 14
                font.bold: true
                color: "#0F172A"
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Rectangle {
                id: leftAccent
                Layout.leftMargin: 8
                Layout.preferredWidth: 5
                Layout.fillHeight: true
                color: "#2563EB"
                radius: 3
            }
            ColumnLayout{
                Layout.fillWidth: true

                RowLayout{
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: reservationCard.bookingDateLabel
                        font.pixelSize: 13
                        color: "#64748B"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: reservationCard.bookingDate
                        font.pixelSize: 12
                        font.bold: true
                        color: "#0F172A"
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: reservationCard.roomTypeLabel
                        font.pixelSize: 13
                        color: "#64748B"//"#0F172A"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: reservationCard.roomType
                        font.pixelSize: 12
                        font.bold: true
                        color: "#0F172A"
                    }
                }
            }
        } 
    }
}