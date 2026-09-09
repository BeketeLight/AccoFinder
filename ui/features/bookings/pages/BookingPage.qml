import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
import "../../home/components"
import "../../../components/cards"

Page {
    id: root
    anchors.fill: parent
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color  easyBlueColor: "#EEF2FF"
    readonly property color  textColor: "#0F172A"
    readonly property color  helloCardBgColor: "#E0F2FE"
    readonly property color  cardBgColor: "#EEF2FF"

        // ===== SCROLLABLE CONTENT =====
        ScrollView {
            anchors.fill: parent
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: root.width
                spacing: 16
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 0
                    Layout.preferredHeight: 2
                    color: root.primaryColor
                    radius: 4   
                }
                 Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "#FFFFFF"
                    ColumnLayout{
                        Layout.fillWidth: true
                        spacing: 10

                        RowLayout{
                            Layout.fillWidth: true
                            spacing: 0
                            Rectangle {
                                Layout.preferredWidth: 5
                                Layout.leftMargin:4
                                Layout.rightMargin: 0
                                Layout.topMargin: 0
                                Layout.preferredHeight: 40
                                color: root.primaryColor
                                radius: 4
                            }
                            Text{
                                text: qsTr("My Bookings")
                                font.pointSize: 18
                                font.bold: true
                                color: "#1E293B"
                                Layout.leftMargin: 10
                            }
                            Item{
                                Layout.preferredWidth: 180
                            }
                            Text{
                                text: qsTr("View all")
                                font.pointSize: 14
                                font.bold: true
                                color: "#4F46E5"
                                Layout.leftMargin: 10
                                MouseArea{
                                    anchors.fill: parent
                                }
                            }
                        }

                        RowLayout{
                            spacing: 2
                            BookingsStatusCard {
                                cardWidth: 100
                                cardHeight: 90
                                title: "Pending"
                                iconBgColor: "#F59E0B"
                                cardBgColor: root.cardBgColor
                                iconSource: "qrc:/ui/assets/pending-icon.svg"
                                isSelected: statusGrid.activeFilter === "pending"
                                onClicked: statusGrid.activeFilter = "pending"
                                Layout.leftMargin:16
                                Layout.alignment: Qt.AlignHCenter
                            }
                            BookingsStatusCard {
                                cardWidth: 100
                                cardHeight: 90
                                title: "Confirmed"
                                iconBgColor: "#10B981"
                                cardBgColor: root.cardBgColor
                                iconSource: "qrc:/ui/assets/good-standing-icon.svg"
                                isSelected: statusGrid.activeFilter === "confirmed"
                                onClicked: statusGrid.activeFilter = "confirmed"
                                Layout.leftMargin:16
                                Layout.alignment: Qt.AlignHCenter
                            }
                            BookingsStatusCard {
                                cardWidth: 100
                                cardHeight: 90
                                title: "Cancelled"
                                iconBgColor: "#EF4444"
                                cardBgColor:root.cardBgColor
                                iconSource: "qrc:/ui/assets/cancelled-icon.svg"
                                isSelected: statusGrid.activeFilter === "cancelled"
                                onClicked: statusGrid.activeFilter = "cancelled"
                                Layout.leftMargin:16
                                Layout.alignment: Qt.AlignHCenter
                                //Layout.alignment: Qt.AlignTop
                            }
                        }

                    }
                }
                 Rectangle {
                     Layout.preferredWidth: 80
                     Layout.leftMargin: 16
                     Layout.rightMargin: 16
                     Layout.topMargin: 0
                     Layout.preferredHeight: 2
                     Layout.alignment: Qt.AlignHCenter
                     color: root.primaryColor
                     radius: 4
                 }
                 Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "#FFFFFF"

                    ColumnLayout{
                        Layout.fillWidth: true
                        spacing: 10
                        RowLayout{
                            Layout.fillWidth: true
                            spacing: 0
                            Rectangle {
                                Layout.preferredWidth: 5
                                Layout.leftMargin:4
                                Layout.rightMargin: 0
                                Layout.topMargin: 0
                                Layout.preferredHeight: 40
                                color: root.primaryColor
                                radius: 4
                            }
                            Text{
                                text: qsTr("Bookings disputes")
                                font.pointSize: 18
                                font.bold: true
                                color: "#1E293B"
                                Layout.leftMargin: 10
                            }
                        }

                        RowLayout{
                            spacing: 2
                            BookingsStatusCard {
                                cardWidth: 300
                                cardHeight: 90
                                title: "Active disputes"
                                iconBgColor: "#06B6D4"
                                cardBgColor: root.cardBgColor
                                iconSource: "qrc:/ui/assets/disputes-icon.svg"
                                isSelected: statusGrid.activeFilter === "pending"
                                onClicked: statusGrid.activeFilter = "pending"
                                Layout.leftMargin:16
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                    }
                }
                 }

                 // ToolButton{
                 //    implicitHeight: 100
                 //    implicitWidth: 100
                 //    icon.source: "qrc:/ui/assets/your-bookings-icon.svg"
                 //    icon.height: 100
                 //    icon.width: 100
                 //    background: null
                 //    //icon.color: "yellowgreen"
                 //    Layout.alignment: Qt.AlignHCenter
                 //    Layout.bottomMargin: 16
                 // }
                 // Text{
                 //    text: qsTr("Here is your bookings overview")
                 //    font.pointSize: 16
                 //    font.bold: true
                 //    Layout.alignment: Qt.AlignHCenter
                 // }
                 //        BookingsStatusCard {
                 //            cardWidth: 80
                 //            cardHeight: 80
                 //            title: "Pending"
                 //            iconBgColor: "#F59E0B"
                 //            cardBgColor: cardBgColor
                 //            iconSource: "qrc:/ui/assets/pending-icon.svg"
                 //            isSelected: statusGrid.activeFilter === "pending"
                 //            onClicked: statusGrid.activeFilter = "pending"
                 //            Layout.leftMargin:16
                 //            Layout.alignment: Qt.AlignHCenter
                 //        }



                 //        BookingsStatusCard {
                 //            cardWidth: 80
                 //            cardHeight: 80
                 //            title: "Cancelled"
                 //            //iconBgColor: "#EF4444"
                 //            cardBgColor: cardBgColor
                 //            iconSource: "qrc:/ui/assets/cancelled-icon.svg"
                 //            isSelected: statusGrid.activeFilter === "cancelled"
                 //            onClicked: statusGrid.activeFilter = "cancelled"
                 //            Layout.leftMargin:16
                 //            Layout.alignment: Qt.AlignHCenter
                 //        }

                 //        BookingsStatusCard {
                 //            cardWidth: 80
                 //            cardHeight: 80
                 //            Layout.preferredHeight: 70
                 //            title: "Total Spent"
                 //            iconBgColor: "#8B5CF6"
                 //            cardBgColor: "#EEF2FF"
                 //            iconSource: "qrc:/ui/assets/ic_wallet.svg"
                 //            Layout.leftMargin:16
                 //            Layout.alignment: Qt.AlignHCenter
                 //        }

                 //        BookingsStatusCard {
                 //            Layout.preferredWidth:300
                 //            Layout.preferredHeight: 70
                 //            title: "Active Disputes"
                 //            iconBgColor: "#06B6D4"
                 //            cardBgColor: "#E0F2FE"
                 //            iconSource: "qrc:/ui/assets/ic_dispute.svg"
                 //            Layout.leftMargin:16
                 //            Layout.alignment: Qt.AlignHCenter
                 //        }
            }
        }


//}
