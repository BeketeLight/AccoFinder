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
    color: "#F4F6F9" //"#EEF2FF"//"#F8F9FA"
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
                            // RowLayout{
                            //    spacing: 0
                            //    Text{
                            //        text: qsTr("My Bookings")
                            //         font.pointSize: 18
                            //         font.bold: true
                            //         color: "#1E293B"
                            //         Layout.leftMargin: 10
                            //    }
                            //    Item{
                            //        Layout.preferredWidth: 180
                            //    }
                            //    Text{
                            //         text: qsTr("View all")
                            //         font.pointSize: 14
                            //         font.bold: true
                            //         color: "#4F46E5"
                            //         Layout.leftMargin: 10
                            //         MouseArea{
                            //             anchors.fill: parent
                            //             onClicked: {
                            //                 NavUtils.navigateToBookingView()
                            //             }
                            //         }
                            //    }
                            // }
                            BookingsCard{
                               titleText: "Booking Overview"
                               subtitleText: "Check your upcoming and completed service bookings."
                               headerIconSource: "qrc:/ui/assets/bookingcard-icon.svg"
                               headerIconBgColor: "#F0FDF4"
                               headerIconTintColor: "#16A34A"
                               viewAllText: "View all"
                               //bottomButtonText: "View all bookings"

                               statsModel: [
                                    {
                                        title: "Pending",
                                        count: 3,
                                        iconSourceImage: "qrc:/ui/assets/pending-icon.svg",
                                        iconColor: "blue",
                                        iconBg: "#FEF3C7",
                                        badgeBg: "#FEF3C7",
                                        badgeTextColor: "#D97706",
                                        actionId: "Pending"
                                    },
                                    {
                                        title: "Confirmed",
                                        count: 0,
                                        iconSourceImage: "qrc:/ui/assets/confirmed-icon.svg",
                                        iconColor: "#0B6623",//"#16A34A",
                                        iconBg: "#DCFCE7",
                                        badgeBg: "#DCFCE7",
                                        badgeTextColor: "#16A34A",
                                        actionId: "Confirmed"
                                    },
                                    {
                                        title: "Cancelled",
                                        count: 1,
                                        iconSourceImage: "qrc:/ui/assets/cancelled-icon.svg",
                                        iconColor: "red",
                                        iconBg: "#FEE2E2",
                                        badgeBg: "#FFE4E6",
                                        badgeTextColor: "#E11D48",
                                        actionId: "Cancelled"
                                    }
                               ]

                               onStatItemClicked: (actionId, index) => {
                                    console.log("Clicked booking filter:", actionId)
                                    // e.g. activeFilter = actionId
                                   NavUtils.navigateToBookingsView(actionId) //Navigate to selected status
                               }
                               onViewAllClicked: (filter)=>{
                                      console.log("View all clicked:", filter)
                                      NavUtils.navigateToBookingsView(filter)
                               }


                            }

                            BookingsCard{
                               titleText: "Booking Disputes"
                               subtitleText: "Check your disputes and resolve disputes on your bookings."
                               headerIconSource: "qrc:/ui/assets/disputes-warning-icon.svg"
                               headerIconBgColor: "#EEF2FE"
                               headerIconTintColor: "blue"
                               statsModel: [
                                    {
                                        title: "Active",
                                        count: 3,
                                        iconSourceImage: "qrc:/ui/assets/dispute-active-icon.svg",
                                        iconColor:"#D97706",
                                        iconBg: "#FEF3C7",
                                        badgeBg: "#FEF3C7",
                                        badgeTextColor: "#D97706",
                                        actionId: "active"
                                    },
                                    {
                                        title: "Resolved",
                                        count: 12,
                                        iconSourceImage: "qrc:/ui/assets/confirmed-icon.svg",
                                        iconColor: "#0B6623",
                                        iconBg: "#DCFCE7",
                                        badgeBg: "#DCFCE7",
                                        badgeTextColor: "#16A34A",
                                        actionId: "resolved"
                                    },
                                    {
                                        title: "Cancelled",
                                        count: 1,
                                        iconSourceImage: "qrc:/ui/assets/cancelled-icon.svg",
                                        iconColor: "red",
                                        iconBg: "#FEE2E2",
                                        badgeBg: "#FFE4E6",
                                        badgeTextColor: "#E11D48",
                                        actionId: "Cancelled"
                                    }
                               ]

                               onStatItemClicked: (actionId, index) => {
                                    console.log("Clicked dispute filter:", actionId)
                                    // e.g. activeFilter = actionId

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
                   height: 300
                   color: "#F4F6F9"
                   anchors.top: guestBanner.bottom

                   ColumnLayout{
                       //anchors.top: guestBanner.bottom
                       spacing: 8
                       BookingsCard{
                          titleText: "Booking Overview"
                          subtitleText: "Check your upcoming and completed service bookings."
                          headerIconSource: "qrc:/ui/assets/bookingcard-icon.svg"
                          headerIconBgColor: "#F0FDF4"
                          headerIconTintColor: "#16A34A"
                          Layout.leftMargin: 10
                          //bottomButtonText: "View all bookings"

                          statsModel: [
                               {
                                   title: "Pending",
                                   count: 3,
                                   iconSourceImage: "qrc:/ui/assets/pending-icon.svg",
                                   iconColor: "blue",
                                   iconBg: "#FEF3C7",
                                   badgeBg: "#FEF3C7",
                                   badgeTextColor: "#D97706",
                                   actionId: "Pending"
                               },
                               {
                                   title: "Confirmed",
                                   count: 12,
                                   iconSourceImage: "qrc:/ui/assets/confirmed-icon.svg",
                                   iconColor: "#0B6623",//"#16A34A",
                                   iconBg: "#DCFCE7",
                                   badgeBg: "#DCFCE7",
                                   badgeTextColor: "#16A34A",
                                   actionId: "Confirmed"
                               },
                               {
                                   title: "Cancelled",
                                   count: 1,
                                   iconSourceImage: "qrc:/ui/assets/cancelled-icon.svg",
                                   iconColor: "red",
                                   iconBg: "#FEE2E2",
                                   badgeBg: "#FFE4E6",
                                   badgeTextColor: "#E11D48",
                                   actionId: "Cancelled"
                               }
                          ]

                          onStatItemClicked: (actionId, index) => {
                             console.log("Clicked booking filter:", actionId)
                               // e.g. activeFilter = actionId
                              NavUtils.navigateToSignIn()//Navigate to selected status
                          }
                          onViewAllClicked: NavUtils.navigateToSignIn()

                    }

                   }
                   }


                }
            }
       }
    }
}



