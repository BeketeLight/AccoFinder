// import QtQuick
// import QtQuick.Controls
// import QtQuick.Layouts
// import "../../../utils" as UtilsModule
// import "../../home/components"
// import "../../../components/cards"
// Page{
//     id:root
//     anchors.fill: parent

//         ColumnLayout{
//             spacing: 8
//             width: root.width
//             Rectangle{
//                 Layout.fillWidth: true
//                                 Layout.leftMargin: 16
//                                 Layout.rightMargin: 16
//                                 Layout.topMargin: 16
//                                 Layout.bottomMargin: 16
//                 width: root.width
//                 implicitHeight: 20
//                 color: "red"
//             }
//             ScrollView{
//                 Layout.fillHeight: true
//                 Layout.fillWidth: true
//                 contentWidth: availableWidth
//                 //anchors.topMargin: 10
//                 clip: true

//                 ColumnLayout {
//                                 width: root.width
//                                 spacing: 16
//                 }
//         //     Rectangle{
//         //         // Layout.fillWidth: true
//         //         // Layout.leftMargin: 16
//         //         // Layout.rightMargin: 16
//         //         // //anchors.topMargin: 10
//         //         // color: "blue"         // Very subtle light gray/blue container background
//         //         //     radius: 16
//         //         //     border.color: "#F1F5F9"   // Delicate border outline

//         //         //     // Auto-calculate height based on grid contents + margins
//         //         //     height: statusGrid.implicitHeight + 24
//         //         // //implicitWidth: 380
//         //         // //implicitHeight: 200
//         //         // //radius: 10
//         //         // //color: "lightblue"
//         //         // Layout.fillWidth: true
//         //         //   Layout.leftMargin: 16
//         //         //   Layout.rightMargin: 16

//         //           id: statusContainer

//         //               Layout.fillWidth: true
//         //               Layout.leftMargin: 16
//         //               Layout.rightMargin: 16

//         //               color: "blue"
//         //               radius: 16
//         //               border.color: "#F1F5F9"

//         //               // 3 rows × 96 height
//         //               // 2 gaps × 20 spacing
//         //               // 24 top/bottom padding
//         //               implicitHeight: statusGrid.implicitHeight + 24
//         //               width: 300


//         //     }
//             // ===== CARD that contains the GridLayout =====
//                         Rectangle {
//                             id: statusCard
//                             Layout.fillWidth: true
//                             Layout.leftMargin: 16
//                             Layout.rightMargin: 16
//                             Layout.topMargin: 4

//                             // Auto height based on content
//                             implicitHeight: statusGrid.implicitHeight + 32   // 16 top + 16 bottom padding

//                             color: "#FFFFFF"
//                             radius: 16
//                             border.color: "#F1F5F9"
//                             border.width: 1

//                             // Soft shadow (optional)
//                             layer.enabled: true
//                             layer.effect: null

//                             GridLayout {
//                                 id: statusGrid
//                                //Layout.fillWidth: true
//                                // // anchors.fill: parent
//                                //  Layout.leftMargin: 16
//                                //  Layout.rightMargin: 16
//                                //  Layout.topMargin: 10
//                                 // x: 12
//                                 //     y: 12

//                                 //     width: parent.width - 24
//                                 //       height: parent.height - 24
//                                 // // Grid Configuration
//                                 // columns: 2
//                                 // rows: 3
//                                 // // 3 items per row (2 rows total for 6 cards)
//                                 anchors {
//                                                         fill: parent
//                                                         margins: 16          // padding inside the card
//                                                     }
//                               // Layout.leftMargin: 30
//                                 //Layout.topMargin: 20
//                                 rowSpacing: 12
//                                 columnSpacing: 12
//                                 //anchors.fill: parent
//                                 //anchors.margins: 12

//                                 columns: 2

//                                 // Track active filter state across cards
//                                 property string activeFilter: "all" // "all", "pending", "confirmed", "cancelled"

