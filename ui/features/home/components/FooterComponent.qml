import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/navigations"
import "../../../utils" as UtilsModule

ToolBar{
   id: footerPageId
   property int currentIndex : 0
    Component.onCompleted: console.log("FooterComponent loaded, currentIndex property exists")
      background: Rectangle {
           color: "white"
      }
       RowLayout {
           anchors.fill: parent

           Item {
              Layout.preferredWidth: 10
           }
         ColumnLayout{
               spacing: 0
             ToolButton{
                  icon.name: "Home-icon"
                  icon.source:"qrc:/ui/assets/home.svg"
                  icon.height: 24
                  icon.width: 24
                  icon.color: currentIndex === 0 ? "blue" : "black"
                  Layout.alignment: Qt.AlignHCenter
                  background: null
                  onClicked: {
                        if(currentIndex === 0) return
                       currentIndex = 0
                       UtilsModule.NavigationUtils.replace("../features/home/screens/HomeScreen.qml")
                  }

             }
             Text{
                 text: qsTr("Home")
                 Layout.alignment: Qt.AlignHCenter
                 color: currentIndex === 0 ? "Blue" : "black"

                 font{
                     pointSize: 12
                 }
             }
         }

         ColumnLayout{
               spacing: 0
             ToolButton{
                  icon.name: "Properties-icon"
                  icon.source:"qrc:/ui/assets/properties.svg"
                  icon.height: 24
                  icon.width: 24
                  icon.color: currentIndex === 1 ? "blue" : "black"
                  Layout.alignment: Qt.AlignHCenter
                  background: null
                  onClicked: {
                     if(currentIndex === 1) return
                       currentIndex = 1
                       UtilsModule.NavigationUtils.navigateToProperties();
                  }

             }
             Text{
                 text: qsTr("Properties")
                 Layout.alignment: Qt.AlignHCenter
                 color: currentIndex === 1 ? "Blue" : "black"

                 font{
                     pointSize: 12
                 }
             }
         }
         ColumnLayout{
               spacing: 0
             ToolButton{
                  icon.name: "Bookings-icon"
                  icon.source:"qrc:/ui/assets/bookings.svg"
                  icon.height: 24
                  icon.width: 24
                  icon.color: currentIndex === 2 ? "blue" : "black"
                  Layout.alignment: Qt.AlignHCenter
                  background: null
                  onClicked: {
                     if(currentIndex === 2) return
                       currentIndex = 2
                       UtilsModule.NavigationUtils.navigateToBookings();
                  }

             }
             Text{
                 text: qsTr("Bookings")
                 Layout.alignment: Qt.AlignHCenter
                 color: currentIndex === 2 ? "Blue" : "black"

                 font{
                     pointSize: 12
                 }
             }
         }

         ColumnLayout{
               spacing: 0
             ToolButton{
                  icon.name: "Account-icon"
                  icon.source:"qrc:/ui/assets/account.svg"
                  icon.height: 24
                  icon.width: 24
                  icon.color: currentIndex === 3 ? "blue" : "black"
                  Layout.alignment: Qt.AlignHCenter
                  background: null
                  onClicked: {
                     if(currentIndex === 3) return
                       currentIndex = 3
                       UtilsModule.NavigationUtils.navigateToAccount()
                  }
             }
             Text{
                 text: qsTr("Account")
                 Layout.alignment: Qt.AlignHCenter
                 color: currentIndex === 3 ? "Blue" : "black"

                 font{
                     pointSize: 12
                 }
             }
         }

       }

   }


