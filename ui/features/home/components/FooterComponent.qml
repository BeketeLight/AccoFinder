import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/navigations"
import "../../../utils" as UtilsModule

Page{
   id: footerPageId
   property int currentIndex : 0
   footer: ToolBar {
      background: Rectangle {
           color: "white"
      }
       RowLayout {
           anchors.fill: parent

           Item {
              Layout.preferredWidth: 10
           }
         BottomNavBar{
               active: footerPageId.currentIndex === 0
            contentItem: ColumnLayout {
                 Image {
                    id: home
                    source: "qrc:/ui/assets/home.svg"
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 24
                    sourceSize.width: 48
                    sourceSize.height: 48
                    Layout.alignment: Qt.AlignHCenter
                    antialiasing: true
                    smooth: true
                 }
                Label {
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Home")
                        color: "black"
                    }
                    Layout.alignment: Qt.AlignHCenter
                    font {
                        pointSize: 12
                        bold: true
                    }
                }
            }
            onClicked: {
               footerPageId.currentIndex = 0
            }
         }
         BottomNavBar{
               active: footerPageId.currentIndex === 1

               contentItem: ColumnLayout {
                   Image {
                       id: property
                       width: 24
                       height: 24
                       source: "qrc:/ui/assets/properties.svg"
                       fillMode: Image.PreserveAspectFit
                       //Layout.leftMargin: 24
                       Layout.preferredHeight: 24
                       Layout.preferredWidth: 24
                       sourceSize.width: 48
                       sourceSize.height: 48
                       Layout.alignment: Qt.AlignHCenter
                       antialiasing: true
                       smooth: true
                   }
                   Label {
                       Text {
                           anchors.centerIn: parent
                           text: qsTr("Properties")
                           color: "black"
                       }
                       Layout.alignment: Qt.AlignHCenter
                       font {
                           pointSize: 12
                           bold: true
                       }
                   }
               }
               onClicked: {
                  footerPageId.currentIndex = 1
                  UtilsModule.NavigationUtils.navigateToProperties();
               }
         }

         BottomNavBar{
               active: footerPageId.currentIndex === 2
               contentItem: ColumnLayout {
                   Image {
                       id: bookings
                       width: 24
                       height: 24
                       source: "qrc:/ui/assets/bookings.svg"
                       fillMode: Image.PreserveAspectFit
                       Layout.preferredHeight: 24
                       Layout.preferredWidth: 24
                       sourceSize.width: 48
                       sourceSize.height: 48
                       Layout.alignment: Qt.AlignHCenter
                       antialiasing: true
                       smooth: true
                   }
                   Label {
                       Text {
                           anchors.centerIn: parent
                           text: qsTr("Bookings")
                           color: "black"
                       }
                       Layout.alignment: Qt.AlignHCenter
                       font {
                           pointSize: 12
                           bold: true
                       }
                   }
               }
               onClicked: {
                  footerPageId.currentIndex = 2
                  UtilsModule.NavigationUtils.navigateToBookings();
               }
         }
         BottomNavBar{
            active: footerPageId.currentIndex === 3

               contentItem: ColumnLayout {
                   Image {
                       id: account
                       width: 24
                       height: 24
                       source: "qrc:/ui/assets/account.svg"
                       fillMode: Image.PreserveAspectFit
                       Layout.preferredHeight: 24
                       Layout.preferredWidth: 24
                       sourceSize.width: 48
                       sourceSize.height: 48
                       Layout.alignment: Qt.AlignHCenter
                       antialiasing: true
                       smooth: true
                   }
                   Label {
                       Text {
                           anchors.centerIn: parent
                           text: qsTr("Account")
                           color: "black"
                       }
                       Layout.alignment: Qt.AlignHCenter
                       font {
                           pointSize: 12
                           bold: true
                       }
                   }
               }
               onClicked: {
                  footerPageId.currentIndex = 3
                  UtilsModule.NavigationUtils.navigateToSignIn();
              }
         }
      }
   }
}