//                                 // 1. Total Bookings
//                                 BookingsStatusCard {
//                                     //Layout.fillWidth: true
//                                     //Layout.preferredHeight: 96
//                                     title: "Total Bookings"
//                                     //value: String(clientModel.totalBookings)
//                                     iconBgColor: "#2563EB"
//                                     cardBgColor: "#F8FAFC"
//                                     iconSource: "qrc:/ui/assets/ic_bookings.svg"
//                                     isSelected: statusGrid.activeFilter === "all"
//                                     onClicked: statusGrid.activeFilter = "all"
//                                 }

//                                 // 2. Pending
//                                 BookingsStatusCard {
//                                     //Layout.fillWidth: true
//                                     //implicitHeight: 96
//                                     title: "Pending"
//                                     //value: String(clientModel.pendingBookings)
//                                     iconBgColor: "#F59E0B"
//                                     cardBgColor: "#FFFBEB"
//                                     iconSource: "qrc:/ui/assets/pending-icon.svg"
//                                     isSelected: statusGrid.activeFilter === "pending"
//                                     onClicked: statusGrid.activeFilter = "pending"
//                                 }

//                                 // 3. Confirmed
//                                 BookingsStatusCard {
//                                     //Layout.fillWidth: true
//                                     //implicitHeight: 96
//                                     title: "Confirmed"
//                                     //value: String(clientModel.confirmedBookings)
//                                     iconBgColor: "#10B981"
//                                     cardBgColor: "#F0FDF4"
//                                     iconSource: "qrc:/ui/assets/good-standing-icon.svg"
//                                     isSelected: statusGrid.activeFilter === "confirmed"
//                                     onClicked: statusGrid.activeFilter = "confirmed"
//                                 }

//                                 // 4. Cancelled
//                                 BookingsStatusCard {
//                                     //Layout.fillWidth: true
//                                     //implicitHeight: 96
//                                     title: "Cancelled"
//                                     //value: String(clientModel.cancelledBookings)
//                                     iconBgColor: "#EF4444"
//                                     cardBgColor: "#FEF2F2"
//                                     iconSource: "qrc:/ui/assets/cancelled-icon.svg"
//                                     isSelected: statusGrid.activeFilter === "cancelled"
//                                     onClicked: statusGrid.activeFilter = "cancelled"
//                                 }

//                                 // 5. Total Spent
//                                 BookingsStatusCard {
//                                     //Layout.fillWidth: true
//                                     //implicitHeight: 96
//                                     title: "Total Spent"
//                                     //value: "MWK " + Number(clientModel.sumOfBookings).toLocaleString()
//                                     iconBgColor: "#8B5CF6"
//                                     cardBgColor: "#F5F3FF"
//                                     iconSource: "qrc:/ui/assets/ic_wallet.svg"
//                                 }

//                                 // 6. Active Disputes
//                                 BookingsStatusCard {
//                                     //Layout.fillWidth: true
//                                     //implicitHeight: 96
//                                     title: "Active Disputes"
//                                     //value: String(clientModel.myDisputesModelId ? clientModel.myDisputesModelId.count : 0)
//                                     iconBgColor: "#06B6D4"
//                                     cardBgColor: "#E0F2FE"
//                                     iconSource: "qrc:/ui/assets/ic_dispute.svg"
//                                 }
//                             }
//                         }


//          }

//     }

// }
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils" as UtilsModule
import "../../home/components"
import "../../../components/cards"

