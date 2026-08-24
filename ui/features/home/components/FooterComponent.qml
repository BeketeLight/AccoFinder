import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/navigations"
import "../../../utils" as UtilsModule
Page{
   id: footerPageId
   property int currentIndex : 0
   // At the top of FooterComponent.qml
   signal tabSelected(int index)
   signal homeTapped()
   signal propertiesTapped()
   signal bookingsTapped()
   signal accountTapped()
   signal saveTapped()
   signal dashboardTapped()

    Component.onCompleted: console.log("FooterComponent loaded, currentIndex property exists")
      background: Rectangle {
         color: "#F8F9FA"
      }
       RowLayout {
           anchors.fill: parent
           spacing: 0
           Item {
               Layout.preferredWidth: 10
           }
         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillWidth: true  // 👈 Distributes tab to 25% of parent width
            Layout.fillHeight: true
            spacing: 0
            ToolButton{
               icon.name: "Home-icon"
               icon.source:"qrc:/ui/assets/home-icon.svg"
               icon.height: 24
               icon.width: 24
               background: null
               icon.color: currentIndex === 0 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               onClicked: {
                        if(currentIndex === 0) return
                        currentIndex = 0
                        footerPageId.homeTapped()
                        tabSelected(0)
                  }
               }
            Text{
               text: qsTr("Home")
               Layout.alignment: Qt.AlignHCenter
               //font.bold: currentIndex === 0
            }
         }
         Item {
             Layout.preferredWidth: 10
         }
         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillWidth: true  // 👈 Distributes tab to 25% of parent width
            Layout.fillHeight: true
            spacing: 0
            ToolButton{
               icon.name: "Properties-icon"
               icon.source:"qrc:/ui/assets/properties-icon.svg"
               icon.height: 24
               icon.width: 24
               icon.color: currentIndex === 1 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               background: null
               onClicked: {
                  if(currentIndex === 1) return
                     footerPageId.propertiesTapped()
                     currentIndex = 1
                     tabSelected(1)
               }
            }
            Text{
               text: qsTr("Properties")
               Layout.alignment: Qt.AlignHCenter
               //font.bold: currentIndex === 1
            }
         }
         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillWidth: true  // 👈 Distributes tab to 25% of parent width
            Layout.fillHeight: true
            spacing: 0
         ToolButton{
            icon.name: "Save-icon"
            icon.source:"qrc:/ui/assets/save-icon.svg"
            icon.height: 24
            icon.width: 24
            background: null
            icon.color: currentIndex === 2 ? "#2563EB" : "gray"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                     if(currentIndex === 2) return
                     currentIndex = 2
                     footerPageId.saveTapped()
                     tabSelected(2)
               }
            }
         Text{
            text: qsTr("Save")
            Layout.alignment: Qt.AlignHCenter
            //font.bold: currentIndex === 2
         }
      }

         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillWidth: true // 👈 Distributes tab to 25% of parent width
            Layout.fillHeight: true
            spacing: 0
            ToolButton{
               icon.name: "Bookings-icon"
               icon.source:"qrc:/ui/assets/bookings-icon.svg"
               icon.height: 24
               icon.width: 24
               icon.color: currentIndex === 3 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               background: null
               onClicked: {
                  if(currentIndex === 3) return
                     footerPageId.bookingsTapped()
                     currentIndex = 3
                     tabSelected(3)
                  }
            }
            Text{
               text: qsTr("Bookings")
               Layout.alignment: Qt.AlignHCenter
               //font.bold: currentIndex === 2
            }
         }
         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillWidth: true// 👈 Distributes tab to 25% of parent width
            Layout.fillHeight: true
            spacing: 0
            ToolButton{
               icon.name: "Account-icon"
               icon.source:"qrc:/ui/assets/account-icon.svg"
               icon.height: 24
               icon.width: 24
               icon.color: currentIndex === 4 ? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               background: null
               onClicked: {
                  if(currentIndex === 4) return
                     currentIndex = 4
                     footerPageId.accountTapped()
                     tabSelected(4)
               }
            }
            Text{
               text: qsTr("Account")
               Layout.alignment: Qt.AlignHCenter
               //font.bold: currentIndex === 3
            }

         }
         ColumnLayout{
            Layout.preferredHeight: 0
            Layout.fillWidth: true// 👈 Distributes tab to 25% of parent width
            Layout.fillHeight: true
            spacing: 0
            ToolButton{
               icon.name: "dashboard-icon"
               icon.source:"qrc:/ui/assets/dashboard-icon.svg"
               icon.height: 24
               icon.width: 24
               icon.color: currentIndex === 5? "#2563EB" : "gray"
               Layout.alignment: Qt.AlignHCenter
               background: null
               onClicked: {
                  if(currentIndex === 5) return
                     currentIndex = 5
                     footerPageId.dashboardTapped()
                     tabSelected(5)
               }
            }
            Text{
               text: qsTr("Dashboard")
               Layout.alignment: Qt.AlignHCenter
               //font.bold: currentIndex === 3
            }

         }
}

}






