import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../utils/NavigationUtils.js" as NavUtils
import "../../home/components"
import "../../../components/cards"
import "../../home/delegates"
import "../components"

Rectangle {
    id: root
    anchors.fill: parent
    readonly property color primaryColor: "#2563EB"
    readonly property color primaryDarkColor: "#1D4ED8"
    readonly property color  easyBlueColor: "#EEF2FF"
    readonly property color  textColor: "#0F172A"
    readonly property color  helloCardBgColor: "#E0F2FE"
    readonly property color  cardBgColor: "#EEF2FF"
    property bool  isLoggedIn: AppSettings.isLoggedIn()
    readonly property bool  isGuest: !AppSettings.isLoggedIn()
    readonly property bool  isClient: AppSettings.isLoggedIn() && AppSettings.userType() === "CLIENT"
    readonly property bool  isAgent: AppSettings.isLoggedIn() && AppSettings.userType() === "AGENT"
    //readonly property color primaryColor: "#2563EB"
    color: "#EEF2FF"//"#F8F9FA"
        // ===== SCROLLABLE CONTENT =====

    //Helper function for Navigation based on user

    function handleClick(category){
        console.log("Agent initiated")
        console.log("Landloard initiated")
        console.log("HandleClicked initiated")
        if(root.isGuest){
            NavUtils.navigateToSignIn()
            return
        }
        var cat = category.toLowerCase()
        if(root.isClient){
            switch(category){
                case "pending":
                    NavUtils.navigateToPendingBookings()
                    //NavUtils.push("/ui/features/bookings/pages/PendingBookingsPage.qml")
                    break
                case "confirmed":
                    NavUtils.navigateToConfirmedBookings()
                    break
                case "cancelled":
                    NavUtils.navigateToCancelleddBookings()
                    break
            }
            return
        }
        // if(root.isAgent){
        //     switch(category){
        //     case "pending":
        //         //NavUtils.navigateToPendingBookings()
        //         NavUtils.push("PendingBookingsPage.qml")
        //         break
        //     case "Confirmed":
        //         NavUtils.navigateToConfirmedBookings()
        //         break
        //     case "cancelled":
        //         NavUtils.navigateToCancelleddBookings()
        //         break
        //     }
        //     return
        // }
    }
    Component.onCompleted: {
       root.isLoggedIn = AppSettings.isLoggedIn()
    }
    Connections{
        target: AppSettings
        function onUserSessionChanged(){
                 root.isLoggedIn = AppSettings.isLoggedIn()
        }
    }
     Loader{
       anchors.fill: parent
       sourceComponent: root.isLoggedIn ? loggedInUser : guestUser
    }

    Component{
       id: loggedInUser

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
                        ColumnLayout{
                            spacing: 8
                            RowLayout{
                                spacing: 0
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
                                        onClicked: {
                                            NavUtils.navigateToPendingBookings()
                                        }
                                    }
                                }
                            }

                            RowLayout{
                                spacing: 2
                                BookingsStatusCard {
                                    Layout.fillWidth: true
                                    cardHeight: 80
                                    title: "Pending"
                                    iconBgColor: "#F59E0B"
                                    cardBgColor: "white"
                                    iconSource: "qrc:/ui/assets/pending-icon.svg"
                                    //isSelected: statusGrid.activeFilter = "pending"
                                    onClicked: {
                                        //statusGrid.activeFilter === "pending"
                                        console.log("Pending clicked..")
                                        root.handleClick("pending")
                                    }
                                    Layout.leftMargin:4
                                    Layout.rightMargin: 10
                                    Layout.alignment: Qt.AlignHCenter

                                }
                                BookingsStatusCard {
                                    Layout.fillWidth: true
                                    cardHeight: 80
                                    title: "Confirmed"
                                    iconBgColor: "#10B981"
                                    cardBgColor: "white"
                                    iconSource: "qrc:/ui/assets/good-standing-icon.svg"
                                    //isSelected: statusGrid.activeFilter === "confirmed"
                                    //onClicked: statusGrid.activeFilter = "confirmed"
                                    Layout.leftMargin: 4
                                    Layout.rightMargin: 10
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                BookingsStatusCard {
                                    Layout.fillWidth: true
                                    cardHeight: 80
                                    title: "Cancelled"
                                    iconBgColor: "#EF4444"
                                    cardBgColor: "white"
                                    iconSource: "qrc:/ui/assets/cancelled-icon.svg"
                                    //isSelected: statusGrid.activeFilter === "cancelled"
                                   // onClicked: statusGrid.activeFilter = "cancelled"
                                    onClicked: NavUtils.navigateToCancelleddBookings()
                                    Layout.leftMargin:4
                                    Layout.rightMargin: 10
                                    Layout.alignment: Qt.AlignHCenter
                                    //Layout.alignment: Qt.AlignTop
                                }
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

                ColumnLayout{
                    Layout.fillWidth: true
                    spacing: 10
                    RowLayout{
                        Layout.fillWidth: true
                        spacing: 0
                        ColumnLayout{
                            spacing: 8
                            Text{
                                text: qsTr("Booking disputes")
                                font.pointSize: 18
                                font.bold: true
                                color: "#1E293B"
                                Layout.leftMargin: 10
                            }
                            BookingsStatusCard {
                                cardWidth: 370
                                //Layout.fillWidth: true
                                cardHeight: 80
                                title: "Active disputes"
                                iconBgColor: "#06B6D4"
                                cardBgColor:"#FFFFFF"/* root.cardBgColor*/
                                iconSource: "qrc:/ui/assets/disputes-icon.svg"
                                //isSelected: statusGrid.activeFilter === "pending"
                               // onClicked: statusGrid.activeFilter = "pending"
                                //onClicked: NavUtils.
                                Layout.leftMargin:6
                                Layout.rightMargin: 10
                                //Layout.alignment: Qt.AlignHCenter
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

            }

        }
    }

    Component{
       id: guestUser
       Flickable {
           id: scrollArea
           anchors.fill: parent
           contentHeight: contentColumn.height
           clip: true

           ColumnLayout {
               id: contentColumn
               width: scrollArea.width
               spacing: 16

               // --- HERO WELCOME BANNER (Guest Only) ---
               Rectangle {
                   id: guestBanner
                   Layout.fillWidth: true
                   Layout.preferredHeight: 180
                   //visible: !pageRoot.isLoggedIn
                   color: "#2563EB"
                   visible: root.isGuest //visible when its guest
                  // Layout.visible: visible

                   ColumnLayout {
                       anchors.fill: parent
                       anchors.margins: 16
                       spacing: 12

                       Text {
                           text: qsTr("Welcome to AccoFinder")
                           font.pixelSize: 24
                           font.bold: true
                           color: "#FFFFFF"
                       }

                       Text {
                           text: qsTr("Find your ideal place or accommodation near your preferred location.")
                           font.pixelSize: 13
                           color: "#E0F2FE"
                           Layout.fillWidth: true
                           wrapMode: Text.WordWrap
                       }

                       Button {
                           Layout.preferredWidth: 160
                           Layout.preferredHeight: 40

                           background: Rectangle {
                               color: parent.down ? "#1D4ED8" : "#FFFFFF"
                               radius: 20
                           }

                           contentItem: Text {
                               text: qsTr("Sign in / Register")
                               color: "#2563EB"
                               font.bold: true
                               horizontalAlignment: Text.AlignHCenter
                               verticalAlignment: Text.AlignVCenter
                            }
                           onClicked: NavUtils.navigateToSignIn()
                       }
                   }
                   Rectangle{
                    //backgrorundrect
                   id: statusRect1
                   anchors.topMargin: 6
                   width: root.width
                   height: 120
                   color: "#EEF2FF"
                   anchors.top: guestBanner.bottom

                   ColumnLayout{
                       //anchors.top: guestBanner.bottom
                       spacing: 8
                       RowLayout{
                           spacing: 0
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
                               Layout.fillWidth: true
                               cardHeight: 80
                               title: "Pending"
                               iconBgColor: "#F59E0B"
                               cardBgColor: "white"
                               iconSource: "qrc:/ui/assets/pending-icon.svg"
                               //isSelected: statusGrid.activeFilter === "pending"
                               //onClicked: statusGrid.activeFilter = "pending"
                               Layout.leftMargin:4
                               Layout.rightMargin: 10
                               Layout.alignment: Qt.AlignHCenter
                           }
                           BookingsStatusCard {
                               Layout.fillWidth: true
                               cardHeight: 80
                               title: "Confirmed"
                               iconBgColor: "#10B981"
                               cardBgColor: "white"
                               iconSource: "qrc:/ui/assets/good-standing-icon.svg"
                               //isSelected: statusGrid.activeFilter === "confirmed"
                              // onClicked: statusGrid.activeFilter = "confirmed"
                               Layout.leftMargin: 4
                               Layout.rightMargin: 10
                               Layout.alignment: Qt.AlignHCenter
                           }
                           BookingsStatusCard {
                               Layout.fillWidth: true
                               cardHeight: 80
                               title: "Cancelled"
                               iconBgColor: "#EF4444"
                               cardBgColor: "white"
                               iconSource: "qrc:/ui/assets/cancelled-icon.svg"
                               //isSelected: statusGrid.activeFilter === "cancelled"
                               //onClicked: statusGrid.activeFilter = "cancelled"
                               Layout.leftMargin:4
                               Layout.rightMargin: 10
                               Layout.alignment: Qt.AlignHCenter
                               //Layout.alignment: Qt.AlignTop
                           }
                       }
                   }
                   }


                    Rectangle{
                     //backgrorundrect
                    id: statusRect
                    anchors.topMargin: 6
                    width: root.width
                    height: 110
                    color: "#EEF2FF"
                    anchors.top: statusRect1.bottom

                    ColumnLayout{
                        Layout.fillWidth: true
                        spacing: 10
                        RowLayout{
                            Layout.leftMargin: 10
                            Text{
                                text: qsTr("My Booking")
                                font.pointSize: 16
                                font.bold:true
                            }
                            Item{
                                Layout.preferredWidth: 200
                            }
                            Text{
                                text: qsTr("view all")
                                font.pointSize: 12
                                color: "#64748B"

                                MouseArea{
                                    anchors.fill: parent
                                    onClicked: NavUtils.navigateToSignIn()
                                }
                            }
                        }
                        RowLayout{
                            Layout.fillWidth: true
                            spacing: 30
                            Layout.leftMargin: 16

                            IconCard{
                                iconSource: "qrc:/ui/assets/pending-icon.svg"
                                title: "Pending"
                                iconCardHeight: 50
                                iconCardWidth: 50
                                onClicked: {
                                    NavUtils.navigateToSignIn()
                                }
                            }
                            IconCard{
                                iconSource: "qrc:/ui/assets/good-standing-icon.svg"
                                title: "Confirmed"
                                iconCardHeight: 50
                                iconCardWidth: 50
                                //onClicked: console.log("Confirmed Clicked")
                                onClicked: {
                                    NavUtils.navigateToSignIn()
                                }
                            }
                            IconCard{
                                iconSource: "qrc:/ui/assets/cancel.svg"
                                title: "Cancelled"
                                iconCardHeight: 50
                                iconCardWidth: 50
                                 //iconColor: "red"
                                onClicked: {
                                    //NavUtils.navigateToSignIn()
                                    NavUtils.navigateToCancelleddBookings()
                                }
                            }
                            IconCard{
                                iconSource: "qrc:/ui/assets/save-icon.svg"
                                title: "Saved"
                                iconCardHeight: 50
                                iconCardWidth: 50
                            }
                        }
                       }
                    }

                    Rectangle{
                        anchors.top: statusRect.bottom
                        anchors.topMargin: 6
                        width: root.width
                        color: "#FFFFFF"
                        height: 100
                        visible: root.isAgent || root.isClient
                        //Layout.visible: visible
                        ColumnLayout{
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: qsTr("Disputes")
                                font.pointSize: 16
                                font.bold:true
                                Layout.leftMargin: 10
                            }
                            BookingsStatusCard {
                                cardWidth: 350
                                cardHeight: 60
                                title: "Active disputes"
                                iconBgColor: "#06B6D4"
                                cardBgColor: "white"
                                iconSource: "qrc:/ui/assets/disputes-icon.svg"
                                isSelected: statusGrid.activeFilter === "pending"
                                onClicked: statusGrid.activeFilter = "pending"
                                Layout.leftMargin:16
                                Layout.rightMargin: 10
                            }
                        }
                    }
                }
            }
       }
    }
}