Page {
    id: root
    anchors.fill: parent
    // property string title: "My Bookings"
    // property bool showHeader: true
    // property bool showBack: true
    // property bool showBackButton: false
    // property bool isSearchBar: false
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color  easyBlueColor: "#EEF2FF"
    readonly property color  textColor: "#0F172A"
    readonly property color  helloCardBgColor: "#E0F2FE"
    // ColumnLayout {
    //     anchors.fill: parent
    //     spacing: 0

    //     // ===== FIXED RED BAR (not scrollable) =====
    //     Rectangle {
    //        Layout.fillWidth: true
    //        Layout.leftMargin: 16
    //        Layout.rightMargin: 16
    //        Layout.topMargin: 16
    //        Layout.preferredHeight: 80
    //        color: root.primaryColor
    //        radius: 4

    //        RowLayout{
    //            anchors.fill: parent
    //            anchors.topMargin: 8
    //            anchors.leftMargin: 16
    //            anchors.rightMargin: 16
    //            ColumnLayout{
    //                spacing: 4
    //                Layout.fillWidth: true
    //                Layout.alignment: Qt.AlignTop
    //                RowLayout{
    //                    spacing: 10
    //                    Layout.alignment: Qt.AlignTop
    //                    // Text{

    //                    //     //Layout.alignment: Qt.AlignHCenter
    //                    //     text: "Hello, Accofinder"
    //                    //     font.pointSize: 18
    //                    //     font.bold: true
    //                    //     color: root.textColor
    //                    // }
    //                }
    //                Text {
    //                    text: qsTr("Here is the overview of your bookings")
    //                    color: root.helloCardBgColor
    //                    font.pointSize: 16
    //                    font.bold: true
    //                }
    //            }
    //        }
    //   }

        //}

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

                // ===== CARD with GridLayout =====
                // Rectangle {
                //     id: statusCard
                //     Layout.fillWidth: true
                //     Layout.leftMargin: 16
                //     Layout.rightMargin: 16
                //     Layout.topMargin: 16

                //     implicitHeight: root.height

                //     color: "#FFFFFF"
                //     radius: 16
                //     border.color: "#F1F5F9"
                //     border.width: 1

                    // GridLayout {
                    //     id: statusGrid
                    //     anchors {
                    //         fill: parent
                    //         margins: 16
                    //     }

                    //     columns: 2
                    //     rowSpacing: 12
                    //     columnSpacing: 12

                    //     property string activeFilter: "all"
                 Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 0
                    Layout.preferredHeight: 2
                    color: root.primaryColor
                    radius: 4
               }
                        BookingsStatusCard {
                            Layout.preferredWidth: 300
                            Layout.preferredHeight: 70
                            title: "Pending"
                            iconBgColor: "#F59E0B"
                            cardBgColor: "#FFFBEB"
                            iconSource: "qrc:/ui/assets/pending-icon.svg"
                            isSelected: statusGrid.activeFilter === "pending"
                            onClicked: statusGrid.activeFilter = "pending"
                            Layout.leftMargin:16
                            Layout.alignment: Qt.AlignHCenter
                        }

                        BookingsStatusCard {
                            Layout.preferredWidth: 300
                            Layout.preferredHeight: 70
                            title: "Confirmed"
                            iconBgColor: "#10B981"
                            cardBgColor: "#F0FDF4"
                            iconSource: "qrc:/ui/assets/good-standing-icon.svg"
                            isSelected: statusGrid.activeFilter === "confirmed"
                            onClicked: statusGrid.activeFilter = "confirmed"
                            Layout.leftMargin:16
                            Layout.alignment: Qt.AlignHCenter
                        }

                        BookingsStatusCard {
                            Layout.preferredWidth: 300
                            Layout.preferredHeight: 70
                            title: "Cancelled"
                            iconBgColor: "#EF4444"
                            cardBgColor: "#FEF2F2"
                            iconSource: "qrc:/ui/assets/cancelled-icon.svg"
                            isSelected: statusGrid.activeFilter === "cancelled"
                            onClicked: statusGrid.activeFilter = "cancelled"
                            Layout.leftMargin:16
                            Layout.alignment: Qt.AlignHCenter
                        }

                        BookingsStatusCard {
                            Layout.preferredWidth: 300
                            Layout.preferredHeight: 70
                            title: "Total Spent"
                            iconBgColor: "#8B5CF6"
                            cardBgColor: "#F5F3FF"
                            iconSource: "qrc:/ui/assets/ic_wallet.svg"
                            Layout.leftMargin:16
                            Layout.alignment: Qt.AlignHCenter
                        }

                        BookingsStatusCard {
                            Layout.preferredWidth:300
                            Layout.preferredHeight: 70
                            title: "Active Disputes"
                            iconBgColor: "#06B6D4"
                            cardBgColor: "#E0F2FE"
                            iconSource: "qrc:/ui/assets/ic_dispute.svg"
                            Layout.leftMargin:16
                            Layout.alignment: Qt.AlignHCenter
                        }

                // Bottom spacer
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                }
            }
        }
    }
//}
